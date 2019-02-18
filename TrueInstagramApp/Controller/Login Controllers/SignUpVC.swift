//
//  SignUpVC.swift
//  TrueInstagramApp
//
//  Created by Nazir on 26/12/2017.
//  Copyright © 2017 Nazir. All rights reserved.
//

import UIKit
import Parse

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Storyboard Items
    //Profile Image
    @IBOutlet weak var avaterImage: UIImageView!
    
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPasswordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var fullNameTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextField!
    @IBOutlet weak var websiteTxt: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    //Reset default size
    var scrollHeight : CGFloat = 0
    //reset keyboard frame size
    var keyboard = CGRect()
    
    //MARK: - viewDidLoad method
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: adding background to this sign up view
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
        //MARK: Scrollview frame size
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width,height:self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollHeight = scrollView.frame.size.height
        
        //MARK: check notification if keyboard is shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideKeybaord), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //MARK: declare hide keybaord tapped
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //MARK: makes the avater image round
        avaterImage.layer.cornerRadius = avaterImage.frame.size.width / 2
        avaterImage.clipsToBounds = true
        
        signUpBtn.layer.cornerRadius = signUpBtn.frame.size.width / 20
        signUpBtn.clipsToBounds = true
        
        cancelBtn.layer.cornerRadius = cancelBtn.frame.size.width / 20
        cancelBtn.clipsToBounds = true
        
        //MARK: declare select image tap
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(self.loadImg))
        avaTap.numberOfTapsRequired = 1
        avaterImage.isUserInteractionEnabled = true
        avaterImage.addGestureRecognizer(avaTap)
        
        //alignment method
        storyboardAlignments()
        
    }
    //MARK: - Alignments for the storyboard
    func storyboardAlignments(){
        
        avaterImage.frame = CGRect(x: self.view.frame.size.width / 2 - 20, y: 40, width: 80, height: 80)
        
        userNameTxt.frame = CGRect(x: 10, y: avaterImage.frame.origin.y + 90, width: self.view.frame.size.width - 20, height: 30)
        passwordTxt.frame = CGRect(x: 10, y: userNameTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        repeatPasswordTxt.frame = CGRect(x: 10, y: passwordTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        
        emailTxt.frame = CGRect(x: 10, y: repeatPasswordTxt.frame.origin.y + 60, width: self.view.frame.size.width - 20, height: 30)
        fullNameTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        bioTxt.frame = CGRect(x: 10, y: fullNameTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        websiteTxt.frame = CGRect(x: 10, y: bioTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        
        signUpBtn.frame = CGRect(x: 20, y: websiteTxt.frame.origin.y + 50, width: self.view.frame.size.width / 4, height: 30)
        cancelBtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 20, y: signUpBtn.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        
        
    }
    
    //MARK: - Avater image methods
    // Call picker to select image
    @objc func loadImg(recognizer:UITapGestureRecognizer){
        
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = .photoLibrary
        imgPicker.allowsEditing = true
        present(imgPicker, animated: true, completion: nil)

    }
    
    //connect selected image to our imageview
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaterImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - ScrollView methods
    //hide keyboard if tapped
    @objc func hideKeyboardTap(recognizer:UITapGestureRecognizer){
        
        self.view.endEditing(true)
    }
    
    @objc func showKeyboard(notification:NSNotification){
        
        //define keybaord size
        keyboard = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        //move up UI
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.scrollHeight - self.keyboard.height
        }
        
        
    }
    
    @objc func hideKeybaord(notification:NSNotification){
        
        //move down UI
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.view.frame.height
        }
        
    }
    
    
    
    //MARK: - Sign Up Button Methods
    @IBAction func signUp_Click(_ sender: Any) {
        
        self.view.endEditing(true)
        
        //When fields are empty
        if (userNameTxt.text!.isEmpty || passwordTxt.text!.isEmpty || repeatPasswordTxt.text!.isEmpty || emailTxt.text!.isEmpty || fullNameTxt.text!.isEmpty || bioTxt.text!.isEmpty || websiteTxt.text!.isEmpty){
            
            //create a message dialog alert
            let alert = UIAlertController(title: "PLEASE", message: "Fill all the fields", preferredStyle: UIAlertControllerStyle.alert)
            let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okBtn)
            self.present(alert, animated: true, completion: nil)
            return
        }
        //
        if passwordTxt.text != repeatPasswordTxt.text{
            //create a message dialog alert
            let alert = UIAlertController(title: "PASSWORD", message: "Passwords do not match", preferredStyle: UIAlertControllerStyle.alert)
            let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okBtn)
            self.present(alert, animated: true, completion: nil)
            return
            
        }
        
        sendDataToServer()
 
    }
    
    //send storyboard fields data to server
    func sendDataToServer(){
        
        let user = PFUser()
        user.username = userNameTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user.password = passwordTxt.text
        user["fullname"] = userNameTxt.text?.lowercased()
        user["bio"] = bioTxt.text
        user["website"] = websiteTxt.text?.lowercased()
        //this data will be sent when the user edits his profile
        user["phonenumber"] = ""
        user["gender"] = ""
        
        let avaImgData = UIImageJPEGRepresentation(avaterImage.image!, 0)
        let convertedFile = PFFile(name: "avater.jpeg", data: avaImgData!)
        user["avaterimg"] = convertedFile
        
        //Save all that data in the server
        user.signUpInBackground { (success, error) in
            if success{
                print("Registered User")
                
                //remember loged user
                UserDefaults.standard.set(user.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                //call login method from AppDelegate class
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
                
            }else{
                //alert message pop for user
                let alert = UIAlertController(title: "ERROR", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okBtn)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
    
    
    
    
    
    //MARK: - Cancel Button Method
    @IBAction func cancelBtn_Click(_ sender: Any) {
        
        self.view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }
    

}
