//
//  AppDelegate.swift
//  Cirrb app
//
//  Created by Rafet Khallaf on 3/19/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import UserNotifications
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var apiManager: APIServiceManager!
    var window: UIWindow?
    var strDeviceToken : String = ""
    var id: String = ""
    var deviceTokenStr: String = ""
    var notificationData = NSDictionary()
    var notificationInfoArray:[String] = []
    
    var flagLanguage = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.sharedManager().enable = true
        //GMSServices.provideAPIKey("AIzaSyBUfufNsKc3yWj9_6LNSZ6ODGznELr8m6w")
        GMSServices.provideAPIKey("AIzaSyCLH0TvLbEphHRJYkfpoyIzFmCA9-V_bCs")
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor(red:0.90, green:0.47, blue:0.36, alpha:1.0)
        UITextField.appearance().tintColor = .black
        self.apiManager = APIServiceManager(root_url: Constant.CommanURLs.SERVER_URL, vc: nil)

        // Override point for customization after application launch.
        
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        registerForRemoteNotification()

        let userId: String? = UserDefaults.standard.object(forKey: Constant.User.USER_ID) as? String
        if userId != nil{
            updateNotifications(userId: userId!)
        }else{
            print("API NOT CALLING")
        }
        return true
    }
    func updateNotifications(userId: String){
        
        let urlUpdateNotification: String = "http://api.cirrb.com/api/updateNotifications"
        
        let params = ["user_id": userId]
        
        print("userObject",params)
        
        Alamofire.request(urlUpdateNotification, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                print("response is: ",response)
                
                if response.result.isSuccess  && response.response?.statusCode == 200{
                    
                    print("Updated Notification" )
                }
                else{
                    print("Updated Notification Failed")
                }}
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let chars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var token = ""
        
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", arguments: [chars[i]])
        }
        print("Device Token = ", token)
        self.strDeviceToken = token
        
        UserDefaults.standard.set(self.strDeviceToken, forKey: "deviceTokenKey")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("Error = ",error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if application.applicationState == .background
        {
            notificationData = (userInfo["aps"] as AnyObject as? NSDictionary)!
            
            let notificationStr = ((notificationData.value(forKey: "alert") as AnyObject).value(forKey: "body")as AnyObject) as! String
            
            notificationInfoArray.append(notificationStr)
            
            //UserDefaults.standard.set(notificationInfoArray, forKey: "notificationInfo")
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationInfo"), object: notificationInfoArray)
            
            //print(notificationInfoArray)
            
        }
        else
        {
            notificationData = (userInfo["aps"] as AnyObject as? NSDictionary)!
            
            let notificationStr = ((notificationData.value(forKey: "alert") as AnyObject).value(forKey: "body")as AnyObject) as! String
            
            notificationInfoArray.append(notificationStr)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationInfo"), object: notificationInfoArray)
            
            //print(notificationInfoArray)
            
        }
    }
    
    // MARK: UNUserNotificationCenter Delegate // >= iOS 10
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User Info = ",notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info = ",response.notification.request.content.userInfo)
        completionHandler()
    }
    
    // MARK: Class Methods
    
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

}
