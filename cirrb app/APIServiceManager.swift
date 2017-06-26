//
//  APIServiceManager.swift
//  cirrb app
//
//  Created by mac on 27/04/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

typealias ServiceResponse = (Any?, NSError?) -> Void


class APIServiceManager: NSObject {
    var root_url: String!
    var authKey: String!
    var email: String!
    var session: SessionManager!
    var currentViewController: UIViewController?
    
    init(root_url: String!, vc: UIViewController?){
        self.root_url = root_url
        self.currentViewController = vc
        
    }
    
    func setCurrentViewController(vc: UIViewController?){
        self.currentViewController = vc
    }
    
    func login(email: String, password: String, device_token: String, onComplete: ServiceResponse?){
      
        let URL = root_url+Constant.Methods.LOGIN
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Content-Type"] = ("application/json")
        let configuration = URLSessionConfiguration.default
        // add the headers
        configuration.httpAdditionalHeaders = headers
        self.session = Alamofire.SessionManager(configuration: configuration)
        
        let params = [
            
            "email": email,
            "password": password,
            "device_type": "ios",
            "device_token": device_token,
            "remember":"true",
            "role":"customer"
        ]
        
        self.session.request(URL,
                             method: .post,
                             parameters: params
            ).responseJSON(completionHandler: {(response) in
                
               print("statusCode login is: ", response.result.isSuccess && ((response.response?.statusCode) != nil))
                
                if response.result.isSuccess && response.response?.statusCode == 200{
                    let details  = response.result.value!
                    let detailDict = details as! NSDictionary
                    
                    if detailDict["status"] != nil {
                        let status = detailDict.value(forKey: "status") as? String
                        if status == "fail" {
                            let message = detailDict.value(forKey: "message") as! String
                            
                            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) in
                            }))
                            self.currentViewController?.present(alert, animated: true, completion: nil)
                            onComplete!(nil,nil )
                        }else{
                            onComplete!(details,nil)
                        }
                    }else{
                        onComplete!(details,nil)
                    }
                }else{
                    
                }
            })
    }
    
    func register(email: String, password: String, device_token: String, lat: String, long: String, onComplete: ServiceResponse?){
        
        let URL = root_url+Constant.Methods.REGISTER
        
        let configuration = URLSessionConfiguration.default
        self.session = Alamofire.SessionManager(configuration: configuration)
        
        let params = [
            "email": email,
            "password": password,
            "password_confirmation": password,
            "device_type": "ios",
            "device_token": device_token,
            "lat":lat,
            "long":long,
            "role":"customer"
        ]
        
        print("params are: ",params)
        
        self.session.request(URL,
                             method: .post,
                             parameters: params
            ).responseJSON(completionHandler: {(response) in
                 debugPrint(response)
                if response.result.isSuccess && response.response?.statusCode == 200{
                    let details  = response.result.value!
                    let detailDict = details as! NSDictionary
                    print("Reg detailDict is: ",detailDict)
                    
                    if detailDict["status"] != nil {
                        
                         print("Reg detailDict inside nil status is: ",detailDict)
                         onComplete!(details,nil )
                    
                    }else if detailDict["email"] != nil {
                        print("Reg detailDict inside email is: ",detailDict)
                        let message = detailDict.value(forKey: "email") as! NSArray
                        let strMessage = message.object(at: 0) as! String
                        
                        let alert = UIAlertController(title: "Alert", message: strMessage, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) in
                        }))
                        self.currentViewController?.present(alert, animated: true, completion: nil)
                       onComplete!(nil,nil )
                    }else {
                        let alert = UIAlertController(title: "Alert", message: "Server not responding.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) in
                        }))
                        self.currentViewController?.present(alert, animated: true, completion: nil)
                        onComplete!(nil,nil )
                    }
                 }else{
                    
                 }
            })
    }
    
    
    func forgotPassword(email: String, onComplete: ServiceResponse?){
        
        let URL = root_url+Constant.Methods.FORGOT_PASSWORD
        
        let configuration = URLSessionConfiguration.default
        self.session = Alamofire.SessionManager(configuration: configuration)
        
        let params = [
            "email": email
        ]
        
        self.session.request(URL,
                             method: .post,
                             parameters: params
            ).responseJSON(completionHandler: {(response) in
                // debugPrint(response)
                if response.result.isSuccess && response.response?.statusCode == 200{
                    let details  = response.result.value!
                    let detailDict = details as! NSDictionary
                    if detailDict["status"] != nil {
                        let status = detailDict.value(forKey: "status") as! String
                        
                        if status == "fail" {
                            let message = detailDict.value(forKey: "message") as! String
                            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) in
                            }))
                            self.currentViewController?.present(alert, animated: true, completion: nil)
                            onComplete!(nil,nil )
                        }
                    }else{
                        onComplete!(details,nil )
                    }
                }else{
                    
                }
            })
    }
    
    func setPassword(code: String, email: String, new_password: String, onComplete: ServiceResponse?){
        
        let URL = root_url+Constant.Methods.SET_PASSWORD
        
        let configuration = URLSessionConfiguration.default
        self.session = Alamofire.SessionManager(configuration: configuration)
        
        
        let params = [
            "code": code,
            "email": email,
            "password": new_password,
            "password_confirmation": new_password
        ]
        
        self.session.request(URL,
                             method: .post,
                             parameters: params
            ).responseJSON(completionHandler: {(response) in
                // debugPrint(response)
                if response.result.isSuccess && response.response?.statusCode == 200{
                    let details  = response.result.value!
                    let detailDict = details as! NSDictionary
                    
                    if detailDict["status"] != nil {
                        let status = detailDict.value(forKey: "status") as! String
                        
                        if status == "success" {
                            
                            onComplete!(details , nil )
                            
                        }else if status == "fail" {
                            
                            let alert = UIAlertController(title: "Alert", message: "Code is invalid.", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) in
                                
                                
                            }))
                            self.currentViewController?.present(alert, animated: true, completion: nil)
                            onComplete!(nil,nil )
                            
                        }else {
                            let alert = UIAlertController(title: "Alert", message: "Server is not responding.", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) in
                                
                            
                            }))
                            self.currentViewController?.present(alert, animated: true, completion: nil)
                            onComplete!(nil,nil )
                        }
                    }else{
                        onComplete!(details,nil )
                    }
                }else{
                    
                }
            })
    }
    
    
    func getBranches(latitude: String, longitude: String, distance: String, onComplete: ServiceResponse?){
        
        let URL = root_url+"restaurants?action=api&lat=\(latitude)&long=\(longitude)&distance=\(distance)&user_id=\((UserDefaults.standard.object(forKey: Constant.User.USER_ID) as? String)!)"
        print("URL for rest is: ", URL)
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Content-Type"] = ("application/json")
        headers["Authorization"] = UserDefaults.standard.object(forKey: Constant.User.AUTH_TOKEN) as? String
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        self.session = Alamofire.SessionManager(configuration: configuration)
        
        self.session.request(URL,
                             method: .get,
                             parameters: nil
            ).responseJSON(completionHandler: {(response) in
                // debugPrint(response)
                if response.result.isSuccess && response.response?.statusCode == 200{
                    let details  = response.result.value!
                    onComplete!(details,nil )
                }else{
                    
                }
            })
    }
    
    
    func getBranchMenu(restaurantId: String, onComplete: ServiceResponse?){
        
        let URL = root_url+"menus?action=api&restaurant_id=\(restaurantId)&user_id=\((UserDefaults.standard.object(forKey: Constant.User.USER_ID) as? String)!)"
        print("URL for menu is: ", URL)
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Content-Type"] = ("application/json")
        headers["Authorization"] = UserDefaults.standard.object(forKey: Constant.User.AUTH_TOKEN) as? String
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        self.session = Alamofire.SessionManager(configuration: configuration)
        
        self.session.request(URL,
                             method: .get,
                             parameters: nil
            ).responseJSON(completionHandler: {(response) in
                debugPrint(response)
                if response.result.isSuccess && response.response?.statusCode == 200{
                    let details  = response.result.value!
                    
                    onComplete!(details,nil )
                }else{
                    
                }
            })
    }
    func setOrder(sub_total: String, delivery_fees: String, total: String, id: String, branch_id: String, resturent_id: String, quantity: String ,onComplete: ServiceResponse?){
        
       let URL = root_url + "setOrderNew"
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Content-Type"] = ("application/json")
        headers["Authorization"] = UserDefaults.standard.object(forKey: Constant.User.AUTH_TOKEN) as? String
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers

        self.session = Alamofire.SessionManager(configuration: configuration)
       
        let params = [
            "user_id" : (UserDefaults.standard.object(forKey: Constant.User.USER_ID) as? String)! ,
            "sub_total" : sub_total,
            "delivery_fees": delivery_fees,
            "total": total,
            "id": id,
            "branch_id": branch_id,
            "resturent_id": resturent_id,
            "quantity": quantity
        ] as [String : Any]
        
        print("params is: ", params)
        
        self.session.request(URL,
                             method: .post,
                             parameters: params
            ).responseJSON(completionHandler: {(response) in
                debugPrint(response)
                if response.result.isSuccess && response.response?.statusCode == 200{
                    let details  = response.result.value!
                    print("details is: ",details)
                    onComplete!(details,nil )
                }else{
                    
                }
            })

    }

    
    func getOrderList(onComplete: ServiceResponse?){
        
        let URL = root_url+"getOrder"
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Content-Type"] = ("application/json")
        headers["Authorization"] = UserDefaults.standard.object(forKey: Constant.User.AUTH_TOKEN) as? String
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        self.session = Alamofire.SessionManager(configuration: configuration)
        
        let params = [
            "user_id" : (UserDefaults.standard.object(forKey: Constant.User.USER_ID) as? String)!
            ] as [String : Any]
      //  print("params is>",params)
        
        self.session.request(URL,
                             method: .post,
                             parameters: params
            ).responseJSON(completionHandler: {(response) in
               // debugPrint(response)
                if response.result.isSuccess && response.response?.statusCode == 200{
                    let details  = response.result.value!
                    onComplete!(details,nil )
                }else{
                    onComplete!(nil,nil )
                   // print("Data Not Found")
                }
            })
    }
    
    func getUserBalanceDetails(onComplete: ServiceResponse?){
        
        let URL = root_url+"customerDetails?user_id=\((UserDefaults.standard.object(forKey: Constant.User.USER_ID) as? String)!)"
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Content-Type"] = ("application/json")
        headers["Authorization"] = UserDefaults.standard.object(forKey: Constant.User.AUTH_TOKEN) as? String
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        self.session = Alamofire.SessionManager(configuration: configuration)
        
        
        self.session.request(URL,
                             method: .get,
                             parameters: nil
            ).responseJSON(completionHandler: {(response) in
                if response.result.isSuccess && response.response?.statusCode == 200{
                    let details  = response.result.value!
                    onComplete!(details,nil )
                }else{
                    
                }
            })
    }
    
    
    func getAllOrderList(onComplete: ServiceResponse?){
        
        let URL = root_url+"getAllOrders"
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Content-Type"] = ("application/json")
        headers["Authorization"] = UserDefaults.standard.object(forKey: Constant.User.AUTH_TOKEN) as? String
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        self.session = Alamofire.SessionManager(configuration: configuration)
        
        let params = [
            "user_id" : (UserDefaults.standard.object(forKey: Constant.User.USER_ID) as? String)!
            ] as [String : Any]
        
        self.session.request(URL,
                             method: .post,
                             parameters: params
            ).responseJSON(completionHandler: {(response) in
                debugPrint(response)
                if response.result.isSuccess && response.response?.statusCode == 200{
                    let details  = response.result.value!
                    onComplete!(details,nil )
                }else{
                    
                }
            })
    }
    
    

    func updateProfile(onComplete: ServiceResponse?){
        
        let URL = root_url+"updateCustomer"
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Content-Type"] = ("application/json")
        headers["Authorization"] = UserDefaults.standard.object(forKey: Constant.User.AUTH_TOKEN) as? String
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        self.session = Alamofire.SessionManager(configuration: configuration)
        
        let params = [
            "user_id" : (UserDefaults.standard.object(forKey: Constant.User.USER_ID) as? String)!,
            "first_name" : (UserDefaults.standard.object(forKey: Constant.User.FIRST_NAME) as? String)!,
            "last_name" : (UserDefaults.standard.object(forKey: Constant.User.LAST_NAME) as? String)!,
            "phone" : (UserDefaults.standard.object(forKey: Constant.User.PHONE) as? String)!
            ] as [String : Any]
        
        self.session.request(URL,
                             method: .post,
                             parameters: params
            ).responseJSON(completionHandler: {(response) in
                debugPrint(response)
                if response.result.isSuccess && response.response?.statusCode == 200{
                    let details  = response.result.value!
                    onComplete!(details,nil)
                }else{
                    
                }
            })
    }

        func uploadImageAndData(data: UIImage, onComplete: ServiceResponse?){
            let url = root_url+"updateCustomer"
    
            var headers = Alamofire.SessionManager.defaultHTTPHeaders
            headers["Content-Type"] = ("application/json")
    
            let parameters = [
                "user_id": (UserDefaults.standard.object(forKey: Constant.User.USER_ID) as? String)!
            ]
            print("pick image UIImage: ",data)
    
            let currentTime = getCurrentMillis()
            print("currentTime is: ",currentTime)
    
            Alamofire.upload(multipartFormData: { (multipartFormData) in
    
                for (key, value) in parameters {
                    multipartFormData.append((UIImageJPEGRepresentation(data,1.0) as Data?)!, withName: "image", fileName: "\(currentTime).png", mimeType: "image/png")
                    multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                }
            }, to: url)
            { (result) in
                switch result {
                case .success(let upload, _, _):
    
                    upload.uploadProgress(closure: { (progress) in
                        print("progress is: ",progress)
                    })
    
                    upload.responseJSON { response in
                        print("response.result: ",response.result.value!)
                        onComplete!(response.result.value!,nil)
                    }
                    
                case .failure( _): break
                }
            }
            
        }
    
    
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    func updateCoordinate(user_id: String, lat: String, long: String, onComplete: ServiceResponse?){
        
        let URL = root_url+"update-coordinates"
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Content-Type"] = ("application/json")
       // headers["Authorization"] = UserDefaults.standard.object(forKey: Constant.User.AUTH_TOKEN) as? String
        
       // print("AUth Token is>>",UserDefaults.standard.object(forKey: Constant.User.AUTH_TOKEN)!)
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        self.session = Alamofire.SessionManager(configuration: configuration)
        
//        let params = [
//            "user_id" : user_id,
//            "lat" : lat,
//            "long" :long
//            ] as [String : Any]
//        
//        print("params",params)
        
        self.session.request(URL,
                             method: .post,
                             parameters: [
                        "user_id" : user_id,
                        "lat" : lat,
                        "long" :long
                        ]
            ).responseJSON(completionHandler: {(response) in
                
                print("statusCode update Coordinate is: ", response.result.isSuccess && ((response.response?.statusCode) != nil))
                
                debugPrint(response)

                if response.result.isSuccess && response.response?.statusCode == 200{
                    
                    let details  = response.result.value!
                    onComplete!(details,nil )
                }else{
                    onComplete!(nil,nil )
                }
            })

    }
    
    func updateDeviceToken(user_id: String, deviceToken: String, onComplete: ServiceResponse?){
        
        let URL = root_url+"update-devicetoken"
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Content-Type"] = ("application/json")
        headers["Authorization"] = UserDefaults.standard.object(forKey: Constant.User.AUTH_TOKEN) as? String
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        self.session = Alamofire.SessionManager(configuration: configuration)
        
        let params = [
            "user_id" : user_id,
            "device_token" : deviceToken,
            ] as [String : Any]
        
        self.session.request(URL,
                             method: .post,
                             parameters: params
            ).responseJSON(completionHandler: {(response) in
                if response.result.isSuccess && response.response?.statusCode == 200{
                    
                    let details  = response.result.value!
                    onComplete!(details,nil )
                }else{
                    onComplete!(nil,nil )
                }
            })
    }
    
    func logout(onComplete: ServiceResponse?){
        
        let URL = root_url+"logout?user_id=\((UserDefaults.standard.object(forKey: Constant.User.USER_ID) as? String)!)"
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Content-Type"] = ("application/json")
        headers["Authorization"] = UserDefaults.standard.object(forKey: Constant.User.AUTH_TOKEN) as? String
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        self.session = Alamofire.SessionManager(configuration: configuration)
        
        self.session.request(URL,
                             method: .get,
                             parameters: nil
            ).responseJSON(completionHandler: {(response) in
                debugPrint(response)
                if response.result.isSuccess && response.response?.statusCode == 200{
                    let details  = response.result.value!
                    onComplete!(details,nil )
                }else{
                    onComplete!(nil,nil )
                }
            })
    }
    func cancelOrder(user_id: String, order_id: String, onComplete: ServiceResponse?){
        
        let URL = root_url+"order-cancel"
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Content-Type"] = ("application/json")
        headers["Authorization"] = UserDefaults.standard.object(forKey: Constant.User.AUTH_TOKEN) as? String
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        self.session = Alamofire.SessionManager(configuration: configuration)
        
        let params = [
            "user_id" : user_id,
            "order_id" : order_id,
            ] as [String : Any]
        
        self.session.request(URL,
                             method: .post,
                             parameters: params
            ).responseJSON(completionHandler: {(response) in
                debugPrint(response)
                if response.result.isSuccess && response.response?.statusCode == 200{
                    let details  = response.result.value!
                    onComplete!(details,nil )
                }else{
                    onComplete!(nil,nil )
                }
            })
    }

    
}
