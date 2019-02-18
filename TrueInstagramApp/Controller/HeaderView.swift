//
//  HeaderView.swift
//  TrueInstagramApp
//
//  Created by Nazir on 30/12/2017.
//  Copyright © 2017 Nazir. All rights reserved.
//

import UIKit
import Parse

class HeaderView: UICollectionReusableView {
    
    @IBOutlet weak var avaterImg: UIImageView!
    @IBOutlet weak var fullnameTxt: UILabel!
    @IBOutlet weak var websiteTxt: UITextView!
    @IBOutlet weak var bioTxt: UILabel!
    
    @IBOutlet weak var postsTxt: UILabel!
    @IBOutlet weak var followersTxt: UILabel!
    @IBOutlet weak var followingsTxt: UILabel!
    
    @IBOutlet weak var postsTitleTxt: UILabel!
    @IBOutlet weak var followersTitleTxt: UILabel!
    @IBOutlet weak var followingTitleTxt: UILabel!
    
    @IBOutlet weak var editProfileBtn: UIButton!
    
    @IBOutlet weak var profileChangeBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        let width = UIScreen.main.bounds.width
        
        //round avaterimg
        avaterImg.layer.cornerRadius = avaterImg.frame.size.width / 2
        avaterImg.clipsToBounds = true
        
        //Alignments for the home page
        avaterImg.frame = CGRect(x: width / 16, y: width / 16, width: width / 4, height: width / 4)
        
        postsTxt.frame = CGRect(x: width / 2.5, y: avaterImg.frame.origin.y, width: 50, height: 30)
        followersTxt.frame = CGRect(x: width / 1.7, y: avaterImg.frame.origin.y, width: 50, height: 30)
        followingsTxt.frame = CGRect(x: width / 1.25, y: avaterImg.frame.origin.y, width: 50, height: 30)
        
        postsTitleTxt.center = CGPoint(x: postsTxt.center.x, y: postsTxt.center.y + 20)
        followersTitleTxt.center = CGPoint(x: followersTxt.center.x, y: followersTxt.center.y + 20)
        followingTitleTxt.center = CGPoint(x: followingsTxt.center.x, y: followingsTxt.center.y + 20)
        
        editProfileBtn.frame = CGRect(x: postsTitleTxt.frame.origin.x, y: postsTitleTxt.center.y + 20, width: width - postsTitleTxt.frame.origin.x - 10, height: 30)
        editProfileBtn.layer.cornerRadius = editProfileBtn.frame.size.width / 50
       
        
        fullnameTxt.frame = CGRect(x: avaterImg.frame.origin.x, y: avaterImg.frame.origin.y + avaterImg.frame.size.height, width: width - 30, height: 30)
        
        websiteTxt.frame = CGRect(x: avaterImg.frame.origin.x - 5, y: fullnameTxt.frame.origin.y + 15, width: width - 30, height: 30)
        
        bioTxt.frame = CGRect(x: avaterImg.frame.origin.x, y: websiteTxt.frame.origin.y + 30, width: width - 30, height: 30)
        bioTxt.sizeToFit()
        
        
        
    }
    
    
    
    @IBAction func followBtn_Click(_ sender: Any) {
        
        let title = editProfileBtn.title(for: UIControlState.normal)
        //to follow user
        if title == "FOLLOW"{
            let addObject = PFObject(className: "follow")
            addObject["follower"] = PFUser.current()?.username
            addObject["following"] = guestUsername.last!
            addObject.saveInBackground(block: { (success, error) in
                if success{
                    self.editProfileBtn.setTitle("FOLLOWING", for: UIControlState.normal)
                    self.editProfileBtn.backgroundColor = UIColor.green
                    
                    //Sned follow notification
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.current()?.username
                    newsObj["ava"] = PFUser.current()?.object(forKey: "avaterimg") as! PFFile
                    newsObj["to"] = guestUsername.last
                    newsObj["owner"] = ""
                    newsObj["uuid"] = ""
                    newsObj["type"] = "follow"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                    
                }else{
                    print(error?.localizedDescription)
                }
            })
            
        }else{
            //to unfollow user
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.current()?.username!)
            query.whereKey("following", equalTo: guestUsername.last!)
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    
                    for object in objects!{
                        object.deleteInBackground(block: { (success, error) in
                            if success{
                                self.editProfileBtn.setTitle("FOLLOW", for: UIControlState.normal)
                                self.editProfileBtn.backgroundColor = UIColor.lightGray
                                
                                //Delete follow notification
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                newsQuery.whereKey("to", equalTo: guestUsername.last!)
                                newsQuery.whereKey("type", equalTo: "follow")
                                newsQuery.findObjectsInBackground(block: { (objects, error) in
                                    if error == nil{
                                        
                                        for object in objects!{
                                            
                                            object.deleteEventually()
                                        }
                                    }
                                })
                                
                            }else{
                                print(error?.localizedDescription ?? String())
                            }
                        })
                    }
                }else{
                    print(error?.localizedDescription ?? String())
                }
            })
        }
    }
    
    
    
}
