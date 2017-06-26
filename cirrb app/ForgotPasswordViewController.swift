//
//  ForgotPasswordViewController.swift
//  cirrb app
//
//  Created by mac on 25/04/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class ForgotPasswordViewController: BaseViewController {
    var appDel: AppDelegate! = (UIApplication.shared.delegate as! AppDelegate)
    
    
    @IBOutlet weak var txtFieldEmail: LoginTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDel.apiManager.setCurrentViewController(vc: self)
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func clickResetPassword(_ sender: Any) {
        let strEmail = (txtFieldEmail.text!.trimmingCharacters(in: .whitespaces))
        
        if strEmail.characters.count == 0 {
            self.ShowAlert("Email fiels can't be blank");
        }else{
            if isInternetAvailable() {
                let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                loadingNotification.label.text = "Loading"
                forgotPassword(email: strEmail)
            }else {
                self.ShowAlert("Please check network connection");
            }
        }
    }
    
    private func forgotPassword(email: String) {
        self.appDel.apiManager.forgotPassword(email: email,  onComplete: {
            (details, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if details != nil{
                print("Login details is: ",details!)
                let detailDict = details as! NSDictionary
                let status = detailDict.value(forKey: "Status") as! String
                
                if status == "success" {
                    UserDefaults.standard.setValue(email, forKey: "email")
                    self.performSegue(withIdentifier: "ForgotPass_SetPass", sender: self)
                }
            }
        })
    }

    
    
    @IBAction func clickCacnel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
 

}
