//
//  HashTagsVC.swift
//  TrueInstagramApp
//
//  Created by Nazir Ahmad on 04/02/2018.
//  Copyright © 2018 Nazir. All rights reserved.
//

import UIKit
import Parse

var hashtag = [String]()

class HashTagsVC: UICollectionViewController {
    
    //UI objects
    var refresher : UIRefreshControl!
    var page : Int = 34
    
    //arrays to hold data from server
    var picArray = [PFFile]()
    var uuidArray = [String]()
    
    var filterArray = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigation controller title
        self.navigationItem.title = "#" + "\(hashtag.last!.uppercased())"
        
        //be able to pull down even if there is few posts
        self.collectionView?.alwaysBounceVertical = true
        
        //MARK: create a new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //MARK: swipe to the back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.back))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        //MARK: pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        self.collectionView?.addSubview(refresher)
        
        loadHashtags()
        
        
       
    }
    
    //MARK: - Back Button method and Refresh method
    @objc func back(back:UIBarButtonItem){
        //push back
        self.navigationController?.popViewController(animated: true)
        //remove the hashtag at the end of the hashtag
        if !hashtag.isEmpty{
            hashtag.removeLast()
        }
        
    }
    
    //MARK: Refresh Method
    //refresh method
    @objc func refresh(){
        loadHashtags()
        
    }
    
    //MARK: - loadHashtags
    func loadHashtags(){
        
        //MARK: STEP 1. Find posts related t hashtags
        let hashtagQuery = PFQuery(className: "hashtags")
        hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
        hashtagQuery.findObjectsInBackground { (objects, error) in
            if error == nil{
                
                //clean up
                self.filterArray.removeAll(keepingCapacity: false)
                
                //store related posts in filterArray
                for object in objects!{
                    self.filterArray.append(object.value(forKey: "to") as! String)
                }
                
                //MARK: STEP 2. Find posts that have unique id in filterArray
                let query = PFQuery(className: "posts")
                query.whereKey("uuid", containedIn: self.filterArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) in
                    if error == nil{
                        
                        //clean up
                        self.picArray.removeAll(keepingCapacity: false)
                        self.uuidArray.removeAll(keepingCapacity: false)
                        
                        for object in objects!{
                            
                            self.picArray.append(object.value(forKey: "pic") as! PFFile)
                            
                            self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        }
                        
                        //reload collectionView
                        self.collectionView?.reloadData()
                        self.refresher.endRefreshing()
                    }else{
                        print(error?.localizedDescription ?? String())
                    }
                })
                
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        
        
        
    }
    
    //MARK: - Scroll Down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 3{
            
            loadMore()
        }
    }
    
    //MARK: - Pagination
    func loadMore(){
        
        
        
        //if posts on the server are more than shown increase page size
        if page <= uuidArray.count{
            
            page = page + 15
            
            //MARK: STEP 1. Find posts related t hashtags
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
            hashtagQuery.findObjectsInBackground { (objects, error) in
                if error == nil{
                    
                    //clean up
                    self.filterArray.removeAll(keepingCapacity: false)
                    
                    //store related posts in filterArray
                    for object in objects!{
                        self.filterArray.append(object.value(forKey: "to") as! String)
                    }
                    
                    //MARK: STEP 2. Find posts that have unique id in filterArray
                    let query = PFQuery(className: "posts")
                    query.whereKey("uuid", containedIn: self.filterArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) in
                        if error == nil{
                            
                            //clean up
                            self.picArray.removeAll(keepingCapacity: false)
                            self.uuidArray.removeAll(keepingCapacity: false)
                            
                            for object in objects!{
                                
                                self.picArray.append(object.value(forKey: "pic") as! PFFile)
                                self.uuidArray.append(object.value(forKey: "uuid") as! String)
                            }
                            
                            //reload collectionView
                            self.collectionView?.reloadData()
                            
                        }else{
                            print(error?.localizedDescription ?? String())
                        }
                    })
                    
                }else{
                    print(error?.localizedDescription ?? String())
                }
            }
            
        }
    }
    
//    //MARK: - CollectionView cell
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return picArray.count
        
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
    
    //MARK: - Go Post
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //send post uuid to "postuuid" variable
        postuuid.append(uuidArray[indexPath.row])
        
        //navigate to PostVC (post view controller)
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PostsVC") as! PostsVC
        self.navigationController?.pushViewController(post, animated: true)
        
        
    }


    


    

}
