//
//  registerViewController.swift
//  Cirrb app
//
//  Created by Rafet Khallaf on 4/22/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet var emailField: LoginTextField!
    @IBOutlet var passwordField: LoginTextField!
    @IBOutlet var confirmPasswordField: LoginTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.confirmPasswordField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.view.frame = CGRect(x: 0, y: -220, width: self.view.frame.width, height: self.view.frame.height)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        return (true)
    }
    
    @IBAction func registerBtn(_ sender: Any) {
        
        if(emailField.text == "" || passwordField.text == "" || confirmPasswordField.text == "" ) {
            DispatchQueue.main.async() {
                [unowned self] in
                
                let alert = UIAlertController(title: "Oops! :/", message: "You've missed some fields", preferredStyle: .alert)
                let OkAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(OkAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        else if ( passwordField.text != confirmPasswordField.text ) {
            DispatchQueue.main.async() {
                [unowned self] in
                
                let alert = UIAlertController(title: "Oops! :/", message: "Password and password confirmation don't match", preferredStyle: .alert)
                let OkAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(OkAction)
                self.present(alert, animated: true, completion: nil)
                
                self.passwordField.text = ""
                self.confirmPasswordField.text = ""
            }
        }
        else {
            
            let url = URL(string: "http://api.cirrb.com/?request=customers")
            var request = URLRequest(url: (url)! as URL)
            request.httpMethod = "post"
            
            let email = emailField.text!
            let password = passwordField.text!
            let paramString = "operation=register&email=\(email)&password=\(password)"
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            print(paramString)
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                do {
                    let requestResults = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                    
                    print(requestResults)
                    
                    if(requestResults["errors"] as! Int == 0) {
                        
                        DispatchQueue.main.async() {
                            [unowned self] in
                            self.performSegue(withIdentifier: "registerToConfirmRegistration", sender: self)
                        }
                        
                    }
                    else if (requestResults["errors"] as! Int == 2) {
                        DispatchQueue.main.async() {
                            [unowned self] in
                            
                            let alert = UIAlertController(title: "Email alread exists", message: "Use a different email address or try to reset your password", preferredStyle: .alert)
                            let OkAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                            alert.addAction(OkAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    else {
                        DispatchQueue.main.async() {
                            [unowned self] in
                            
                            
                            let alert = UIAlertController(title: "Error", message: "Wrong email or password!", preferredStyle: .alert)
                            let OkAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                            alert.addAction(OkAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                }
                catch {
                    print("Error")
                }
                
            }.resume()
        }
    }

}
