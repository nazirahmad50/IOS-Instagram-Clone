//
//  NewsVC.swift
//  TrueInstagramApp
//
//  Created by Nazir Ahmad on 10/02/2018.
//  Copyright © 2018 Nazir. All rights reserved.
//

import UIKit
import Parse

class NewsVC: UITableViewController {
    
    //arrays to hold data from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var typeArray = [String]()
    var dateArray = [Date?]()
    var uuidArray = [String]()
    var OwnerArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dynamic cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        //title for the navigation bar
        self.navigationItem.title = "NOTIFICATIONS"
        
        //request notifications
        let query = PFQuery(className: "news")
        query.whereKey("to", equalTo: PFUser.current()!.username!)
        query.limit = 30
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (objects, error) in
            if error == nil{
                
                //clean up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.OwnerArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    
                    self.usernameArray.append(object.object(forKey: "by") as! String)
                    self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                    self.typeArray.append(object.object(forKey: "type") as! String)
                    self.dateArray.append(object.createdAt)
                    self.uuidArray.append(object.object(forKey: "uuid") as! String)
                    self.OwnerArray.append(object.object(forKey: "owner") as! String)
                    
                    
                    
                    //save notifications as checked (yes). This will not show old notification again after clicking on notification tabar
                    object["checked"] = "yes"
                    object.saveEventually()
                }
                
                self.tableView.reloadData()
            }
        }
        
    }

  

    
   
    //MARK: - Cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return usernameArray.count
    }
    
    //MARK: - Cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! NewsCell
        
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControlState.normal)
        
        avaArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
                
                cell.avaImg.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription ?? String())
            }
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
        
        //define info text
        if typeArray[indexPath.row] == "mention"{
            
            cell.infoLbl.text = "Has mentioned you."
        }
        if typeArray[indexPath.row] == "comment"{
            
            cell.infoLbl.text = "Has commented your post."
        }
        if typeArray[indexPath.row] == "follow"{
            
            cell.infoLbl.text = "Now following you."
        }
        if typeArray[indexPath.row] == "like"{
            
            cell.infoLbl.text = "Likes your post."
        }
        
        // asign index of button
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        
        
        return cell
    }
    
    
    
    //click username button to take user to guest
    //MARK: - Username Button
    @IBAction func usernameBtn_Click(_ sender: Any) {
        
        //call index of button
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        //call cell to call furthur data
        let cell = tableView.cellForRow(at: i) as! NewsCell
        
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
    
    
    //MARK: - didSelectRowAt
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // call cell for calling cell data
        let cell = tableView.cellForRow(at: indexPath) as! NewsCell
        
        //going to comments for @mention
        if cell.infoLbl.text == "Has mentioned you."{
            
            //send related data to global variable
            commentuuid.append(uuidArray[indexPath.row])
            commentOwner.append(OwnerArray[indexPath.row])
            
            let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
            self.navigationController?.pushViewController(comment, animated: true)
        }
        
        //going to comments for comments
        if cell.infoLbl.text == "Has commented your post."{
            
            //send related data to global variable
            commentuuid.append(uuidArray[indexPath.row])
            commentOwner.append(OwnerArray[indexPath.row])
            
            let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
            self.navigationController?.pushViewController(comment, animated: true)
            
        }
        
        //going to guest page who followed
        if cell.infoLbl.text == "Now following you."{
            
            //take guestname
            guestUsername.append(cell.usernameBtn.titleLabel!.text!)
            
            //go guest
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
            
        }
        
        //going to the liked post
        if cell.infoLbl.text == "Likes your post."{
            
            //take post uuid
            postuuid.append(uuidArray[indexPath.row])
            
            let post =   self.storyboard?.instantiateViewController(withIdentifier: "PostsVC") as! PostsVC
            self.navigationController?.pushViewController(post, animated: true)
            
        }
        
        
    }

    
 
}
