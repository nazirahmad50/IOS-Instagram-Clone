//
//  EditProfileVC.swift
//  TrueInstagramApp
//
//  Created by Nazir on 03/01/2018.
//  Copyright © 2018 Nazir. All rights reserved.
//

import UIKit
import Parse

class EditProfileVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var avaterImg: UIImageView!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var websiteTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var genderTxt: UITextField!
    
    //MARK: - PickerView and PickerView data
    var genderPicker : UIPickerView!
    let genders = ["Male", "Female"]
    
    // value to hold keyboard frame size
    var keyboard = CGRect()
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: create Picker
        genderPicker = UIPickerView()
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker
        
        //check notification if keyboard is shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //MARK: declare hide keybaord tapped
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //MARK: declare select image tap
        let avaterTap = UITapGestureRecognizer(target: self, action: #selector(self.loadImg))
        avaterTap.numberOfTapsRequired = 1
        avaterImg.isUserInteractionEnabled = true
        avaterImg.addGestureRecognizer(avaterTap)
        
        
        
        alignments()
        
        information()

        
    }
   
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    //MARK: - ScrollView methods
    //hide keyboard if tapped
    @objc func keyboardWillShow(notification:Notification){
        
        keyboard = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = self.view.frame.size.height + self.keyboard.height / 2
        }
        
    }
    
    @objc func keyboardWillHide(notification:Notification){
        
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = 0
        }
    
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
        avaterImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Alignments
    func alignments(){
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        avaterImg.frame = CGRect(x: width - 68 - 10, y: 15, width: 68, height: 68)
        avaterImg.layer.cornerRadius = avaterImg.frame.size.width / 2
        avaterImg.clipsToBounds = true
        
        fullnameTxt.frame = CGRect(x: 10, y: avaterImg.frame.origin.y, width: width - avaterImg.frame.size.width - 30, height: 30)
        usernameTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 40, width: width - avaterImg.frame.size.width - 30, height: 30)
        websiteTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: width - 20, height: 30)
        bioTxt.frame = CGRect(x: 10, y: websiteTxt.frame.origin.y + 40, width: width - 20, height: 60)
        bioTxt.layer.borderWidth = 1
        bioTxt.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).cgColor
        bioTxt.layer.cornerRadius = bioTxt.frame.size.width / 50
        bioTxt.clipsToBounds = true
        
        titleLabel.frame = CGRect(x: 15, y: emailTxt.frame.origin.y - 30, width: width - 20, height: 30)
        emailTxt.frame = CGRect(x: 10, y: bioTxt.frame.origin.y + 100 , width: width - 20, height: 30)
        phoneNumberTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 40, width: width - 20, height: 30)
        genderTxt.frame = CGRect(x: 10, y: phoneNumberTxt.frame.origin.y + 40, width: width - 20, height: 30)
        
        
    }
    
    //MARK: - get data from server
    func information(){
        //recieve profile picture
        let avaImg = PFUser.current()?.object(forKey: "avaterimg") as! PFFile
        avaImg.getDataInBackground { (data, error) in
            if error == nil{
                self.avaterImg.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription)
            }
        }
        //retrieve user fields data
        usernameTxt.text = PFUser.current()?.username
        fullnameTxt.text = PFUser.current()?.object(forKey: "fullname") as? String
        bioTxt.text = PFUser.current()?.object(forKey: "bio") as? String
        websiteTxt.text = PFUser.current()?.object(forKey: "website") as? String
        
        emailTxt.text = PFUser.current()?.email
        phoneNumberTxt.text = PFUser.current()?.object(forKey: "phonenumber") as? String
        genderTxt.text = PFUser.current()?.object(forKey: "gender") as? String
        
        
        
    }
    //MARK: - Regex restriction for email txtfield
    func validateEmail(email:String) -> Bool{
        let regex = "[A-Z0-9a-z._%+-]{4}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true:false
        return result
    }
     //MARK: - Regex restriction for website txtfield
    func validateWebsite(web:String) -> Bool{
        let regex = "[A-Z0-9a-z._%+-]+.[A-Za-z]{2}"
        let range = web.range(of: regex, options: .regularExpression)
        let result = range != nil ? true:false
        return result
    }

    //MARK: - Cancel Button
    @IBAction func cancelBtn_Click(_ sender: Any) {
        
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: - AlertMessage
    func alertMessage(error : String , message : String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(okBtn)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Save Button
    @IBAction func saveBtn_Click(_ sender: Any) {
        //Check if email is correct
        if !validateEmail(email: emailTxt.text!){
            
            alertMessage(error: "Incorect Email", message: "Please provide valide email")
            //break out of function or if statement 
            return
        }
        //Check if website link is valide
        if !validateWebsite(web: websiteTxt.text!){
            
            alertMessage(error: "Incorect Website", message: "Please provide valide website link")
            return
        }
        
        getDataFromServer()
        
        
        
    }
    //MARK: - Get data from server
    func getDataFromServer(){
        
        //send data from edit profile to server
        let user = PFUser.current()!
        user.username = usernameTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user["fullname"] = fullnameTxt.text?.lowercased()
        user["website"] = websiteTxt.text?.lowercased()
        user["bio"] = bioTxt.text
        
        //if phone number is empty set it to empty in server
        if phoneNumberTxt.text!.isEmpty{
            user["phonenumber"] = ""
        }else{
            user["phonenumber"] = phoneNumberTxt.text
        }
        //if phone number is empty set it to empty in server
        if genderTxt.text!.isEmpty{
            user["gender"] = ""
        }else{
            user["gender"] = genderTxt.text
        }
        
        //send profile image to server
        let avaData = UIImageJPEGRepresentation(avaterImg.image!, 0)
        let avaFile = PFFile(name: "ava.jpeg", data: avaData!)
        user["avaterimg"] = avaFile
        
        //save file information in server
        user.saveInBackground { (success, error) in
            if success{
                
                self.view.endEditing(true)
                
                self.dismiss(animated: true, completion: nil)
                
                //instantly reload data in home view controller when save button is pressed
               NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
                
                
            }else{
                print(error?.localizedDescription)
            }
        }
        
    }
    
    //MARK: - PickerView Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //number of rows in pickerView
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    //titles in pickerView rows
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
      
    }
    //pickerView did select some value
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxt.text = genders[row]
        self.view.endEditing(true)
    }
  

}
