//
//  FollowersVC.swift
//  TrueInstagramApp
//
//  Created by Nazir on 31/12/2017.
//  Copyright © 2017 Nazir. All rights reserved.
//

var user = String()
var showw = String()

import UIKit
import Parse

class FollowersVC: UITableViewController {
    
    var usernameArray = [String]()
    var avaterImgArray = [PFFile]()
    
    var followersArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the title for top bar of navigation
        self.navigationItem.title = showw.uppercased()
        
        //MARK: create a new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //MARK: swipe to the back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.back))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        if showw == "followers"{
            loadFollowers()
        }
        
        if showw == "followings"{
            loadFollowing()
        }
       
        tableView.rowHeight = 100
       

    }
    
    
    
    //MARK: - LoadFollowers
    func loadFollowers(){
        //MARK: STEP1. FIND IN FOLLOW CLASS PEOPLE FOLLOWING USER
        //find followers of user
        let followersQuery = PFQuery(className: "follow")
        //query setting
        followersQuery.whereKey("following", equalTo: user)
        followersQuery.findObjectsInBackground { (objects, error) in
            if error == nil{
                //clean up so no errors
                self.followersArray.removeAll(keepingCapacity: false)
                //MARK: STEP2. HOLD RECIEVED DATA
                //find objects depending on query settings
                for object in objects!{
                    self.followersArray.append(object.value(forKey: "follower") as! String)
                }
                
                //MARK: STEP3. FIND IN USER CLASS DATA OF USERS FOLLOWING "user'
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followersArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackground(block: { (objects, error) in
                    if error == nil{
                        
                        //clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaterImgArray.removeAll(keepingCapacity: false)
                        
                        for object in objects!{
                            
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avaterImgArray.append(object.object(forKey: "avaterimg") as! PFFile)
                            self.tableView.reloadData()
                        }
                        
                    }else{
                        print(error?.localizedDescription ?? String())
                    }
                })
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        
    }
    //MARK: - LoadFollowing
    func loadFollowing(){
        //MARK: STEP1. FIND IN FOLLOW CLASS PEOPLE FOLLOWER USER
        //find followers of user
        let followingQuery = PFQuery(className: "follow")
        followingQuery.whereKey("follower", equalTo: user)
        followingQuery.findObjectsInBackground { (objects, error) in
            if error == nil{
                self.followersArray.removeAll(keepingCapacity: false)
                //MARK: STEP2. HOLD RECIEVED DATA
                //find objects depending on query settings
                for object in objects!{
                    self.followersArray.append(object.object(forKey: "following") as! String)
                    
                    
                }
                
                 //MARK: STEP3. FIND IN USER CLASS DATA OF USERS FOLLOWERS "user'
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followersArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackground(block: { (objects, error) in
                    if error == nil{
                        
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaterImgArray.removeAll(keepingCapacity: false)
                        
                        for object in objects!{
                            self.usernameArray.append(object.object(forKey: "username")as! String)
                            self.avaterImgArray.append(object.object(forKey: "avaterimg") as! PFFile)
                            self.tableView.reloadData()
                        }
                    }else{
                        print(error?.localizedDescription)
                    }
                })
               
            }else{
                print(error?.localizedDescription)
            }
        }
        
    }
    
    //MARK: - TableView methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    //MARK: Cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FollowersCell
        cell.usernameTxt.text = usernameArray[indexPath.row]
        avaterImgArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
                cell.avaterImg.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription)
            }
        }
        //show do user following or not
        //this checks if the current user has his follower in his following
        let query = PFQuery(className: "follow")
        query.whereKey("follower", equalTo: PFUser.current()!.username!)
        query.whereKey("following", equalTo: cell.usernameTxt.text!)
        query.countObjectsInBackground { (count, error) in
            if error == nil{
                //if one of the current user follower is not in his following then do this
                if count == 0 {
                    cell.followingBtn.setTitle("FOLLOW", for: UIControlState.normal)
                    cell.followingBtn.backgroundColor = UIColor.lightGray
                 //else the current user has his follower in his following then do this
                }else{
                    cell.followingBtn.setTitle("FOLLOWING", for: UIControlState.normal)
                    cell.followingBtn.backgroundColor = UIColor.green
                }
            }else{
             
                print(error?.localizedDescription)
            }
        }
        
        if cell.usernameTxt.text == PFUser.current()?.username{
            cell.followingBtn.isHidden = true
        }
        
        
        return cell
    }
    
    //MARK: - When the user selects row in the table
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        
        if cell.usernameTxt.text == PFUser.current()?.username!{
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
           
            
        }else{
            guestUsername.append(cell.usernameTxt.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
  
    @objc func back(sender : UITabBarItem){
        
        self.navigationController?.popViewController(animated: true)
        
    }


   

 

}
