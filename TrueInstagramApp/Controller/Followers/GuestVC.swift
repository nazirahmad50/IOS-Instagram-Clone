//
//  GuestVC.swift
//  TrueInstagramApp
//
//  Created by Nazir on 01/01/2018.
//  Copyright © 2018 Nazir. All rights reserved.
//

import UIKit
import Parse

var guestUsername = [String]()

class GuestVC: UICollectionViewController {
    
    var refresher : UIRefreshControl!
    var page : Int = 12
    
    var uuidArray = [String]()
    var picArray = [PFFile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.white
        
        //MARK: allow verticle scroll
        self.collectionView?.alwaysBounceVertical = true
        
        //MARK: top bar title will be set to the username that is at the end of guestusernameArray
        self.navigationItem.title = guestUsername.last?.uppercased()
        
        //MARK: create a new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //MARK: swipe to the back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.back))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        //MARK: pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        self.collectionView?.addSubview(refresher)
        //call the load posts method
        loadPosts()

    }
    //MARK: - Back Button method and Refresh method
    @objc func back(back:UIBarButtonItem){
        //push back
        self.navigationController?.popViewController(animated: true)
        //remove the username at the end of the guestUsernameArray
        if !guestUsername.isEmpty{
            guestUsername.removeLast()
        }
        
    }
    
    //MARK: Refresh Method
    //refresh method
    @objc func refresh(){
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
    //MARK: - LoadPosts method
    func loadPosts(){
        
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: guestUsername.last)
        query.limit = page
        query.findObjectsInBackground { (objects, error) in
            if error == nil{
                
                //clean up
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.uuidArray.append(object.object(forKey: "uuid") as! String)
                    self.picArray.append(object.object(forKey: "pic") as! PFFile)
                }
                
                self.collectionView?.reloadData()
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    
    //MARK: - Pageination
    //load more while scrolling down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height{
            self.loadMore()
        }
    }
    
    //pagination
    func loadMore(){
        //if there is more objects
        if page <= picArray.count{
            //increase page size when user scrolls down
            page = page + 12
            
            //load more 
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: guestUsername.last!)
            query.limit = page
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
                    print("loaded + \(self.page)")
                    self.collectionView?.reloadData()
                }else{
                    print(error?.localizedDescription)
                }
            })
            
        }
    }
    
    //MARK: - Number of cells method
    //cell config
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    //MARK: Cell size
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    //MARK: Cell for item at
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomePictureCell
        
        picArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
                cell.picCell.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription)
            }
        }
        
        return cell
    }
    //MARK: - LoadData into viewcontroller
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        //MARK: STEP1. load data of guest
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestUsername.last!)
        infoQuery.findObjectsInBackground { (objects, error) in
            if error == nil{
                
                if objects!.isEmpty{
                    let alert = UIAlertController(title: "\(guestUsername.last!)", message: "This user does not exist", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                        
                        self.navigationController?.popViewController(animated: true)
                        
                    })
                    
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
                
                for object in objects!{
                    
                    header.fullnameTxt.text = (object.object(forKey: "fullname") as? String)?.uppercased()
                    header.bioTxt.text = object.object(forKey: "bio") as? String
                    header.bioTxt.sizeToFit()
                    header.websiteTxt.text = object.object(forKey: "website") as? String
                    header.websiteTxt.sizeToFit()
                    
                    let avaFile : PFFile = (object.object(forKey: "avaterimg") as? PFFile)!
                    avaFile.getDataInBackground(block: { (data, error) in
                        if error == nil{
                            header.avaterImg.image = UIImage(data: data!)
                        }
                    })
                }
            }else{
                print(error?.localizedDescription)
            }
        }
        
        //MARK: STEP2. show do current user follow guest or not
        let query = PFQuery(className: "follow")
        query.whereKey("follower", equalTo: PFUser.current()?.username!)
        query.whereKey("following", equalTo: guestUsername.last)
        query.countObjectsInBackground { (count, error) in
            if error == nil{
                if count == 0{
                    header.editProfileBtn.setTitle("FOLLOW", for: UIControlState.normal)
                    header.bioTxt.backgroundColor = UIColor.lightGray
                }else{
                    header.editProfileBtn.setTitle("Following", for: UIControlState.normal)
                    header.editProfileBtn.backgroundColor = UIColor.green
                }
            }else{
                print(error?.localizedDescription)
            }
        }
        
        //MARK: STEP3. Count Statistics
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: guestUsername.last)
        posts.countObjectsInBackground { (count, error) in
            if error == nil{
                header.postsTxt.text = "\(count)"
            }else{
                print(error?.localizedDescription)
            }
        }
        
        //count followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: guestUsername.last)
        followers.countObjectsInBackground { (count, error) in
            if error == nil{
                header.followersTxt.text = "\(count)"
            }else{
                print(error?.localizedDescription)
            }
        }
        
        //count followings
        let following = PFQuery(className: "follow")
        following.whereKey("follower", equalTo: guestUsername.last)
        following.countObjectsInBackground { (count, error) in
            if error == nil{
                header.followingsTxt.text = "\(count)"
            }else{
                print(error?.localizedDescription)
            }
        }
        //MARK: STEP4. implement tap gestures
        //postsTap gesture
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(self.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.postsTxt.isUserInteractionEnabled = true
        header.postsTxt.addGestureRecognizer(postsTap)
        //followersTap gesture
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(self.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followersTxt.isUserInteractionEnabled = true
        header.followingsTxt.addGestureRecognizer(followersTap)
        //followingtAP gesture
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(self.followingsTap))
        followingTap.numberOfTapsRequired = 1
        header.followingsTxt.isUserInteractionEnabled = true
        header.addGestureRecognizer(followingTap)
        
        
        return header
    }
    
    //MARK: - Tap Gestures methods
    @objc func postsTap(){
        
        if !picArray.isEmpty{
            let indexPath = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.top, animated: true)
        }
        
    }
    
    @objc func followersTap(){
        
        user = guestUsername.last!
        showw = "followers"
        
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! FollowersVC
        self.navigationController?.pushViewController(followers, animated: true)
        
    }
    
    @objc func followingsTap(){
        
        user = guestUsername.last!
        showw = "followings"
        
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! FollowersVC
        self.navigationController?.pushViewController(followings, animated: true)
        
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
