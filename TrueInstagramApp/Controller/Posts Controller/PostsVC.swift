//
//  PostsVC.swift
//  TrueInstagramApp
//
//  Created by Nazir Ahmad on 24/01/2018.
//  Copyright © 2018 Nazir. All rights reserved.
//

import UIKit
import Parse

var postuuid = [String]()


class PostsVC: UITableViewController {
    
    //arrays to hold server data
    var avaArray = [PFFile]()
    var usernameArray = [String]()
    var dateArray = [Date?]()
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var titleArray = [String]()
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //title label at the top
        self.navigationItem.title = "PHOTO"
        
        //new back Button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backBtn

        //swipe gesture to back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.back))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        //dynamic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)

        
        findPost()
   
       
    }
    //refresh func
    @objc func refresh(){
        self.tableView.reloadData()
    }
    
    //MARK: - backBtn func
  
    @objc func back(sender: UIBarButtonItem){
        //push back
        self.navigationController?.popViewController(animated: true)
        
        //clean post uuid from last
        if !postuuid.isEmpty{
            postuuid.removeLast()
        }
        
    }
    
    //MARK: - findPost func
    //find post in server
    func findPost(){
        
        //find post
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("uuid", equalTo: postuuid.last!)
        postQuery.findObjectsInBackground { (objects, error) in
            if error == nil{
                
                //clean up all arrays
                self.avaArray.removeAll(keepingCapacity: false)
                self.usernameArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                self.titleArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                
                //find releated objects
                for object in objects!{
                    self.usernameArray.append(object.value(forKey: "username") as! String)
                    self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                    self.dateArray.append(object.createdAt)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.titleArray.append(object.value(forKey: "title") as! String)
                }
                
                self.tableView.reloadData()
                
            }else{
                print(error?.localizedDescription)
            }
        }
        
    }
    
   

  

    // MARK: - Table view data source
    //Cell number
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //decalre cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostsCell
        
        //connect objects with information from arrays
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControlState())
        cell.usernameBtn.sizeToFit()
        cell.uuidLbl.text = uuidArray[indexPath.row]
        cell.descLbl.text = titleArray[indexPath.row]
        cell.descLbl.sizeToFit()
        
        
        //place profile from picture avaArray
        avaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            cell.avaImg.image = UIImage(data: data!)
        }
        //place post picture from picArray
        picArray[indexPath.row].getDataInBackground { (data, error) in
            cell.picImg.image = UIImage(data: data!)
        }
        
        //calculate post date
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
        
        // logic what to show: seconds, minuts, hours, days or weeks
        if difference.second! <= 0 {
            cell.dateLbl.text = "now"
        }
        if difference.second! > 0 && difference.minute! == 0 {
            cell.dateLbl.text = "\(difference.second!)s."
        }
        if difference.minute! > 0 && difference.hour! == 0 {
            cell.dateLbl.text = "\(difference.minute!)m."
        }
        if difference.hour! > 0 && difference.day! == 0 {
            cell.dateLbl.text = "\(difference.hour!)h."
        }
        if difference.day! > 0 && difference.weekOfMonth! == 0 {
            cell.dateLbl.text = "\(difference.day!)d."
        }
        if difference.weekOfMonth! > 0 {
            cell.dateLbl.text = "\(difference.weekOfMonth!)w."
        }
        
        //manipulate like button depending did user like it
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("by", equalTo: PFUser.current()?.username!)
        didLike.whereKey("to", equalTo: cell.uuidLbl.text!)
        didLike.countObjectsInBackground { (count, error) in
            //if no likes are found else found likes
            if count == 0 {
                cell.likeBtn.setTitle("unlike", for: UIControlState.normal)
                cell.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState.normal)
            }else{
                
                cell.likeBtn.setTitle("like", for: UIControlState.normal)
                cell.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState.normal)
                
            }
        }
        
        //count total likes of showing posts
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.uuidLbl.text!)
        countLikes.countObjectsInBackground { (count, error) in
            cell.likeLbl.text = "\(count)"
        }
        
        //assign index to use it in username button and comment button func
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.moreBtn.layer.setValue(indexPath, forKey: "index")
        
        //MARK:  @mention is tapped
        cell.descLbl.userHandleLinkTapHandler = {label, handle, range in
            
            //when clicked on mention tag name drop the mention symbol and send the tag name to the server
            var mention = handle
            mention = String(mention.characters.dropFirst())
            
            //if tapped on @CurrentUser go home
            if mention.lowercased() == PFUser.current()?.username{
                
                let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                self.navigationController?.pushViewController(home, animated: true)
                
                //else go to that guest home view controller
            }else{
                
                guestUsername.append(mention.lowercased())
                let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! GuestVC
                self.navigationController?.pushViewController(guest, animated: true)
                
            }
        }
        
        //MARK: #Hashtag is tapped
        cell.descLbl.hashtagLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercased())
            
            let hash = self.storyboard?.instantiateViewController(withIdentifier: "HashTagsVC") as! HashTagsVC
            self.navigationController?.pushViewController(hash, animated: true)
        }
        
        
        return cell
    }
    
    //click username button to take user to guest
    //MARK: - Username Button
    @IBAction func usernameBtn_Click(_ sender: Any) {
        
        //call index of button
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        //call cell to call furthur data
        let cell = tableView.cellForRow(at: i) as! PostsCell
        
        //if user taps on his name in the post then go home page else go guest
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username{
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            
            self.navigationController?.pushViewController(home, animated: true)
         
        }else{
            
            guestUsername.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    //clicked comment button
    @IBAction func commentBtn_Click(_ sender: Any) {
        
        //call index of button
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        //call cell to call furthur data
        let cell = tableView.cellForRow(at: i) as! PostsCell
        
        //send related data to global vairable in comment CommentVC
        commentuuid.append(cell.uuidLbl.text!)
        commentOwner.append(cell.usernameBtn.titleLabel!.text!)
        
        //go to comments present comment view controller
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        self.navigationController?.pushViewController(comment, animated: true)
        
    }
    
    //MARK: - More Button
    @IBAction func moreBtn_Click(_ sender: Any) {
        
        //call index of button. In order for any button to work inside a cell it must call the index witch is in the cell config
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        //call cell to call further data
        let cell = tableView.cellForRow(at: i) as! PostsCell
        
        //DELETE ACTION
        let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) { (UIAlertAction) in
            
            //MARK: STEP 1. Delete row from tableview
            self.usernameArray.remove(at: i.row)
            self.avaArray.remove(at: i.row)
            self.dateArray.remove(at: i.row)
            self.picArray.remove(at: i.row)
            self.titleArray.remove(at: i.row)
            self.uuidArray.remove(at: i.row)
            
            //MARK: STEP 2. Delete post from server
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: cell.uuidLbl.text!)
            postQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    
                    for object in objects!{
                        object.deleteInBackground(block: { (success, error) in
                            if success{
                                
                                //send notification to homeviewcontroller(root) to update shown posts
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)

                                
                                //push back to home(root) controller
                                self.navigationController?.popViewController(animated: true)
                            }else{
                                print(error?.localizedDescription ?? String())
                            }
                        })
                    }
                }else{
                    print(error?.localizedDescription ?? String())
                }
            })
            
            //MARK: STEP 3. Delete likes of post from server
            let likeQuery = PFQuery(className: "likes")
            likeQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            likeQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    
                    for object in objects!{
                        //each found object will be deleted eventualy(cant avoid this deletion)
                        object.deleteEventually()
                    }
                }
            })
            
            //MARK: STEP 4. Delete comments of post from server
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            commentQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    for object in objects!{
                        //each found object will be deleted eventualy(cant avoid this deletion)
                        object.deleteEventually()
                    }
                }
            })
            
            //MARK: STEP 5. Delete hashtags of post from server
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            hashtagQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    for object in objects!{
                        
                        object.deleteEventually()
                    }
                }
            })
            
            
        }
        
        //COMPLAIN ACTION
        let complain = UIAlertAction(title: "Complain", style: UIAlertActionStyle.default) { (UIAlertAction) in
            
            //send complain to server
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.current()?.username
            complainObj["to"] = cell.uuidLbl.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
            complainObj["post"] = cell.uuidLbl.text
            complainObj.saveInBackground(block: { (success, error) in
                if success{
                    self.alert(error: "Complain has been made successfuly" , message: "We will consider your complaint")
                }else{
                    self.alert(error: "ERROR", message: error!.localizedDescription)
                }
            })
        }
        
        //Cancel Action
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        //create menu controller
        let menu = UIAlertController(title: "Menu", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //if the current post user is the current user then allow delete and cancel action
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username{
            
            menu.addAction(delete)
            menu.addAction(cancel)
        }else{
            menu.addAction(complain)
            menu.addAction(cancel)
        }
        
        //show menu
        self.present(menu, animated: true, completion: nil)
        
        
    }
    
    //MARK: - Alert func
    func alert(error: String, message : String){
        
        let alert = UIAlertController(title: error, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    

  

}
