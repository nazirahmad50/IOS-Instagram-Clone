//
//  NavVC.swift
//  TrueInstagramApp
//
//  Created by Nazir Ahmad on 26/01/2018.
//  Copyright © 2018 Nazir. All rights reserved.
//

import UIKit

class NavVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Color of navigation bar title
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        //color of buttons in nvaigation controller
        self.navigationBar.tintColor = UIColor.white
        
        //color of background of navigation controller
        self.navigationBar.barTintColor = UIColor(displayP3Red: 18.0 / 255.0, green: 86.0 / 255.0, blue: 136.0 / 255.0, alpha: 1)
        
        //unable translucent
        self.navigationBar.isTranslucent = false

       
    }
    
    //white status bar for the phone features
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

 



}
