//
//  FollowersCell.swift
//  TrueInstagramApp
//
//  Created by Nazir on 31/12/2017.
//  Copyright © 2017 Nazir. All rights reserved.
//

import UIKit
import Parse

class FollowersCell: UITableViewCell {
    
    @IBOutlet weak var avaterImg: UIImageView!
    @IBOutlet weak var usernameTxt: UILabel!
    @IBOutlet weak var followingBtn: UIButton!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
       
        avaterImg.layer.cornerRadius = avaterImg.frame.size.width / 2
        avaterImg.clipsToBounds = true
        
        followingBtn.layer.cornerRadius = followingBtn.frame.size.width / 20
        followingBtn.clipsToBounds = true
        
        let width = UIScreen.main.bounds.width
        
        avaterImg.frame = CGRect(x: 10, y: 10, width: width / 5.3, height: width / 5.3)
        usernameTxt.frame = CGRect(x: avaterImg.frame.size.width + 20, y: 28, width: width / 3.2, height: 30)
        followingBtn.frame = CGRect(x: width - width / 3.5 - 10, y: 30, width: width / 3.5, height: 30)
        
        
        
    }

    @IBAction func followingBtn_Click(_ sender: Any) {
        
        let title = followingBtn.title(for: UIControlState.normal)
        //to follow user
        if title == "FOLLOW"{
            let addObject = PFObject(className: "follow")
            addObject["follower"] = PFUser.current()?.username
            addObject["following"] = usernameTxt.text
            addObject.saveInBackground(block: { (success, error) in
                if success{
                    self.followingBtn.setTitle("FOLLOWING", for: UIControlState.normal)
                    self.followingBtn.backgroundColor = UIColor.green
                }else{
                    print(error?.localizedDescription)
                }
            })
        
        }else{
            //to unfollow user
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.current()?.username!)
            query.whereKey("following", equalTo: usernameTxt.text!)
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    
                    for object in objects!{
                        object.deleteInBackground(block: { (success, error) in
                            if success{
                                self.followingBtn.setTitle("FOLLOW", for: UIControlState.normal)
                                self.followingBtn.backgroundColor = UIColor.lightGray
                            }else{
                                print(error?.localizedDescription)
                            }
                        })
                    }
                }else{
                    print(error?.localizedDescription)
                }
            })
        }
        
    }
    
    

}
