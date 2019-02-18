//
//  CommentVC.swift
//  TrueInstagramApp
//
//  Created by Nazir Ahmad on 27/01/2018.
//  Copyright © 2018 Nazir. All rights reserved.
//

import UIKit
import Parse

var commentuuid = [String]()
var commentOwner = [String]()

class CommentVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    var refresh = UIRefreshControl()
    
    //values for reseting user interface to default
    var tableViewHeight : CGFloat = 0
    var commentY : CGFloat = 0
    var commentHeight : CGFloat = 0
    
    //arrays to hold server data
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var commentArray = [String]()
    var dateArray = [Date?]()
    
    
    //keybaord frame
    var keyboard = CGRect()
    
    //page size
    var page : Int32 = 15
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.backgroundColor = UIColor.red
        
        //title for at the top bar
        self.navigationItem.title = "COMMENTS"
        
        //new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.back))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        // catch notification if the keyboard is shown or hidden
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //disable send button from the beginning
        sendBtn.isEnabled = false
        
        alignment()
        
        loadComments()
     
        
    }
    
    
    
    //MARK: - Back gestures
    @objc func back(sender : UIBarButtonItem){
        
        //push back
        self.navigationController?.popViewController(animated: true)
        
        //clean comment uuid from last holding information
        if !commentuuid.isEmpty{
            
            commentuuid.removeLast()
        }
        
        //clean comment owner from last holding information
        if !commentOwner.isEmpty{
            commentOwner.removeLast()
        }
        
    }
    
    //MARK: - keyboardWillShow
    //func loading when keybaord is shown
    @objc func keyboardWillShow(notification : NSNotification){
        
        //define keybaord frame size
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        //move UI up
        UIView.animate(withDuration: 0.4) {
            self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.commentTxt.frame.size.height + self.commentHeight
            self.commentTxt.frame.origin.y = self.commentY - self.keyboard.height - self.commentTxt.frame.size.height + self.commentHeight
            self.sendBtn.frame.origin.y = self.commentTxt.frame.origin.y
        }
        
    }
    
    //MARK: - keyboardWillHide
    //func loading when keybaord is hidden
    @objc func keyboardWillHide(notification : NSNotification){
        
        //move UI down
        UIView.animate(withDuration: 0.4) {
            self.tableView.frame.size.height = self.tableViewHeight
            self.commentTxt.frame.origin.y = self.commentY
            self.sendBtn.frame.origin.y = self.commentY
        }
        
    }
    
    //MARK: - Alignment/Delegates
    func alignment(){
        
        
        
        // alignnment
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height / 1.096 - self.navigationController!.navigationBar.frame.size.height - 20)
        tableView.estimatedRowHeight = width / 5.333
        tableView.rowHeight = UITableViewAutomaticDimension
        
        commentTxt.frame = CGRect(x: 10, y: tableView.frame.size.height + height / 56.8, width: width / 1.306, height: 33)
        commentTxt.layer.cornerRadius = commentTxt.frame.size.width / 50
        
        sendBtn.frame = CGRect(x: commentTxt.frame.origin.x + commentTxt.frame.size.width + width / 32, y: commentTxt.frame.origin.y, width: width - (commentTxt.frame.origin.x + commentTxt.frame.size.width) - (width / 32) * 2, height: commentTxt.frame.size.height)
        
        
        // delegates
        commentTxt.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        // assign reseting values
        tableViewHeight = tableView.frame.size.height
        commentHeight = commentTxt.frame.size.height
        commentY = commentTxt.frame.origin.y
        
    }
    
    //MARK: - Preload func
    override func viewWillAppear(_ animated: Bool) {
        //hide bottom bar
        self.tabBarController?.tabBar.isHidden = true
        
        //call keybaord
        commentTxt.becomeFirstResponder()
    }
    
    //MARK: - Postload func
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - textViewDidChange
    //while writing something in the comment text
    func textViewDidChange(_ textView: UITextView) {
        
        //disable button if no text entered in the coment textbox
        let spacing = CharacterSet.whitespacesAndNewlines
        
        //if the comment box has some text instead of only whitespace
        if !commentTxt.text.trimmingCharacters(in: spacing).isEmpty{
            sendBtn.isEnabled = true
        }else{
            sendBtn.isEnabled = false
        }
        
        // increase the height of the comment box if the text is more
        if textView.contentSize.height > textView.frame.size.height && textView.frame.height < 130{
            
            //find difference to add
            let difference = textView.contentSize.height - textView.frame.size.height
            
            //redefine frame of commenttxt
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            
            //move up tableview
            if textView.contentSize.height + keyboard.height + commentY >= tableView.frame.size.height{
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
            
        }
        
        //deleting lines decrease the comment box height
        else if textView.contentSize.height < textView.frame.size.height{
            
            //find difference to deduct
            let difference = textView.frame.size.height - textView.contentSize.height
            //redefine frame of commenttxt
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            //move tableview down
            if textView.contentSize.height + keyboard.height + commentY > tableView.frame.size.height{
                
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
    }
    
    //MARK: - TableView
    //MARK: numberOfSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    //MARK: Cell Height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: Cell Config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommentCell
        
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControlState.normal)
        cell.usernameBtn.sizeToFit()
        
        cell.commentLbl.text = commentArray[indexPath.row]
        
        
        avaArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
            cell.avaImg.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription ?? String())
            }
        
        }
        
        //calculate date
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
        
        if difference.second! <= 0{
            cell.dateLbl.text = "now"
        }
        if difference.second! > 0 && difference.minute! == 0{
            cell.dateLbl.text = "\(difference.second!)s."
        }
        
        if difference.minute! > 0 && difference.hour! == 0{
            cell.dateLbl.text = "\(difference.minute!)m."
        }
        
        if difference.hour! > 0 && difference.day! == 0{
            cell.dateLbl.text = "\(difference.hour!)s."
        }
        
        if difference.day! > 0 && difference.weekOfMonth! == 0{
            cell.dateLbl.text = "\(difference.day!)d."
        }
        
        if difference.weekOfMonth! > 0{
            cell.dateLbl.text = "\(difference.weekOfMonth!)w."
        }
        
        //MARK:  @mention is tapped
        cell.commentLbl.userHandleLinkTapHandler = {label, handle, range in
            
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
        cell.commentLbl.hashtagLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercased())
            
            let hash = self.storyboard?.instantiateViewController(withIdentifier: "HashTagsVC") as! HashTagsVC
            self.navigationController?.pushViewController(hash, animated: true)
        }
        
        //assign index to be used in the username button func
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")

        
        return cell
        
    }
    
    //MARK: - Load Comments func
    func loadComments(){
        
        //MARK: STEP 1. Count total comments in order to skip all except page size = 15
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground { (count, error) in
            if error == nil{
                //pagination if comments are more than 15 then swiping down will load more comments for the post
                if self.page < count {
                    self.refresh.addTarget(self, action: #selector(self.loadMore), for: UIControlEvents.valueChanged)
                    self.tableView.addSubview(self.refresh)
                }
                
                //MARK: STEP 2. Request last (page size 15 ) comments
                let query = PFQuery(className: "comments")
                query.whereKey("to", equalTo: commentuuid.last!)
                query.skip = count.distance(to: self.page)
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) in
                    if error == nil{
                        
                        //clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        //find related onjects
                        for object in objects!{
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.commentArray.append(object.object(forKey: "comment") as! String)
                            self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                            self.dateArray.append(object.createdAt)
                            self.tableView.reloadData()
                            
                            //scroll to bottom
                            self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)

                        }
                    }else{
                        print(error?.localizedDescription ?? String())
                    }
                })
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        
    }
    
    
    //MARK: - Pagination
    @objc func loadMore(){
        
        //MARK: STEP 1. Count total comments in order to skip all except page size = 15
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground { (count, error) in
            if error == nil{
                
                //self refresher
                self.refresh.endRefreshing()
                
                //remove refresher if loaded all comments
                if self.page >= count {
                    self.refresh.removeFromSuperview()
                }
                
                //MARK: STEP 2. load more comments
                if self.page < count {
                    //increase page size to load 30 as first paging
                    self.page = self.page + 15
                    
                    //request existing comments from server
                    let query = PFQuery(className: "comments")
                    query.whereKey("to", equalTo: commentuuid.last!)
                    query.skip = count.distance(to: self.page)
                    query.addAscendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) in
                        if error == nil{
                            
                            //clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            self.commentArray.removeAll(keepingCapacity: false)
                            self.dateArray.removeAll(keepingCapacity: false)
                            
                            //find related objects
                            
                            for object in objects!{
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                                self.commentArray.append(object.object(forKey: "comment") as! String)
                                self.dateArray.append(object.createdAt)
                                self.tableView.reloadData()
                            }
                            
                        }else{
                            print(error?.localizedDescription ?? String())
                        }
                    })
                }

            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        
    }
    
    //MARK: - Send Button
    @IBAction func sendBtn_Click(_ sender: Any) {
        
        //MARK: STEP 1. Add row in table view. This will show comments in the table before sending it to the server (less waiting time)
        usernameArray.append(PFUser.current()!.username!)
        avaArray.append(PFUser.current()?.object(forKey: "avaterimg") as! PFFile)
        dateArray.append(Date())
        
        //this also removes the empty spaces in the comments. When the comment is sent the empty spaces will be removed automaticaly
        commentArray.append(commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        tableView.reloadData()
        
        //MARK: STEP 2. Send comment to server
        let commentObject = PFObject(className: "comments")
        commentObject["to"] = commentuuid.last
        commentObject["username"] = PFUser.current()?.username
        commentObject["ava"] = PFUser.current()?.value(forKey: "avaterimg")
        commentObject["comment"] = commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        commentObject.saveEventually()
        
        //MARK: STEP 3. Send hashtag to server
        let words : [String] = commentTxt.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        //define tagged word
        for var word in words {
            
            //save hashtag in server
            if word.hasPrefix("#"){
                
                //cut symbols
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = commentuuid.last
                hashtagObj["by"] = PFUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = commentTxt.text
                hashtagObj.saveInBackground(block: { (success, error) in
                    if success{
                        print("hashtag \(word) is created")
                    }else{
                        print(error?.localizedDescription ?? String())
                    }
                })
            }
        }
        
        //MARK:  STEP 4. Send notifications as @mention (This is for NewsVC)
        var mentionCreated = Bool()
        for var word in words{
            
            //check @mentions for user
            if word.hasPrefix("@"){
                
                //cut symbols
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let newsObj = PFObject(className: "news")
                newsObj["by"] = PFUser.current()?.username
                newsObj["ava"] = PFUser.current()?.object(forKey: "avaterimg") as! PFFile
                newsObj["to"] = word
                newsObj["owner"] = commentOwner.last
                newsObj["uuid"] = commentuuid.last
                newsObj["type"] = "mention"
                newsObj["checked"] = "no"
                newsObj.saveEventually()
                mentionCreated = true
                
                
            }
        }
        
        //MARK: STEP 5. Send notification as comment
        
        //only if the post does not belong to current user
        if commentOwner.last != PFUser.current()?.username && mentionCreated == false{
            
            let newsObj = PFObject(className: "news")
            newsObj["by"] = PFUser.current()?.username
            newsObj["ava"] = PFUser.current()?.object(forKey: "avaterimg") as! PFFile
            newsObj["to"] = commentOwner.last
            newsObj["owner"] = commentOwner.last
            newsObj["uuid"] = commentuuid.last
            newsObj["type"] = "comment"
            newsObj["checked"] = "no"
            newsObj.saveEventually()
            
        }
        
        
    
        
        //scroll to bottom
        self.tableView.scrollToRow(at: IndexPath(item: commentArray.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
        
        //MARK: STEP 6. Reset UI
        sendBtn.isEnabled = false
        commentTxt.text = ""
        commentTxt.frame.size.height = commentHeight
        commentTxt.frame.origin.y = sendBtn.frame.origin.y
        
        tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.commentTxt.frame.size.height + self.commentHeight
        
    }
    
    //MARK: - Username Button
    @IBAction func usernameBtn_Click(_ sender: Any) {
        
        //call index of current button
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        //call cell to call furthure cell data
        let cell = tableView.cellForRow(at: i) as! CommentCell
        
        //if the current loged in user clicks on his his name in the posts comment then go to back to home page
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username{
            
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
            
            //else go to the guest home page
        }else{
            
            guestUsername.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    //MARK: - Editable Cell
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //MARK: - Swipe Cell fro action
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let cell = tableView.cellForRow(at: indexPath) as! CommentCell

        //MARK: STEP 1. delete comment from server

        //ACTION 1 to delete comment
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "    ") { (action, indexPath) in


            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: commentuuid.last!)
            commentQuery.whereKey("comment", equalTo: cell.commentLbl.text!)
            commentQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    //Find releated objects according to the 2 resctirction at the top (whereKey)
                    for object in objects!{
                        object.deleteEventually()
                    }
                }else{
                    print(error?.localizedDescription ?? String())
                }
            })
            
            //MARK: STEP 2. Delete hashtag from server
            let hashtagquery = PFQuery(className: "hashtags")
            hashtagquery.whereKey("to", equalTo: commentuuid.last!)
            hashtagquery.whereKey("by", equalTo: cell.usernameBtn.titleLabel!.text!)
            hashtagquery.whereKey("comment", equalTo: cell.commentLbl.text!)
            
            hashtagquery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    for object in objects!{
                        
                        object.deleteEventually()
                    }
                }else{
                    print(error?.localizedDescription ?? String())
                }
            })
            
            //MARK: STEP 3. Delete @mention comment notification 
            let newsQuery = PFQuery(className: "news")
            newsQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel!.text!)
            newsQuery.whereKey("to", equalTo: commentOwner.last!)
            newsQuery.whereKey("uuid", equalTo: commentuuid.last!)
            newsQuery.whereKey("type", containedIn: ["comment", "mention"])
            newsQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    
                    for object in objects!{
                        
                        object.deleteEventually()
                    }
                }
            })
            
            //close cell
            tableView.setEditing(false, animated: true)

            //MARK: STEP 3. delete comment row from tableView
            self.commentArray.remove(at: indexPath.row)
            self.dateArray.remove(at: indexPath.row)
            self.usernameArray.remove(at: indexPath.row)
            self.avaArray.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }

        //ACTION 2. Mention or address message to someone
        let address = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "    ") { (action, indexPath) in

            //include username in textview
            self.commentTxt.text = "\(self.commentTxt.text + "@" + self.usernameArray[indexPath.row] + " ")"

            self.sendBtn.isEnabled = true

            //close cell
            tableView.setEditing(false, animated: true)

        }
        
        //ACTION 3. Complain
        let complain = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "    ") { (action, indexPath) in
            
            //Send complain to server regarding selected comment
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.current()?.username
            complainObj["post"] = commentuuid.last
            complainObj["to"] = cell.commentLbl.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
            complainObj.saveInBackground(block: { (success, error) in
                if success {
                    self.alert(error: "Complain has been made successfuly" , message: "We will consider your complaint")
                }else{
                    self.alert(error: "ERROR", message: error!.localizedDescription)
                }
            })
            
            //close cell after complaint
            tableView.setEditing(false, animated: true)
            
        }
        
        //button background
        delete.backgroundColor = UIColor(patternImage: UIImage(named: "delete.png")!)
        address.backgroundColor = UIColor(patternImage: UIImage(named: "address.png")!)
        complain.backgroundColor = UIColor(patternImage: UIImage(named: "complain.png")!)
        
        //if Comment belongs to current user then he can delete or address
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username{
            return [delete, address]
        }
        
        //if Post belongs to current user then he can delete, address and complain about the comments
        else if commentOwner.last == PFUser.current()?.username{
            return [delete,address, complain]
        }
        
        //if Post belongs to another user not the current user
        else{
            return [address, complain]
        }


    }
    //MARK: - Alert func
    func alert(error: String, message : String){
        
        let alert = UIAlertController(title: error, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
    }
    

    

   

}
