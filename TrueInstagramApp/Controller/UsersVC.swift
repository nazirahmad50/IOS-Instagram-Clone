//
//  UsersVC.swift
//  TrueInstagramApp
//
//  Created by Nazir Ahmad on 09/02/2018.
//  Copyright © 2018 Nazir. All rights reserved.
//

import UIKit
import Parse

class UsersVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //declare searchBar
    var searchBar = UISearchBar()
    
    //tableView arrays to hold server data
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    //collectionView UI
    var collectionView : UICollectionView!
    
    //collectionView arrays to hold server data
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var page : Int = 15
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        //implement SearchBar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.size.width - 34
        
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        
        loadUsers()
        
        collectionViewLaunch()
        
        
    }
    
    //MARK: - SEARCHBAR CODE
    
    //MARK: - Load Users
    func loadUsers(){
        
        let usersQuery = PFQuery(className: "_User")
        usersQuery.addDescendingOrder("createdAt")
        usersQuery.limit = 20
        usersQuery.findObjectsInBackground { (objects, error) in
            if error == nil{
                
                //clean up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.usernameArray.append(object.object(forKey: "username") as! String)
                    self.avaArray.append(object.object(forKey: "avaterimg") as! PFFile)
                }
                
                self.tableView.reloadData()
                
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
    }
    
    //MARK: -Search Updated
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let usernameQuery = PFQuery(className: "_User")
        //you can find the user without typing their full name or if its uper or lower cap
        usernameQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        usernameQuery.findObjectsInBackground { (objects, error) in
            if error == nil{
                
                //be able to search by fullname
                //if no objecs are found according to entered text in username column then find by fullname
                if objects!.isEmpty{
                    
                    let fullnameQuery = PFQuery(className: "_User")
                    fullnameQuery.whereKey("fullname", matchesRegex: "(?i)" + searchBar.text!)
                    fullnameQuery.findObjectsInBackground(block: { (objects, error) in
                        if error == nil{
                            
                            //clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            
                            for object in objects!{
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.avaArray.append(object.object(forKey: "avaterimg") as! PFFile)
                            }
                            
                            self.tableView.reloadData()
                        }else{
                            print(error?.localizedDescription ?? String())
                        }
                    })
                    
                }
                
                //continue username search
                //clean up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.usernameArray.append(object.object(forKey: "username") as! String)
                    self.avaArray.append(object.object(forKey: "avaterimg") as! PFFile)
                }
                
                self.tableView.reloadData()
                
                
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        
        return true
    }
    
    //MARK: - searchBarTextDidBeginEditing
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        //hide collectionView when started to search
        collectionView.isHidden = true
        
        //if text is entered into the searchbar enable search button
        searchBar.showsCancelButton = true
        
    }
    
    //MARK: - Cancel Button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        //unhide collectionView when tapped cancel button
        collectionView.isHidden = false
        
        //dissmis keybaord
        searchBar.resignFirstResponder()
        
        //hide cancel button after clicked on search button
        searchBar.showsCancelButton = false
        
        //reset text
        searchBar.text = ""
        
        //reset shown users
        loadUsers()
        
    }
    
   

   
    //MARK: - TABLEVIEW CODE
    // MARK: - Cell num
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return usernameArray.count
    }
    
    //MARK: - Cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.view.frame.size.width / 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FollowersCell
        
        //hide follow button
        cell.followingBtn.isHidden = true
        
        //connect cells object with recieved information from server
        cell.usernameTxt.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
                cell.avaterImg.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        

        return cell
    }
    
    //MARK: - DidSelectRowAt indexpath
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //this already has indexpath in the func
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        
        //if user taps his own account go to his home page
        if cell.usernameTxt.text! == PFUser.current()?.username{
            
            let home = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            
            self.navigationController?.pushViewController(home, animated: true)
            
            //else if curent user taps another user go to their home page
        }else{
            
            guestUsername.append(cell.usernameTxt.text!)
            let guest = storyboard?.instantiateViewController(withIdentifier: "guestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
            
        }
        
        
    }
    
    //MARK: - COLLECTION VIEW CODE
    //MARK: - collectionView Launch
    func collectionViewLaunch(){
        
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        //have 3 pic on each line
        layout.itemSize = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        
        //direction of scrolling
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        //define frame of collectionView
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.navigationController!.navigationBar.frame.size.height - 20)
        
        //declare collectionView
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        //delegates
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        
        self.view.addSubview(collectionView)
        
        //define cell for collectionView
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        
        
        
        loadPosts()
        
        
        
    }
    
    //MARK: - Cell line spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    //MARK: - Cell inter spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    //MARK: - Cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        //create pic image view to show loaded pictures
        let picImg = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        cell.addSubview(picImg)
        
        picArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
                
                picImg.image = UIImage(data: data!)
                
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        
        return cell
    }
    
    //MARK: - didSelectItem
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //take relevant unique id of the post to load post in post view controller
        postuuid.append(uuidArray[indexPath.row])
        
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PostsVC") as! PostsVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    //MARK: - LoadPosts
    func loadPosts(){
        
        let query = PFQuery(className: "posts")
        query.limit = page
        query.findObjectsInBackground { (objects, error) in
            if error == nil{
                
                //clean up
                self.picArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    
                    self.picArray.append(object.object(forKey: "pic") as! PFFile)
                    self.uuidArray.append(object.object(forKey: "uuid") as! String)
                }
                
                self.collectionView.reloadData()
                
            }else{
                print(error?.localizedDescription ?? String())
            }
        }
        
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //scroll down for paging
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6{
            self.loadMore()
        }
    }
    
    //MARK: - Pagination
    func loadMore(){
        
        //if more posts are unloaded we want to load it then
        if page <= picArray.count{
            
            page = page + 15
            
            //load additional posts
            let query = PFQuery(className: "posts")
            query.limit = page
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    
                    //clean up
                    self.picArray.removeAll(keepingCapacity: false)
                    self.uuidArray.removeAll(keepingCapacity: false)
                    
                    for object in objects!{
                        self.picArray.append(object.object(forKey: "pic") as! PFFile)
                        self.uuidArray.append(object.object(forKey: "uuid") as! String)
                    }
                    
                    self.collectionView.reloadData()
                    
                }else{
                    print(error?.localizedDescription ?? String())
                }
            })
        }
        
    }
    
    
    

    

}
