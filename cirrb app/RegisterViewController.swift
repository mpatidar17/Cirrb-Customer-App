//
//  RegisterViewController.swift
//  cirrb app
//
//  Created by mac on 25/04/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD
import GoogleMaps
import CoreLocation

class RegisterViewController: BaseViewController, CLLocationManagerDelegate {
     var appDel: AppDelegate! = (UIApplication.shared.delegate as! AppDelegate)
    
    @IBOutlet weak var txtFieldEmail: LoginTextField!
    @IBOutlet weak var txtFieldPassword: LoginTextField!
    @IBOutlet weak var txtFieldConfirmPassword: LoginTextField!
    
    let locationManager = CLLocationManager()
    var marker = GMSMarker()
    var geocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDel.apiManager.setCurrentViewController(vc: self)
        
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
        
        
        self.locationManager.delegate = self
        self.locationManager.distanceFilter  = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            locationManager.stopUpdatingLocation()
            UserDefaults.standard.setValue(String(location.coordinate.latitude), forKey: Constant.User.CURRENT_LATITUDE)
            UserDefaults.standard.setValue(String(location.coordinate.longitude), forKey: Constant.User.CURRENT_LONGITUDE)
            
        }
        
    }
    func coordinateReload(){
        
        let s_latitude = (UserDefaults.standard.object(forKey: Constant.User.CURRENT_LATITUDE) as? String)!
        print("s_latitude is :>",s_latitude)
        
        let s_longitude = (UserDefaults.standard.object(forKey: Constant.User.CURRENT_LONGITUDE) as? String)!
        print("s_longitude is :>",s_longitude)
       
    }
   
    @IBAction func clickRegister(_ sender: Any) {
        let strEmail = (txtFieldEmail.text!.trimmingCharacters(in: .whitespaces))
        let strPassword = (txtFieldPassword.text!.trimmingCharacters(in: .whitespaces))
        let strConfirmPassword = (txtFieldConfirmPassword.text!.trimmingCharacters(in: .whitespaces))
        let tokenStr: String? = UserDefaults.standard.object(forKey: "deviceTokenKey") as? String
        
        let s_latitude = (UserDefaults.standard.object(forKey: Constant.User.CURRENT_LATITUDE) as? String)!
        print("s_latitude is :>",s_latitude)
        
        let s_longitude = (UserDefaults.standard.object(forKey: Constant.User.CURRENT_LONGITUDE) as? String)!
        print("s_longitude is :>",s_longitude)


        
        if strEmail.characters.count == 0 {
            self.ShowAlert("Email fiels can't be blank");
        }else if strPassword.characters.count == 0{
            self.ShowAlert("Password fiels can't be blank");
        }else if strConfirmPassword.characters.count == 0{
            self.ShowAlert("Password not matched.");
        }else if strPassword != strConfirmPassword {
            self.ShowAlert("Password not matched.");
        }else{
            if isInternetAvailable() {
                let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                loadingNotification.label.text = "Loading"
                
                if tokenStr != nil{
                    
                    registerUser(email: strEmail, password: strPassword, device_token: tokenStr!, lat: s_latitude, long: s_longitude)
                }else{
                    
                    registerUser(email: strEmail, password: strPassword, device_token: "abcd", lat: s_latitude, long: s_longitude)
                }
            }else {
                self.ShowAlert("Please check network connection");
            }
        }
    }
    
    private func registerUser(email: String, password: String, device_token: String, lat: String, long: String) {
        self.appDel.apiManager.register(email: email, password: password, device_token: device_token, lat: lat, long: long, onComplete: {
            (details, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if details != nil {
                let detailDict = details as! NSDictionary
                let status = detailDict.value(forKey: "status") as! String
                
                if status == "success" {
                    self.performSegue(withIdentifier: "Reg_RegSucess", sender: self)
                }
            }
            
            

        })
    }

    @IBAction func clickCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
