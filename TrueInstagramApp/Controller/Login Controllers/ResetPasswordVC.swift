//
//  ResetPasswordVC.swift
//  TrueInstagramApp
//
//  Created by Nazir on 26/12/2017.
//  Copyright © 2017 Nazir. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordVC: UIViewController {
    
    //MARK: - StoryBoard Items
    @IBOutlet weak var emailResetTxt: UITextField!
    
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //adding background image to reset password view
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
        //alignments for the reset password view items
        emailResetTxt.frame = CGRect(x: 10, y: 120, width: self.view.frame.size.width - 20, height: 30)
        resetBtn.frame = CGRect(x: 10, y: emailResetTxt.frame.origin.y + 50, width: self.view.frame.size.width / 4, height: 30)
        cancelBtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 20, y: resetBtn.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        
        resetBtn.layer.cornerRadius = resetBtn.frame.size.width / 20
        resetBtn.clipsToBounds = true
        
        cancelBtn.layer.cornerRadius = cancelBtn.frame.size.width / 20
        cancelBtn.clipsToBounds = true

       
    }
    
    //MARK: - Reset Button
    @IBAction func resetBtn_Click(_ sender: Any) {
        //hide keybaord
        self.view.endEditing(true)
        //if storyboard field is empty
        if emailResetTxt.text!.isEmpty{
            //show alert pop dialog
            let alert = UIAlertController(title: "PLEASE", message: "Fill all the fields", preferredStyle: UIAlertControllerStyle.alert)
            let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okBtn)
            present(alert, animated: true, completion: nil)
        }
        
        //sends a request for password reset to the users email
        
        PFUser.requestPasswordResetForEmail(inBackground: emailResetTxt.text!) { (success, error) in
            if success{
                //create a message dialog alert with action of dissmising the currect view controller
                let alert = UIAlertController(title: "Email for reseting password", message: "Reset password has been sent to your email", preferredStyle: UIAlertControllerStyle.alert)
                let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(okBtn)
                self.present(alert, animated: true, completion: nil)
                
            }else{
                print("not working sorry")
                print(error?.localizedDescription)
            }
        }
     
    }
   
    

    
    
    
    //MARK: - Cancel Button
    @IBAction func cancelBtn_Click(_ sender: Any) {
        
        self.view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }
    
   

}
