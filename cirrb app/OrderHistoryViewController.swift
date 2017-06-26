//
//  OrderHistoryViewController.swift
//  cirrb app
//
//  Created by mac on 02/05/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit
import Kingfisher
import MBProgressHUD

class orderHistoryItemCell: UITableViewCell {
    @IBOutlet weak var lblMenuTitle: UILabel!
    @IBOutlet weak var lblMenuPrice: UILabel!
    @IBOutlet weak var lblMenuQuantity: UILabel!
    
}

class OrderHistoryViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tblViewOrderHistory: UITableView!
    
    var orderHistoryDict = NSDictionary()
    var orderHistoryLst = NSArray()
    var orderDetails = NSDictionary()
    var partnerDetails = NSArray()
    
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblGrandTotal: UILabel!
    @IBOutlet weak var lblDeliveryCharge: UILabel!
    
    
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverPhoneLabel: UILabel!
    @IBOutlet weak var driverEmailLabel: UILabel!
    @IBOutlet weak var driverImageView: UIImageView!
    
    @IBOutlet weak var driverInfoView: UIView!
    @IBOutlet weak var driverInfoViewHight: NSLayoutConstraint!
    
    @IBOutlet weak var lblDriverInfo: UILabel!
    
    @IBOutlet weak var lblOrderTotal: UILabel!
    @IBOutlet weak var lbldeliveryCharges: UILabel!
    @IBOutlet weak var lblgrandTotal: UILabel!
    
    @IBOutlet weak var lblTotalPayed: UILabel!
    
    @IBOutlet weak var lblpayedByYou: UILabel!
    
    
    @IBOutlet weak var lblorderStatus: UILabel!
    
    @IBOutlet weak var lblOrderStatus: UILabel!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var agentIdLabel: UILabel!
    
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var payedByYouLblHight: NSLayoutConstraint!
    
    
    @IBOutlet weak var cancelOrder: defaultButton!
    

    
    var appDel: AppDelegate! = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        UINavigationBar.appearance().tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.isNavigationBarHidden = false
        self.automaticallyAdjustsScrollViewInsets = false
     
            print("orderHistoryDict is>>>",orderHistoryDict)
   
        self.orderHistoryLst = orderHistoryDict.value(forKey: "order_list") as! NSArray
    
        if orderHistoryLst.count == 0{
        
            let alert = UIAlertController(title: "Alert", message: "Invalid Token", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
                UserDefaults.standard.removeObject(forKey:"isLogin")
                
                let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let desController = mainstoryboard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
                self.present(desController, animated: true, completion: nil)
            }));
            alert.view.tintColor = UIColor.red
            self.present(alert, animated: true, completion: nil)
        }else{
        self.lblTotalAmount.text = "SR " + String((orderHistoryDict.value(forKey: "sub_total") as AnyObject) as! Float)
        
        self.lblDeliveryCharge.text = "SR " + String((orderHistoryDict.value(forKey: "delivery_fees") as AnyObject) as! Float)
        
        self.lblGrandTotal.text = "SR " + String((orderHistoryDict.value(forKey: "total") as AnyObject) as! Float)
        
        let payedTotal = ((orderHistoryDict.value(forKey: "total") as AnyObject) as! Float) + ((orderHistoryDict.value(forKey: "remain_balance") as AnyObject) as! Float)
        
            lblTotalPayed.text = "SR " + String(payedTotal)
            
        let OrderStatus = ((orderHistoryDict.value(forKey: "status") as AnyObject) as! String)
    
            if OrderStatus == "open" || OrderStatus == "process"{
                lblTotalPayed.isHidden = true
                lblpayedByYou.isHidden = true
            }else if OrderStatus == "closed"{
                lblTotalPayed.isHidden = false
                lblpayedByYou.isHidden = false
                payedByYouLblHight.constant = 21
                cancelOrder.isHidden = true
            }else if OrderStatus == "incomplete"{
                lblTotalPayed.isHidden = true
                lblpayedByYou.isHidden = true
                payedByYouLblHight.constant = 21
                cancelOrder.isHidden = true
            }else if OrderStatus == "cancel"{
                lblTotalPayed.isHidden = true
                lblpayedByYou.isHidden = true
                payedByYouLblHight.constant = 21
                cancelOrder.isHidden = true
            }
        
        lblOrderStatus.text = OrderStatus
        }
        
        self.tblViewOrderHistory.separatorStyle = .none
        
        partnerDetails.adding("Hello")
        
        print("partnerDetails is::>>>>",self.partnerDetails)
        
        driverInformation()
        
       // driverInfoView.constant = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        if appDel.flagLanguage == 1{
            
            let path = Bundle.main.path(forResource: "ar-SA", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
            
            lblDriverInfo.text = bundal.localizedString(forKey: "Driver Details", value: nil, table: nil)
            
            lblOrderTotal.text = bundal.localizedString(forKey: "Order total:", value: nil, table: nil)
            
            lbldeliveryCharges.text = bundal.localizedString(forKey: "Delivery charges:", value: nil, table: nil)
            
            lblgrandTotal.text = bundal.localizedString(forKey: "Grand total:", value: nil, table: nil)
            
            lblpayedByYou.text = bundal.localizedString(forKey: "Paid by you", value: nil, table: nil)
            
            lblorderStatus.text = bundal.localizedString(forKey: "Order Status", value: nil, table: nil)
            
            nameLabel.text = bundal.localizedString(forKey: "Name", value: nil, table: nil)
            
            agentIdLabel.text = bundal.localizedString(forKey: "Agent Id", value: nil, table: nil)
            
            phoneLabel.text = bundal.localizedString(forKey: "Phone", value: nil, table: nil)
            
            let btn = bundal.localizedString(forKey: "Cancel Order", value: nil, table: nil)
            
            cancelOrder.setTitle(btn, for: .normal)
            
            let title = bundal.localizedString(forKey: "Order History", value: nil, table: nil)
            
            navigationItem.title = title
            
        }else{
            
            let path = Bundle.main.path(forResource: "en", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
            
            lblDriverInfo.text = bundal.localizedString(forKey: "Driver Details", value: nil, table: nil)
            
            lblOrderTotal.text = bundal.localizedString(forKey: "Order total:", value: nil, table: nil)
            
            lbldeliveryCharges.text = bundal.localizedString(forKey: "Delivery charges:", value: nil, table: nil)
            
            lblgrandTotal.text = bundal.localizedString(forKey: "Grand total:", value: nil, table: nil)
            
            lblpayedByYou.text = bundal.localizedString(forKey: "Paid by you", value: nil, table: nil)
            
            lblorderStatus.text = bundal.localizedString(forKey: "Order Status", value: nil, table: nil)
            
            nameLabel.text = bundal.localizedString(forKey: "Name", value: nil, table: nil)
            
            agentIdLabel.text = bundal.localizedString(forKey: "Agent Id", value: nil, table: nil)
            
            phoneLabel.text = bundal.localizedString(forKey: "Phone", value: nil, table: nil)
            
            let btn = bundal.localizedString(forKey: "Cancel Order", value: nil, table: nil)
            
            cancelOrder.setTitle(btn, for: .normal)
            
            let title = bundal.localizedString(forKey: "Order History", value: nil, table: nil)
            
            navigationItem.title = title
        }

    }
    
    func driverInformation(){
        
        if (self.partnerDetails.count) > 0{
            
            let driverFName:String? = (((self.partnerDetails.object(at: 0) as AnyObject).value(forKey: "name") as AnyObject) as? String)
            
            let driverLName:String? = (((self.partnerDetails.object(at: 0) as AnyObject).value(forKey: "last_name") as AnyObject) as? String)
            
            var driverFullName = String()
            
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
                
            driverFullName = FirstName + " " + lastName
            
            if driverFullName == " "{
                driverNameLabel.text = "No Name"
            }else{
                driverNameLabel.text = driverFullName
            }
            let phoneNo = (((self.partnerDetails.object(at: 0) as AnyObject).value(forKey: "phone") as AnyObject) as! Int)
            
            if phoneNo == 0 {
                driverPhoneLabel.text = "Not Available"
            }else{
            driverPhoneLabel.text = String(phoneNo)
            }
            
            driverEmailLabel.text = String(((self.partnerDetails.object(at: 0) as AnyObject).value(forKey: "id") as AnyObject) as! Int)
            
            let driverImage = (((self.partnerDetails.object(at: 0) as AnyObject).value(forKey: "image") as AnyObject) as! String)
            let url = URL(string: driverImage)
            driverImageView.kf.setImage(with: url)

            driverImageView.layer.cornerRadius = 42.5
            driverInfoView.isHidden = false
            driverImageView.layer.masksToBounds = true
            self.driverImageView.layer.borderWidth = 3
            self.driverImageView.layer.borderColor = UIColor(red:0.95, green:0.53, blue:0.42, alpha:1.0).cgColor
          //  driverInfoView.constant = 70

        }else{
            print("NO DATA FOUND")
            driverNameLabel.isHidden = true
            driverPhoneLabel.isHidden = true
         //   driverInfoView.constant = 0
            driverInfoView.isHidden = true
            driverInfoViewHight.constant = 0


        }
       
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblViewOrderHistory.dequeueReusableCell(withIdentifier: "orderHistoryItemCell", for: indexPath) as! orderHistoryItemCell
        
    
        cell.lblMenuTitle?.text = (((orderHistoryLst.object(at: indexPath.row) as AnyObject).value(forKey: "name") as AnyObject) as! String)
        
        cell.lblMenuPrice?.text = "SR " + String((((orderHistoryLst.object(at: indexPath.row) as AnyObject).value(forKey: "per_menu_cost") as AnyObject) as! Float))
        
        cell.lblMenuQuantity?.text = String((((orderHistoryLst.object(at: indexPath.row) as AnyObject).value(forKey: "quantity") as AnyObject) as! Int))
        
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! orderHistoryItemCell
        currentCell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return orderHistoryLst.count
    }
    private func cancelOrder(user_id: String, order_id: String) {
        
        self.appDel.apiManager.cancelOrder(user_id: user_id, order_id: order_id, onComplete: {
            (details, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if details != nil {
                let detailDict = details as! NSDictionary
                let status = detailDict.value(forKey: "status") as! String
                if status == "success" {
                    print("Order is Canceled")
                    self.lblOrderStatus.text = "Cancel"
                    self.cancelOrder.isHidden = true
                }
                else{
                    print("Order is Not Canceled")
                }
            }
        })
    }
    @IBAction func clickCancelOrder(_ sender: Any) {
        
         let userId = UserDefaults.standard.object(forKey: Constant.User.USER_ID) as! String
        let orderid = String(describing: orderHistoryDict.value(forKey: "id") as AnyObject)
        if appDel.flagLanguage == 1{
            
            let alert = UIAlertController(title: "محزر", message: "هل تريد بالتأكيد إلغاء الطلب؟", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "لا", style: UIAlertActionStyle.cancel, handler: nil));
            //event handler with closure
            alert.addAction(UIAlertAction(title: "نعم", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
                let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                loadingNotification.label.text = "جار التحميل"
               self.cancelOrder(user_id: userId, order_id: orderid)
            }));
            alert.view.tintColor = UIColor.red
            present(alert, animated: true, completion: nil)
        }else{

        let alert = UIAlertController(title: "Alert", message: "Are you sure want to cancel your order?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil));
        //event handler with closure
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.label.text = "Loading"
            self.cancelOrder(user_id: userId, order_id: orderid)
        }));
        alert.view.tintColor = UIColor.red
        present(alert, animated: true, completion: nil)
        }
    }

}
