//
//  HomeVC.swift
//  TrueInstagramApp
//
//  Created by Nazir on 30/12/2017.
//  Copyright © 2017 Nazir. All rights reserved.
//

import UIKit
import Parse



class HomeVC: UICollectionViewController {
    
    var refresher : UIRefreshControl!
    var page : Int = 12
    
    var uuidArray = [String]()
    var picArray = [PFFile]()

    //MARK: - viewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        //alaways verticle scroll
        self.collectionView?.alwaysBounceVertical = true
        
        //changes the navigation title to the currecnt username
        self.navigationItem.title = (PFUser.current()?.object(forKey: "username") as? String)?.uppercased()
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        //recieve notification from EditProfileVC
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        
        
        
       
        
        loadPosts()
        

      
    }
    //MARK: - Reload, Upload, Refresh funcs
    //reloads the home page after it recieved notification
    @objc func reload(_ notification:Notification) {
        collectionView?.reloadData()
    }
    
 
  
    
    
    
    @objc func refresh(){
        loadPosts()
        refresher.endRefreshing()
    }
    //MARK: - LoadPosts Func
    func loadPosts (){
        //make query to the posts class in server
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("username", equalTo: PFUser.current()!.username!)
        postQuery.limit = page
//        postQuery.addDescendingOrder("createdAt")
        postQuery.findObjectsInBackground { (objects, error) in
            if error == nil{
                //clean up
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                //find objects in class related to our request
                for object in objects!{
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                }
                self.collectionView?.reloadData()
            }else{
                print(error?.localizedDescription)
            }
        }
    
    }
    //MARK: - Pageination
    //load more while scrolling down
    //This will load more than the limit which is 12 
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height{
            self.loadMore()
        }
    }
    
    //pagination
    
    func loadMore(){
        //if there is more objects
        if page <= picArray.count{
            //increase page size
            page = page + 12
            
            //load more posts
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: PFUser.current()!.username!)
            query.limit = page
//            query.addDescendingOrder("createdAt")
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    
                    //clean it of other information that is stored
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    //find related objects
                    for object in objects! {
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    }
                    print("loaded +\(self.page)")
                    self.collectionView?.reloadData()
                }else{
                    print(error?.localizedDescription)
                }
            })
            
        }
    }
    
    //MARK: - CollectionView cell
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //number of cells
        return self.picArray.count
    }
    
   //MARK: Cell size
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    //this method affects the functionality of the cell in the in the colllectionview
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //use the imageview item from the homepicturecell class
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomePictureCell
        
        //get the picture from the picArray
        picArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
                cell.picCell.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        
        
        return cell
    }
    
    


    // MARK: - Load data from server into collectionview

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        //create a segue to the headerview class to use their items
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        //MARK:  STEP 1. get user data from the server
        //get user data from the server and insert it into the collectionview
        header.fullnameTxt.text = (PFUser.current()?.object(forKey: "fullname") as? String)?.uppercased()
        header.websiteTxt.text = PFUser.current()?.object(forKey: "website") as? String
        header.websiteTxt.sizeToFit()
        header.bioTxt.text = PFUser.current()?.object(forKey: "bio") as? String
        header.bioTxt.sizeToFit()
        
        //proccess the image in the background
        let avaImgQuery = PFUser.current()?.object(forKey: "avaterimg") as! PFFile
        avaImgQuery.getDataInBackground { (data, error) in
        header.avaterImg.image = UIImage(data: data!)
        }
        header.editProfileBtn.setTitle("Edit Profile", for: UIControlState.normal)
        
        //MARK:  STEP 2. count statistics for POSTS/FOLLOWERS/FOLLOWING
        //count the number of posts and set it to the posts label
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.current()!.username!)
        posts.countObjectsInBackground { (count, error) in
            if error == nil {
                header.postsTxt.text = "\(count)"
            }
        }
        //count the number of followers the current user has
        let follwers = PFQuery(className: "follow")
        follwers.whereKey("following", equalTo: PFUser.current()!.username!)
        follwers.countObjectsInBackground { (count, error) in
            if error == nil{
                header.followersTxt.text = "\(count)"
            }
        }
        //count the number of following the current user has
        let following = PFQuery(className: "follow")
        following.whereKey("follower", equalTo: PFUser.current()!.username!)
        following.countObjectsInBackground { (count, error) in
            if error == nil{
                header.followingsTxt.text = "\(count)"
            }
        }
        
        //MARK: STEP 3. Implement tap gestures for POSTS/FOLLOWERS/FOLLOWING
        //Posts gesture recognizer
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(self.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.postsTxt.isUserInteractionEnabled = true
        header.postsTxt.addGestureRecognizer(postsTap)
        
        //Followers gesture recognizer
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(self.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followersTxt.isUserInteractionEnabled = true
        header.followersTxt.addGestureRecognizer(followersTap)
        
        //Following gesture recognizer
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(self.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followingsTxt.isUserInteractionEnabled = true
        header.followingsTxt.addGestureRecognizer(followingsTap)
        
        
        
        
        
        return header
        
    }
    //MARK: - postsTap/followersTap/followingTap mthods
    @objc func postsTap(){
        //if picarray is not empty
        if !picArray.isEmpty{
            
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
        
    }
    
    @objc func followersTap(){
        //set the global user label to current user
        user = (PFUser.current()?.username!)!
        //set the global showw label to followers
        showw = "followers"
        
        //create a segue to the followersvc and access its items
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! FollowersVC
        //present the viewcontroler
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    @objc func followingsTap(){
        //set the global user label to current user
        user = (PFUser.current()?.username!)!
         //set the global showw label to followers
        showw = "followings"
        
        //create a segue to the followersvc and access its items
        let following = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! FollowersVC
        //present the viewcontroler
        self.navigationController?.pushViewController(following, animated: true)
        
        
    }
    
    //MARK: - Sign Out Button
    @IBAction func signOutBtn_Click(_ sender: Any) {
        
        PFUser.logOutInBackground { (error) in
            if error == nil{
                
                //remove loged in user from app memory
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.synchronize()
                
                let signIn = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as! SignInVC
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = signIn
                
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    
    //MARK: - Go Post
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //send post uuid to "postuuid" variable
        postuuid.append(uuidArray[indexPath.row])
        
        //navigate to PostVC (post view controller)
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PostsVC") as! PostsVC
        self.navigationController?.pushViewController(post, animated: true)
        
        
    }


}
