//
//  LoginViewController.swift
//  cirrb app
//
//  Created by mac on 25/04/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: BaseViewController {
    
    
    var appDel: AppDelegate! = (UIApplication.shared.delegate as! AppDelegate)
    
    @IBOutlet weak var txtFieldPassword: LoginTextField!
    @IBOutlet weak var txtFieldEmail: LoginTextField!
    var currentViewController: UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDel.apiManager.setCurrentViewController(vc: self)
        self.navigationController?.isNavigationBarHidden = true
        
        let isLogin: Bool =  (UserDefaults.standard.object(forKey: "isLogin") != nil)
        
        
        if isLogin
        {
            
            let strEmail = UserDefaults.standard.object(forKey: Constant.User.SET_EMAIL) as! String
            let strPassword = UserDefaults.standard.object(forKey: Constant.User.SET_PASSWORD) as! String
            
//            let strDeviceToken = UserDefaults.standard.object(forKey: Constant.User.SET_DEVICE_TOKEN) as! String
//            print("strDeviceToken is: ",strDeviceToken)
            
            
               let tokenStr: String? = UserDefaults.standard.object(forKey: "deviceTokenKey") as? String
        
            txtFieldEmail.text = strEmail
            txtFieldPassword.text = strPassword
            
            if strEmail.characters.count == 0 {
                self.ShowAlert("Email fiels can't be blank");
            }else if !isValidEmail(strEmail: strEmail){
                ShowAlert("Email is incorrect.")
            }else if strPassword.characters.count == 0{
                self.ShowAlert("Password fiels can't be blank");
            }else{
                if isInternetAvailable() {
                    
                    if tokenStr != nil{
                        self.loginUser(email: strEmail,password: strPassword,device_token: tokenStr!)
                        
                        let lang: String? = (UserDefaults.standard.value(forKey: "Language") as AnyObject) as? String
                        
                        if lang == "true" {
                            appDel.flagLanguage = 1
                        }else{
                            appDel.flagLanguage = 0
                        }
                        
                    }else{
                        self.loginUser(email: strEmail,password: strPassword,device_token: "abcd")
                        let lang: String? = (UserDefaults.standard.value(forKey: "Language") as AnyObject) as? String
                        
                        if lang == "true" {
                            appDel.flagLanguage = 1
                        }else{
                            appDel.flagLanguage = 0
                        }

                    }
                }else {
                    self.ShowAlert("Please check network connection");
                }
                
            }
            
        }else{
            print("isLogin: false con", isLogin)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickLogin(_ sender: Any) {
        
        let strEmail = (txtFieldEmail.text!.trimmingCharacters(in: .whitespaces))
        let strPassword = (txtFieldPassword.text!.trimmingCharacters(in: .whitespaces))
        let tokenStr: String? = UserDefaults.standard.object(forKey: "deviceTokenKey") as? String

        if strEmail.characters.count == 0 {
            self.ShowAlert("Email fields can't be blank")
        }else if !isValidEmail(strEmail: strEmail){
                ShowAlert("Email is incorrect.")
        }else if strPassword.characters.count == 0{
            self.ShowAlert("Password fields can't be blank");
        }else{
            if isInternetAvailable() {
                 let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                 loadingNotification.label.text = "Loading"
                if tokenStr != nil{
                    self.loginUser(email: strEmail,password: strPassword,device_token: tokenStr!)
                }else{
                    self.loginUser(email: strEmail,password: strPassword,device_token: "abcd")
                }
            }else {
                self.ShowAlert("Please check network connection");
            }
           
        }

    }
    private func loginUser(email: String, password: String, device_token: String) {
        self.appDel.apiManager.login(email: email, password: password, device_token: device_token, onComplete: {
            (details, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if details != nil{
              //  print("Login details is: ",details!)
                let detailDict = details as! NSDictionary
                
                let auth_token = detailDict.value(forKey: "auth_token") as! String
            
                let f_name: String? = detailDict.value(forKey: "name") as? String
                let l_name: String? = detailDict.value(forKey: "last_name") as? String
                let email_user: String? = detailDict.value(forKey: "email") as? String
                let phone = detailDict.value(forKey: "phone") as? Int
                let image: String? = detailDict.value(forKey: "image") as? String
                
                let delivery_charges_per_km = detailDict.value(forKey: "delivery_charges_per_km") as! Float
                let minimum_delivery_charges = detailDict.value(forKey: "minimum_delivery_charges") as! Int
                let order_limit = detailDict.value(forKey: "order_limit") as! Int
                let user_id = detailDict.value(forKey: "id") as! Int
                
                UserDefaults.standard.setValue(email, forKey: Constant.User.SET_EMAIL)
                UserDefaults.standard.setValue(password, forKey: Constant.User.SET_PASSWORD)
                UserDefaults.standard.setValue(device_token, forKey: Constant.User.SET_DEVICE_TOKEN)
                
                if (auth_token.trimmingCharacters(in: .whitespaces)).characters.count != 0 {
                    UserDefaults.standard.setValue(String(user_id), forKey: Constant.User.USER_ID)
                    UserDefaults.standard.setValue(auth_token, forKey: Constant.User.AUTH_TOKEN)
                    
                    
                    UserDefaults.standard.setValue(f_name, forKey: Constant.User.FIRST_NAME)
                    UserDefaults.standard.setValue(l_name, forKey: Constant.User.LAST_NAME)
                    UserDefaults.standard.setValue(String(describing: phone!), forKey: Constant.User.PHONE)
                    UserDefaults.standard.setValue(email_user, forKey: Constant.User.EMAIL_USER)
                    UserDefaults.standard.setValue(image, forKey: Constant.User.IMAGE_PATH)
                    
                    
                    UserDefaults.standard.setValue(delivery_charges_per_km, forKey: Constant.User.DELIVERY_CHARGES_PER_KM)
                    UserDefaults.standard.setValue(minimum_delivery_charges, forKey: Constant.User.MINIMUM_DELIVERY_CHARGES)
                    
                    UserDefaults.standard.setValue(String(order_limit), forKey: Constant.User.ORDER_LIMIT)
                    self.performSegue(withIdentifier: "Login_Home", sender: self)
                }
            }
        })
    }

    @IBAction func clickRegister(_ sender: Any) {
        self.performSegue(withIdentifier: "Login_Register", sender: self)
    }
    @IBAction func clickForgotPassword(_ sender: Any) {
        self.performSegue(withIdentifier: "Login_ForgotPass", sender: self)
    }
    
    
}
