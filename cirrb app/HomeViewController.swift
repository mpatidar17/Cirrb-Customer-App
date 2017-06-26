//
//  HomeViewController.swift
//  cirrb app
//
//  Created by mac on 26/04/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps
import MBProgressHUD
import Alamofire

class orderCell: UITableViewCell {
    @IBOutlet weak var lblOrderID: UILabel!
    @IBOutlet weak var lblOrderTotalAmt: UILabel!
    
    @IBOutlet weak var lblOrderWaiting: UILabel!
    
    var orderHistoryDict = NSDictionary()
    var partnerDetails = NSArray()
}

class HomeViewController: BaseViewController, CLLocationManagerDelegate, SWRevealViewControllerDelegate , UITableViewDelegate, UITableViewDataSource {
    
    var appDel: AppDelegate! = (UIApplication.shared.delegate as! AppDelegate)
    var orderList = NSArray()
    var orderListObject = NSDictionary()
    let locationManager = CLLocationManager()
    var marker = GMSMarker()
    var geocoder = CLGeocoder()
    var timer: Timer?
    
    var partnerDetailsDict = NSDictionary()
    var partnerDetails = NSArray()

    
    @IBOutlet weak var tblviewOrderLst: UITableView!
    
    @IBOutlet var gmapView: GMSMapView!
    
    @IBOutlet weak var lblCountOrder: UILabel!
    @IBOutlet weak var menuButton: defaultButton!
    
