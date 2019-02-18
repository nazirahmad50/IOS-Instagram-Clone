//
//  SignInVC.swift
//  TrueInstagramApp
//
//  Created by Nazir on 26/12/2017.
//  Copyright © 2017 Nazir. All rights reserved.
//

import UIKit
import Parse

class SignInVC: UIViewController {
    
    //MARK: - StoryBoard items
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var forgotBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        //titleLabel.font = UIFont(name: "Pacifico.ttf", size: 25)
        
        
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
        //Alignments for the storyboard items
        titleLabel.frame = CGRect(x: 10, y: 80, width: self.view.frame.size.width - 20, height: 50)
        
        userNameTxt.frame = CGRect(x: 10, y: titleLabel.frame.origin.y + 70, width: self.view.frame.size.width - 20, height: 30)
        passwordTxt.frame = CGRect(x: 10, y: userNameTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        
        forgotBtn.frame = CGRect(x: 10, y: passwordTxt.frame.origin.y + 30, width: self.view.frame.size.width - 20, height: 30)
        signInBtn.frame = CGRect(x: 20, y: forgotBtn.frame.origin.y + 40, width: self.view.frame.size.width / 4, height: 30)
        signUpBtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 20, y: signInBtn.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        
        signInBtn.layer.cornerRadius = signInBtn.frame.size.width / 20
        signInBtn.clipsToBounds = true
        
        signUpBtn.layer.cornerRadius = signUpBtn.frame.size.width / 20
        signUpBtn.clipsToBounds = true
        
        //create tap gesture for hiding keybaord
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
    }
    //hide keyboard if tapped
    @objc func hideKeyboard(recognizer:UITapGestureRecognizer){
        
        self.view.endEditing(true)
        
    }
    
    
    //MARK: - Signin Button
    @IBAction func SignInBtn_Click(_ sender: Any) {
        //hides the keyboard when the user clicks on the sign in button
        self.view.endEditing(true)
        //if one of the storyboard fields is empty
        if userNameTxt.text!.isEmpty || passwordTxt.text!.isEmpty{
            //alert message pop for user
            let alert = UIAlertController(title: "PLEASE", message: "Fill all the fields", preferredStyle: UIAlertControllerStyle.alert)
            let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okBtn)
            present(alert, animated: true, completion: nil)
            
            
        }
        
        checkSignInDataInServer()
      
        
    }
    //checks the signin storyboard fields against the server data
    func checkSignInDataInServer(){
        
        PFUser.logInWithUsername(inBackground: userNameTxt.text!, password: passwordTxt.text!) { (user, error) in
            if error == nil{
                //remember the user login in the app memory, checks if the user login or not
                UserDefaults.standard.set(user?.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                //calls the login method from the appdelegate class
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
    
    
    


}
