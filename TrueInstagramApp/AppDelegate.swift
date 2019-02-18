//
//  AppDelegate.swift
//  TrueInstagramApp
//
//  Created by Nazir on 26/12/2017.
//  Copyright © 2017 Nazir. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        let parseConfig = ParseClientConfiguration { (ParseMutableClientConfiguration) in
            
            //accessing Back4App app via id/key
            ParseMutableClientConfiguration.applicationId = "zeCpDlBiZ2qc6hVztXg7akfhzkCyUClEPf7m2Ngf"
            ParseMutableClientConfiguration.clientKey = "8QwRXFfdJy0jPrDpiWUHLZq1czOar4CBL5SYbMDA"
            ParseMutableClientConfiguration.server = "https://parseapi.back4app.com"
            
        }
        Parse.initialize(with: parseConfig)
        //call the login method in this class
        login()
        
        //color of windows espicialy for comment text and button
        window?.backgroundColor = UIColor.white
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func login (){
        
        //remembers users login
        let userName = UserDefaults.standard.string(forKey: "username")
        
        if userName != nil{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let myTapBar = storyBoard.instantiateViewController(withIdentifier: "tapBar")
            window?.rootViewController = myTapBar
        }
    }


}