    @IBOutlet weak var lblCurrentOrder: UILabel!
    
    
    @IBOutlet weak var newOrderButton: defaultButton!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: "isLogin")
        
      //  let auth_token = UserDefaults.standard.object(forKey: Constant.User.AUTH_TOKEN) as? String
      //  print("auth_token",auth_token!)
        
        UINavigationBar.appearance().tintColor = UIColor.white
        
        menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
        
        self.revealViewController().delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.locationManager.delegate = self
        self.locationManager.distanceFilter  = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        self.gmapView.isMyLocationEnabled = true
        self.gmapView.settings.compassButton = true
        self.gmapView.settings.myLocationButton = false
        self.locationManager.startUpdatingLocation()
        
        if isInternetAvailable() {
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            
            if appDel.flagLanguage == 1{
            loadingNotification.label.text = "جار التحميل"
            }else{
            loadingNotification.label.text = "Loading"
            }
            getOrder()
            
        }else {
            self.ShowAlert("Please check network connection");
        }
        startTimer()
      //coordinateReload()
        
        
        let userId: String? = UserDefaults.standard.object(forKey: Constant.User.USER_ID) as? String
        if userId != nil{
            updateNotifications(userId: userId!)
        }else{
            print("API NOT CALLING")
        }
    }
    override func viewWillAppear( _ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        getOrder()
        
       // let userId: String = UserDefaults.standard.object(forKey: Constant.User.USER_ID) as! String
       // self.updateNotifications(userId: userId)

        if appDel.flagLanguage == 1{
            
            let path = Bundle.main.path(forResource: "ar-SA", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
            
            let btn = bundal.localizedString(forKey: "New Order", value: nil, table: nil)
            
            lblCurrentOrder.text = bundal.localizedString(forKey: "Current Orders", value: nil, table: nil)
            
            newOrderButton.setTitle(btn, for: .normal)
            
            let title = bundal.localizedString(forKey: "Home", value: nil, table: nil)
            
            navigationItem.title = title
            
        }else{
            
            let path = Bundle.main.path(forResource: "en", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
            
            let btn = bundal.localizedString(forKey: "New Order", value: nil, table: nil)
            
            lblCurrentOrder.text = bundal.localizedString(forKey: "Current Orders", value: nil, table: nil)
            
            newOrderButton.setTitle(btn, for: .normal)
            
            let title = bundal.localizedString(forKey: "Home", value: nil, table: nil)
            
            navigationItem.title = title
        }
        
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
    @IBAction func clickCurrentLocation(_ sender: Any) {
        
        let u_latitude = (UserDefaults.standard.object(forKey: Constant.User.CURRENT_LATITUDE) as? String)!
        
        let u_longitude = (UserDefaults.standard.object(forKey: Constant.User.CURRENT_LONGITUDE) as? String)!
        
        let coordinates = CLLocationCoordinate2DMake(Double(u_latitude)!, Double(u_longitude)!)
        
        gmapView.camera = GMSCameraPosition(target: coordinates , zoom: 15, bearing: 0, viewingAngle: 0)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func directionApi(source:String, destination:String) {
        
            let directionsUrlString: String = "https://maps.googleapis.com/maps/api/directions/json?&origin=\(source)&destination=\(destination)&mode=driving"
            
            let url = URL(string: directionsUrlString)
            
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                DispatchQueue.main.async(execute: {
                    self.extractData(data!)
                })
            })
            task.resume()
        }
    
    func extractData(_ directionData: Data) {
        
        let json = try? JSONSerialization.jsonObject(with: directionData, options: []) as! NSDictionary
        
        let routesArray: [AnyObject] = (json!["routes"] as! [AnyObject])
        var polyline: GMSPolyline? = nil
        if routesArray.count > 0 {
            let routeDict: [AnyHashable: Any] = routesArray[0] as! [AnyHashable: Any]
            var routeOverviewPolyline: [AnyHashable: Any] = (routeDict["overview_polyline"] as! [AnyHashable: Any])
            let points: String = (routeOverviewPolyline["points"] as! String)
            let path: GMSPath = GMSPath(fromEncodedPath: points)!
            polyline = GMSPolyline(path: path)
            polyline!.strokeWidth = 4.0
            polyline?.strokeColor = UIColor.blue
            polyline!.map = gmapView
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            gmapView.isMyLocationEnabled = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            gmapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            locationManager.stopUpdatingLocation()
            
//            let lat = location.coordinate.latitude
//            print("lat is",lat)
//            
//            let x = Double(round(1000*lat)/1000)
//            print("lat is x",x)
//            
//            let long = location.coordinate.longitude
//            print("long is",long)
//            
//            let y = Double(round(1000*long)/1000)
//            print("long is y",y)
            
//            UserDefaults.standard.setValue(String(x), forKey: Constant.User.CURRENT_LONGITUDE)

//            UserDefaults.standard.setValue(String(y), forKey: Constant.User.CURRENT_LONGITUDE)

            
            UserDefaults.standard.setValue(String(location.coordinate.latitude), forKey: Constant.User.CURRENT_LATITUDE)
            
            UserDefaults.standard.setValue(String(location.coordinate.longitude), forKey: Constant.User.CURRENT_LONGITUDE)
            
        }
        
    }
    
    @IBAction func clickNewOrder(_ sender: Any) {
        self.performSegue(withIdentifier: "Home_Branch", sender: self)
    }
    func creatMarker(_ coordinates: CLLocationCoordinate2D){
        marker.position = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        marker.map = gmapView
    }
    
    private func getOrder() {
        self.appDel.apiManager.getOrderList(onComplete: {
            (details, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if details != nil {
                let orderMenuDict = details as! NSDictionary
                let status = orderMenuDict.value(forKey: "status") as! String
                if status == "success"
                {
                    self.orderList = orderMenuDict.object(forKey: "orders") as! NSArray
                   // print("orderList is:> ",self.orderList)
                    let open_order = String(self.orderList.count)
                    
                    self.lblCountOrder.text = open_order + "/" + String(describing: UserDefaults.standard.object(forKey: Constant.User.ORDER_LIMIT) as! String)
                    
                    
                    for i in 0..<self.orderList.count {
         
                        self.partnerDetailsDict = (self.orderList.object(at: i) as AnyObject) as! NSDictionary
                        
                       // print("partnerDetailsDict is >>",self.partnerDetailsDict)
                        
                        self.partnerDetails =  (self.orderList.object(at: i) as AnyObject).value(forKey: "partner") as! NSArray
                        
                        
                       // print("partnerDetails",self.partnerDetails)

                        if (self.partnerDetails.count) > 0{
                        
                            
                            let driverFName:String? = (((self.partnerDetails.object(at: 0) as AnyObject).value(forKey: "name") as AnyObject) as? String)
                            
                            let driverLName:String? = (((self.partnerDetails.object(at: 0) as AnyObject).value(forKey: "last_name") as AnyObject) as? String)
                            
                            var driverFullName: String!
                            var FirstName = String()
                            var lastName = String()
                            
                            if driverFName != nil{
                                FirstName = driverFName!
                            }else{
                                FirstName = ""
                            }
                            
                            if driverLName != nil{
                                lastName = driverLName!
                            }else{
                                lastName = ""
                            }
                            
                            driverFullName = (FirstName + " " + lastName)
                            
                            print("driverFullName",driverFullName)
                            
                            if driverFullName == " "{
                                driverFullName = "empty"
                            }else{
                                driverFullName = (FirstName + " " + lastName)
                            }
                            
                            let partnerLat = (((self.partnerDetails.object(at: 0) as AnyObject).value(forKey: "lat") as AnyObject) as! Float)
                            
                            
                          //  print("orderLat is:>>",partnerLat)
                            
                            let partnerLong = (((self.partnerDetails.object(at: 0) as AnyObject).value(forKey: "long") as AnyObject) as! Float)
                            
                          //  print("orderLat is:>>",partnerLong)
                            
                            let latitude = (partnerLat as Float)
                            print("p_latitude is> ",latitude)
                            
                            let longitude = (partnerLong as Float)
                            print("p_longitude is> ",longitude)
                           
                            let marker = GMSMarker()
                            marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) , longitude: CLLocationDegrees(longitude))
                            
                            
                            marker.icon = GMSMarker.markerImage(with: UIColor(red:0.90, green:0.47, blue:0.36, alpha:1.0))

                            if driverFullName! == "empty"{
                            marker.title = "Driver's Name: " + "No Name"
                            }else{
                            marker.title = "Driver's Name: " + driverFullName!
                            }
                            let phoneNo = (((self.partnerDetails.object(at: 0) as AnyObject).value(forKey: "phone") as AnyObject) as! Int)
                            
                            if phoneNo == 0 {
                                marker.snippet = "Phone: " + "Not Available"
                            }else{
                                marker.snippet = "Phone: " + String(phoneNo)
                            }
    
                            marker.tracksInfoWindowChanges = true

                            marker.map = self.gmapView
                            
                            
                           // let s_latitude = UserDefaults.standard.object(forKey: Constant.User.CURRENT_LATITUDE) as! String
                            
                           // let s_longitude = UserDefaults.standard.object(forKey: Constant.User.CURRENT_LONGITUDE) as! String
//                            let branch :  NSArray = ((self.orderList.object(at: 0) as AnyObject).value(forKey: "branch") as AnyObject) as! NSArray
                            
               //             let b_lat = ((branch.object(at: 0) as AnyObject).value(forKey:"bl_lat") as AnyObject) as! Double
               //             let b_long = ((branch.object(at: 0) as AnyObject).value(forKey:"bl_long") as AnyObject) as! Double
                            
                            //print("s_latitude: ",s_latitude)
                            //print("s_longitude: ",s_longitude)
              //              print("b_lat: ",b_lat)
               //             print("b_long: ",b_long)
                            
                            
                         //   let source: String! = "\(s_latitude),\(s_longitude)"
                          //  let destination: String! = "\(latitude),\(longitude)"
                            
                           // self.directionApi(source: source, destination: destination)
                    
                             }
                    
                    }
                    

//                     String(((self.orderList.object(at: 0) as AnyObject).object(forKey: "branch")  as AnyObject) as! Int)
                    
                    self.tblviewOrderLst.reloadData()
                }else{
                    let message = orderMenuDict.value(forKey: "message") as! String
                    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
                        UserDefaults.standard.removeObject(forKey:"isLogin")
                        
                        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let desController = mainstoryboard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
                        self.present(desController, animated: true, completion: nil)
                    }));
                    alert.view.tintColor = UIColor.red
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
               print("Server Not Responding")
            }
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblviewOrderLst.dequeueReusableCell(withIdentifier: "orderHistoryCell", for: indexPath) as! orderCell
        
        cell.lblOrderID?.text = "#" + String(((orderList.object(at: indexPath.row) as AnyObject).value(forKey: "id") as AnyObject) as! Int)
        
        cell.lblOrderTotalAmt?.text = "SR " + String(((orderList.object(at: indexPath.row) as AnyObject).value(forKey: "total") as AnyObject) as! Float)
        
        let status = String(((orderList.object(at: indexPath.row) as AnyObject).value(forKey: "status") as AnyObject) as! String)
        
        if status == "process"{
            if appDel.flagLanguage == 1{
            cell.lblOrderWaiting.text = "...معالجة"
            }else{
            cell.lblOrderWaiting.text = "Processing..."
            }
        }else if status == "open"{
            if appDel.flagLanguage == 1{
            cell.lblOrderWaiting.text = "...انتظار"
            }else{
            cell.lblOrderWaiting.text = "Waiting..."
            }
        }
        cell.orderHistoryDict = (orderList.object(at: indexPath.row) as AnyObject) as! NSDictionary
        
        cell.partnerDetails = (self.orderList.object(at: indexPath.row) as AnyObject).value(forKey: "partner") as! NSArray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return orderList.count
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tblviewOrderLst.indexPathForSelectedRow;
        let currentCell = tblviewOrderLst.cellForRow(at: indexPath!) as! orderCell
        self.orderListObject = currentCell.orderHistoryDict
        self.partnerDetails = currentCell.partnerDetails
        currentCell.selectionStyle = .none
        self.performSegue(withIdentifier: "orderHistorySegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if (segue.identifier == "orderHistorySegue"){
            let selectedvc = segue.destination as! OrderHistoryViewController
            selectedvc.orderHistoryDict = self.orderListObject
            selectedvc.partnerDetails = self.partnerDetails
            }
    }
    func startTimer(){
        
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(updateUserCoordinates), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        timer?.invalidate()
    }
   /*
    func coordinateReload(){
        
        let userId = UserDefaults.standard.object(forKey: Constant.User.USER_ID) as! String
        
        let tokenStr: String? = UserDefaults.standard.object(forKey: "deviceTokenKey") as? String
        
        let s_latitude = (UserDefaults.standard.object(forKey: Constant.User.CURRENT_LATITUDE) as? String)!
        print("s_latitude is :>",s_latitude)
        
        let s_longitude = (UserDefaults.standard.object(forKey: Constant.User.CURRENT_LONGITUDE) as? String)!
        print("s_longitude is :>",s_longitude)
        
        updateCoordinate(user_id: userId, lat: s_latitude, long: s_longitude)
        
        if tokenStr != nil {
            self.updateDeviceToken(user_id: userId, deviceToken: tokenStr!)
        }
        
    }
    
    private func updateCoordinate(user_id: String, lat: String, long: String) {
        self.appDel.apiManager.updateCoordinate(user_id: user_id, lat: lat, long: long, onComplete: {
            (details, error) in
            if details != nil {
                let detailDict = details as! NSDictionary
                let status = detailDict.value(forKey: "status") as! String
                
                if status == "success" {
                    print("Coordinate is Updated")
                }
                else{
                    print("Not Updated")
                }
            }else{
                print("Nt Updated Yet")
            }
        })
    }*/
    private func updateDeviceToken(user_id: String, deviceToken: String) {
        self.appDel.apiManager.updateDeviceToken(user_id: user_id, deviceToken: deviceToken, onComplete: {
            (details, error) in
            if details != nil {
                let detailDict = details as! NSDictionary
                let status = detailDict.value(forKey: "status") as! String
                if status == "success" {
                    print("Device Token is Updated")
                }
                else{
                    print("Device Token is Not Updated")
                }
            }
        })
    }
    
    func updateUserCoordinates(){
        
        let urlUserCoordinates: String = "http://api.cirrb.com/api/update-coordinates"
        
        let s_latitude = (UserDefaults.standard.object(forKey: Constant.User.CURRENT_LATITUDE) as? String)!
        print("s_latitude is :>",s_latitude)
        
        let s_longitude = (UserDefaults.standard.object(forKey: Constant.User.CURRENT_LONGITUDE) as? String)!
        print("s_longitude is :>",s_longitude)
        
        let userId = UserDefaults.standard.object(forKey: Constant.User.USER_ID) as! String
        
        let tokenStr: String? = UserDefaults.standard.object(forKey: "deviceTokenKey") as? String
        
        if tokenStr != nil {
            self.updateDeviceToken(user_id: userId, deviceToken: tokenStr!)
        }
        let userObject = ["user_id": userId , "lat": s_latitude, "long": s_longitude]
        
        print("userObject",userObject)
        
        Alamofire.request(urlUserCoordinates, method: .post, parameters: userObject, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                print("response is: ",response)
                
                if response.result.isSuccess  && response.response?.statusCode == 200{
                    
                    print("Updated User Coordinates")
                }
                else{
                    
                    print("Not Updated User Coordinates")
                    
           }}
    }
    
//    func updateNotifications(userId: String){
//        
//        let urlUpdateNotification: String = "http://api.cirrb.com/api/updateNotifications"
//        
//        let params = ["user_id": userId]
//        
//        debugPrint(params)
//        
//        Alamofire.request(urlUpdateNotification, method: .post, parameters: params, encoding: JSONEncoding.default)
//            .responseJSON { response in
//                debugPrint(response)
//                if response.result.isSuccess  && response.response?.statusCode == 200{
//                    
//                    print("Updated Notification")
//                }
//                else{
//                    print("Updated Notification Failed")
//                }}
//    }


}
