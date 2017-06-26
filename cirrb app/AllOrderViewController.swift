//
//  AllOrderViewController.swift
//  cirrb app
//
//  Created by mac on 10/05/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class allOrderCell: UITableViewCell {
    @IBOutlet weak var lblOrderID: UILabel!
    @IBOutlet weak var lblOrderTotalAmt: UILabel!
    @IBOutlet weak var lblOrderStatus: UILabel!

    var orderHistoryDict = NSDictionary()
    var partnerDetails = NSArray()

}

class AllOrderViewController: BaseViewController , UITableViewDelegate, UITableViewDataSource {
    
    var appDel: AppDelegate! = (UIApplication.shared.delegate as! AppDelegate)
    var orderList = NSArray()
    var orderListObject = NSDictionary()
    
    var partnerDetailsDict = NSDictionary()
    var partnerDetails = NSArray()
    
    @IBOutlet weak var tblviewOrderLst: UITableView!
    @IBOutlet weak var lblNoDataFound: UILabel!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDel.apiManager.setCurrentViewController(vc: self)
        UINavigationBar.appearance().tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = false
        
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.revealToggle(_:))
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tblviewOrderLst.separatorStyle = .none
        
        if isInternetAvailable() {
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            if appDel.flagLanguage == 1{
            loadingNotification.label.text = "جار التحميل"
            }else{
            loadingNotification.label.text = "Loading"
            }
            getAllOrderList()
        }else {
            self.ShowAlert("Please check network connection");
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if appDel.flagLanguage == 1{
            
            let path = Bundle.main.path(forResource: "ar-SA", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
            
            let title = bundal.localizedString(forKey: "Orders", value: nil, table: nil)
            
            navigationItem.title = title
            
            lblNoDataFound.text = bundal.localizedString(forKey: "Order is not available", value: nil, table: nil)

            
        }else{
            
            let path = Bundle.main.path(forResource: "en", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
            
            let title = bundal.localizedString(forKey: "Orders", value: nil, table: nil)
            
            navigationItem.title = title
            
            lblNoDataFound.text = bundal.localizedString(forKey: "Order is not available", value: nil, table: nil)
            
        }
        

    }
    
    private func getAllOrderList() {
        self.appDel.apiManager.getAllOrderList(onComplete: {
            (details, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if details != nil {
                let orderMenuDict = details as! NSDictionary
                let status = orderMenuDict.value(forKey: "status") as! String
                
                if status == "success"
                {
                    self.orderList = orderMenuDict.object(forKey: "orders") as! NSArray
                    print("self.orderList.count is: ", self.orderList.count)
                    
                    if self.orderList.count > 0 {
                        self.lblNoDataFound.isHidden = true
                        self.tblviewOrderLst.isHidden = false
                        self.tblviewOrderLst.reloadData()
                    }else {
                        self.tblviewOrderLst.isHidden = true
                        self.lblNoDataFound.isHidden = false
                    }
                    
                    for i in 0..<self.orderList.count {
                        
                        self.partnerDetailsDict = (self.orderList.object(at: i) as AnyObject) as! NSDictionary
                        
                        print("partnerDetailsDict is >>",self.partnerDetailsDict)
                        
                        self.partnerDetails =  (self.orderList.object(at: i) as AnyObject).value(forKey: "partner") as! NSArray
                        
                        
                        print("partnerDetails",self.partnerDetails)
                        
                        if (self.partnerDetails.count) > 0{
                        }
                    }
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
            }
        })
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblviewOrderLst.dequeueReusableCell(withIdentifier: "allOrderCell", for: indexPath) as! allOrderCell
        
        cell.lblOrderID?.text = "#" + String(((orderList.object(at: indexPath.row) as AnyObject).value(forKey: "id") as AnyObject) as! Int)
        
        cell.lblOrderTotalAmt?.text = "SR " + String(((orderList.object(at: indexPath.row) as AnyObject).value(forKey: "total") as AnyObject) as! Float)
        
        let status = String(((orderList.object(at: indexPath.row) as AnyObject).value(forKey: "status") as AnyObject) as! String)
        
        if status == "process"{
            if appDel.flagLanguage == 1{
                cell.lblOrderStatus.text = "...معالجة"
            }else{
                cell.lblOrderStatus.text = "Processing..."
            }
        }else if status == "open"{
            if appDel.flagLanguage == 1{
                cell.lblOrderStatus.text = "...انتظار"
            }else{
                cell.lblOrderStatus.text = "Waiting..."
            }
        }else if status == "closed"{
            if appDel.flagLanguage == 1{
                cell.lblOrderStatus.text = "...مغلق"
            }else{
                cell.lblOrderStatus.text = "Closed..."
            }
        }else if status == "incomplete"{
            if appDel.flagLanguage == 1{
                cell.lblOrderStatus.text = "...غير مكتمل"
            }else{
                cell.lblOrderStatus.text = "Incomplete..."
            }
        }else if status == "cancel"{
            if appDel.flagLanguage == 1{
                cell.lblOrderStatus.text = "...إلغاء"
            }else{
                cell.lblOrderStatus.text = "Cancel..."
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
        let currentCell = tblviewOrderLst.cellForRow(at: indexPath!) as! allOrderCell
        self.orderListObject = currentCell.orderHistoryDict
        self.partnerDetails = currentCell.partnerDetails
        currentCell.selectionStyle = .none
        self.performSegue(withIdentifier: "AllOrder_History", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "AllOrder_History") {
            let selectedvc = segue.destination as! OrderHistoryViewController
            selectedvc.orderHistoryDict = self.orderListObject
            selectedvc.partnerDetails = self.partnerDetails
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
