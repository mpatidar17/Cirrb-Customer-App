//
//  SetForgotPasswordViewController.swift
//  cirrb app
//
//  Created by mac on 25/04/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class SetForgotPasswordViewController: BaseViewController {
    var appDel: AppDelegate! = (UIApplication.shared.delegate as! AppDelegate)
    
    @IBOutlet weak var lblSetEmail: UILabel!
    
    @IBOutlet weak var txtFieldSetCode: LoginTextField!
    @IBOutlet weak var txtFieldNewPassword: LoginTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDel.apiManager.setCurrentViewController(vc: self)
        
        self.navigationController?.isNavigationBarHidden = true
        
        lblSetEmail.text = UserDefaults.standard.object(forKey: "email") as? String
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func clickResetPassword(_ sender: Any) {
        let strCode = (txtFieldSetCode.text!.trimmingCharacters(in: .whitespaces))
        let strNewPassword = (txtFieldNewPassword.text!.trimmingCharacters(in: .whitespaces))
        
        if strCode.characters.count == 0 {
            self.ShowAlert("Code fiels can't be blank");
        }else if strNewPassword.characters.count == 0 {
            self.ShowAlert("New Password fiels can't be blank");
        }else{
            if isInternetAvailable() {
                let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                loadingNotification.label.text = "Loading"
                let email = UserDefaults.standard.object(forKey: "email") as? String
                resetPassword(code: strCode, email: email!, new_password: strNewPassword)
            }else {
                self.ShowAlert("Please check network connection");
            }
            
        }
    }
    
    private func resetPassword(code: String,email: String, new_password: String) {
        self.appDel.apiManager.setPassword(code: code, email: email, new_password: new_password, onComplete: {
            (details, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if details != nil{
                let detailDict = details as! NSDictionary
                let message = detailDict.value(forKey: "message") as! String
                
                let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                    
                    let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let desController = mainstoryboard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
                    
                    self.present(desController, animated: true, completion: nil)
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true)
            }
        })
    }

    @IBAction func clickCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
