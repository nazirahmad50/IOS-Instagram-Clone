//
//  UploadVC.swift
//  TrueInstagramApp
//
//  Created by Nazir on 18/01/2018.
//  Copyright © 2018 Nazir. All rights reserved.
//

import UIKit
import Parse

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var descText: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disable publishBtn
        publishBtn.isEnabled = false
        publishBtn.backgroundColor = UIColor.lightGray
        
        //hide remove button before user uploads an image
        removeBtn.isHidden = true
        picImg.image = UIImage(named: "BIMG")
        
        
        //Hide tap gesture
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboardTap))
        hideTap.numberOfTouchesRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //Select image tap gesture
        let picTap = UITapGestureRecognizer(target: self, action: #selector(self.loadImg))
        picTap.numberOfTouchesRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(picTap)
        
//        alignments()
        
    }
    
    func alignments(){
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        picImg.frame = CGRect(x: 15, y: 79, width: width / 4.5, height: width / 4.5)
        descText.frame = CGRect(x: picImg.frame.size.width + 25, y: picImg.frame.origin.y, width: width / 1.488, height: picImg.frame.size.height)
        publishBtn.frame = CGRect(x: 0, y: height / 1.17, width: width, height: width / 8)
        removeBtn.frame = CGRect(x: picImg.frame.origin.x, y: picImg.frame.origin.y + picImg.frame.size.height, width: picImg.frame.size.width, height: 20)
        
        
    }
    
    @objc func hideKeyboardTap(){
        self.view.endEditing(true)
        
    }
    
    @objc func loadImg(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
        
    }
    
    //MARK: - ImagePicker
    //hold selected image in picImg object and dismis once the user finished editing
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        //enable publish button
        publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(displayP3Red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        //unhide remove button
        removeBtn.isHidden = false
        
        //implement second tap on picImg
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(self.zoomImg))
        zoomTap.numberOfTouchesRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }
    
    @objc func zoomImg(){
        
        let zoomed = CGRect(x: 0, y: self.view.center.y - self.view.center.x - self.tabBarController!.tabBar.frame.size.height * 1.5, width: self.view.frame.size.width, height: self.view.frame.size.width)
        
        let unzoomed = CGRect(x: 15, y: 15, width: self.view.frame.size.width / 4.5, height: self.view.frame.size.width / 4.5)
        
        if picImg.frame == unzoomed{
            UIView.animate(withDuration: 0.3, animations: {
                self.picImg.frame = zoomed
                
                self.view.backgroundColor = UIColor.black
                self.descText.alpha = 0
                self.publishBtn.alpha = 0
                self.removeBtn.alpha = 0
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.picImg.frame = unzoomed
                
                self.view.backgroundColor = UIColor.white
                self.descText.alpha = 1
                self.publishBtn.alpha = 1
                self.removeBtn.alpha = 1
            })
        }
        
    }

    
    
    //MARK: - Published button
    //clicked published button
    @IBAction func publishBtn_Click(_ sender: Any) {
        //dissmis the keyboard
        self.view.endEditing(true)
        
        //send data to the server to the 'posts' class
        let object = PFObject(className: "posts")
        object["username"] = PFUser.current()!.username
        object["ava"] = PFUser.current()!.value(forKey: "avaterimg") as! PFFile
        
        let uuid = UUID().uuidString
        object["uuid"] = "\(PFUser.current()!.username!) \(uuid)"

        
        if descText.text.isEmpty{
            object["title"] = ""
            
        }else{
            object["title"] = descText.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        //send picture to the server after converting to FILE and compression
        let picData = UIImageJPEGRepresentation(picImg.image!, 0)
        let picFile = PFFile(name: "post.jpeg", data: picData!)
        object["pic"] = picFile
        
        // send #hashtag to server
        let words:[String] = descText.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        // define taged word
        for var word in words {
            
            // save #hasthag in server
            if word.hasPrefix("#") {
                
                // cut symbold
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = "\(PFUser.current()!.username!) \(uuid)"
                hashtagObj["by"] = PFUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = descText.text
                hashtagObj.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        print("hashtag \(word) is created")
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }
        
        //save information in server
        object.saveInBackground { (success, error) in
            if error == nil{
                
                //send notification with the name 'upload' to 'HomeVC'
                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                //switch to the first(0 index of tabar) viewController
                self.tabBarController?.selectedIndex = 0
                
                //call this func which means it will reset everything
                self.viewDidLoad()
                self.descText.text = ""
            }
        }
    }
    
    //MARK: - Remove Button
    @IBAction func removeBtn_Click(_ sender: Any) {
        self.viewDidLoad()
    }
    
    
    
}
