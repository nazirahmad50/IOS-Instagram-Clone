//
//  TabBarVC.swift
//  TrueInstagramApp
//
//  Created by Nazir Ahmad on 26/01/2018.
//  Copyright © 2018 Nazir. All rights reserved.
//

import UIKit
import Parse

//global variables of icons
var icons = UIScrollView()
var corner = UIImageView()
var dot = UIView()

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //color of item
        self.tabBar.tintColor = UIColor.white
        
        //disable translucent
        self.tabBar.isTranslucent = false
        
        //custom tabbar button
        let itemWidth = self.view.frame.width / 5
        let itemHeight = self.tabBar.frame.size.height
        let button = UIButton(frame: CGRect(x: itemWidth * 2, y: self.view.frame.size.height - itemHeight, width: itemWidth - 10, height: itemHeight))
        button.setBackgroundImage(UIImage(named: "upload.png"), for: UIControlState.normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(self.upload), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button)
        
        //color of background
        self.tabBar.barTintColor = UIColor(displayP3Red: 37.0 / 255.0, green: 39.0 / 255.0, blue: 42.0 / 255.0, alpha: 1)
        
        //create total icons
        icons.frame = CGRect(x: self.view.frame.size.width / 5 * 3 + 10, y: self.view.frame.size.height - self.tabBar.frame.size.height * 2 - 3, width: 50, height: 35)
        self.view.addSubview(icons)
        
        //create corner
        corner.frame = CGRect(x: icons.frame.origin.x, y: icons.frame.origin.y + icons.frame.size.height, width: 20, height: 14)
        corner.center.x = icons.center.x
        corner.image = UIImage(named: "corner.png")
        corner.isHidden = true
        self.view.addSubview(corner)
        
        //create dot at the bottom of the notification tab icon
        dot.frame = CGRect(x: self.view.frame.size.width / 5 * 3, y: self.view.frame.size.height - 5, width: 7, height: 7)
        dot.center.x = self.view.frame.size.width / 5 * 3 + (self.view.frame.size.width / 5) / 2
        dot.backgroundColor = UIColor(displayP3Red: 251/255, green: 103/255, blue: 29/255, alpha: 1)
        dot.layer.cornerRadius = dot.frame.size.width / 2
        dot.isHidden = true
        self.view.addSubview(dot)
        
        //call function of all type notifications
        query(type: ["like"], image: UIImage(named: "likeicon.png")!)
        query(type: ["follow"], image: UIImage(named: "followicon.png")!)
        query(type: ["mention", "comment"], image: UIImage(named: "commenticon.png")!)
        
        //hide icons objects after 8 seconds of delya of opening the app
        UIView.animate(withDuration: 1, delay: 8, options: [], animations: {
            
            icons.alpha = 0
            corner.alpha = 0
            dot.alpha = 0
            
            
        }, completion: nil)
        
        
    }
    
    //MARK: - multiple query
    func query(type:[String], image:UIImage){
        
        let query = PFQuery(className: "news")
        query.whereKey("to", equalTo: PFUser.current()!.username!)
        query.whereKey("checked", equalTo: "no")
        query.whereKey("type", containedIn: type)
        query.countObjectsInBackground { (count, error) in
            if error == nil{
                
                if count > 0 {
                    self.placeIcon(image: image, text: "\(count)")
                }
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
    }
    
    //MARK: - multiple icons
    func placeIcon(image:UIImage, text:String){
        
        //create seperate icons
        let view = UIImageView(frame: CGRect(x: icons.contentSize.width, y: 0, width: 50, height: 35))
        view.image = image
        icons.addSubview(view)
        
        //create label to show digits
        let label = UILabel(frame: CGRect(x: view.frame.size.width / 2, y: 0, width: view.frame.size.width / 2, height: view.frame.size.height))
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        label.text = text
        label.textAlignment = .center
        label.textColor = UIColor.white
        view.addSubview(label)
        
        //update icons view frame
        icons.frame.size.width = icons.frame.size.width + view.frame.size.width - 4
        icons.contentSize.width = icons.contentSize.width + view.frame.size.width - 4
        icons.center.x = self.view.frame.size.width / 5 * 4 - (self.view.frame.size.width / 5) / 4
        
        //unhide elements
        corner.isHidden = false
        dot.isHidden = false
        
    }
    
    //MARK: - Upload Button
    @objc func upload(sender : UIButton){
        
        //go to the upload controler in the tabBar icons whitch is the second one
        self.selectedIndex = 2
        
        
    }


}
