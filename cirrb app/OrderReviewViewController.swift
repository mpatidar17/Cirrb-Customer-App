//
//  OrderReviewViewController.swift
//  cirrb app
//
//  Created by mac on 28/04/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit
import Kingfisher
import MBProgressHUD

class reviewItemCell: UITableViewCell {
    @IBOutlet weak var lblMenuTitle: UILabel!
    @IBOutlet weak var lblMenuPrice: UILabel!
    @IBOutlet weak var lblMenuQuantity: UILabel!
}

class OrderReviewViewController: BaseViewController , UITableViewDelegate , UITableViewDataSource{
    var appDel: AppDelegate! = (UIApplication.shared.delegate as! AppDelegate)
    @IBOutlet weak var tblViewReviewOrder: UITableView!
    var selectedMenuItemArray = NSMutableArray()
    
    @IBOutlet weak var lblTotalAmount: UILabel!
    
    @IBOutlet weak var lblGrandTotal: UILabel!
    @IBOutlet weak var lblDeliveryCharge: UILabel!
    
    
    @IBOutlet weak var lblOnceOrderConfirmed: UILabel!   
    @IBOutlet weak var lblOrderTotal: UILabel!
    @IBOutlet weak var lbldeliveryCharges: UILabel!
    @IBOutlet weak var lblgrandTotal: UILabel!
    
    @IBOutlet weak var confirmButton: defaultButton!
    
    @IBOutlet weak var txtFieldCoupon: UITextField!
    
    
    var grand_total = Float()
    var delivery_charge = Float()
    var total_charges: String = ""
    
    var idOrder = String()
    var branch_id = String()
    var resturent_id = String()
    var quantity = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDel.apiManager.setCurrentViewController(vc: self)
        self.automaticallyAdjustsScrollViewInsets = false
        tblViewReviewOrder.reloadData()
        UINavigationBar.appearance().tintColor = UIColor.white
        let amt = UserDefaults.standard.object(forKey: Constant.User.TOTAL_AMOUNT) as? String
        
        total_charges = amt!.replacingOccurrences(of: "SR ", with: "")
        
        lblTotalAmount.text = "SR " + total_charges
        
        lblDeliveryCharge.text = "SR " + String(describing: UserDefaults.standard.object(forKey: Constant.User.DELIVERY_CHARGES_FINAL) as! Float)
        
        delivery_charge = UserDefaults.standard.object(forKey: Constant.User.DELIVERY_CHARGES_FINAL) as! Float
        
        grand_total = delivery_charge + Float(total_charges)!
        
        lblGrandTotal.text =  "SR " + String(grand_total)
        
        print("selectedMenuItemArray: ", self.selectedMenuItemArray)
        self.tblViewReviewOrder.separatorStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        if appDel.flagLanguage == 1{
            
            let path = Bundle.main.path(forResource: "ar-SA", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
            
            
            let title = bundal.localizedString(forKey: "REVIEW", value: nil, table: nil)
            
            navigationItem.title = title
            
            
            lblOnceOrderConfirmed.text = bundal.localizedString(forKey: "Once order is confirmed we will dispatch your order to the colsest driver", value: nil, table: nil)
            
            lblOrderTotal.text = bundal.localizedString(forKey: "Order total", value: nil, table: nil)
            
            lbldeliveryCharges.text = bundal.localizedString(forKey: "Delivery charges:", value: nil, table: nil)
            
            lblgrandTotal.text = bundal.localizedString(forKey: "Grand total:", value: nil, table: nil)
            
            let btn = bundal.localizedString(forKey: "Confirm", value: nil, table: nil)
            
            confirmButton.setTitle(btn, for: .normal)
            
            txtFieldCoupon.placeholder = bundal.localizedString(forKey: "Have a promotional code or coupon ?", value: nil, table: nil)
            
            
        }else{
            
            let path = Bundle.main.path(forResource: "en", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
            
            let title = bundal.localizedString(forKey: "REVIEW", value: nil, table: nil)
            
            navigationItem.title = title
            
            
            lblOnceOrderConfirmed.text = bundal.localizedString(forKey: "Once order is confirmed we will dispatch your order to the colsest driver", value: nil, table: nil)
            
            lblOrderTotal.text = bundal.localizedString(forKey: "Order total", value: nil, table: nil)
            
            lbldeliveryCharges.text = bundal.localizedString(forKey: "Delivery charges:", value: nil, table: nil)
            
            lblgrandTotal.text = bundal.localizedString(forKey: "Grand total:", value: nil, table: nil)
            
            let btn = bundal.localizedString(forKey: "Confirm", value: nil, table: nil)
            
            confirmButton.setTitle(btn, for: .normal)
            
            txtFieldCoupon.placeholder = bundal.localizedString(forKey: "Have a promotional code or coupon ?", value: nil, table: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblViewReviewOrder.dequeueReusableCell(withIdentifier: "reviewItemCell", for: indexPath) as! reviewItemCell
        
        
        cell.lblMenuTitle?.text = ((selectedMenuItemArray.object(at: indexPath.row) as AnyObject).value(forKey: "name") as AnyObject) as? String
        
        cell.lblMenuPrice?.text = "SR " + String(((selectedMenuItemArray.object(at: indexPath.row) as AnyObject).value(forKey: "price") as AnyObject) as! Float)
            
        let quantity = Int(((selectedMenuItemArray.object(at: indexPath.row) as AnyObject).value(forKey: "quantity") as AnyObject) as! Float)
        
        cell.lblMenuQuantity?.text = String(quantity)
     
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! reviewItemCell
        currentCell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedMenuItemArray.count
    }
    

    @IBAction func clickConfirm(_ sender: Any) {
        if selectedMenuItemArray.count > 0 {
            
            for i in 0..<selectedMenuItemArray.count {
                
                if self.idOrder.characters.count != 0 {
                    self.idOrder = self.idOrder + "," + String((((selectedMenuItemArray.object(at: i) as AnyObject).value(forKey: "id") as AnyObject) as? Int)!)
                }else{
                    self.idOrder = String((((selectedMenuItemArray.object(at: i) as AnyObject).value(forKey: "id") as AnyObject) as? Int)!)
                }
                
                if self.branch_id.characters.count != 0 {
                    self.branch_id = self.branch_id + "," + (UserDefaults.standard.object(forKey: "branch_id") as? String)!
                }else{
                    self.branch_id = (UserDefaults.standard.object(forKey: "branch_id") as? String)!
                }
                
                if self.resturent_id.characters.count != 0 {
                    self.resturent_id = self.resturent_id + "," + String((((selectedMenuItemArray.object(at: i) as AnyObject).value(forKey: "restaurant_id") as AnyObject) as? Int)!)
                }else{
                    self.resturent_id = String((((selectedMenuItemArray.object(at: i) as AnyObject).value(forKey: "restaurant_id") as AnyObject) as? Int)!)
                }
                
                if self.quantity.characters.count != 0 {
                    self.quantity = self.quantity + "," + String((((selectedMenuItemArray.object(at: i) as AnyObject).value(forKey: "quantity") as AnyObject) as? Float)!)
                }else{
                    self.quantity = String((((selectedMenuItemArray.object(at: i) as AnyObject).value(forKey: "quantity") as AnyObject) as? Float)!)
                }
            }
            
            print("id: ", self.idOrder)
            print("branch_id: ", self.branch_id)
            print("resturent_id: ", self.resturent_id)
            print("quantity: ", self.quantity)
        }
        
        if appDel.flagLanguage == 1{
            
            let alert = UIAlertController(title: "محزر", message: "هل أنت متأكد من تأكيد طلبك؟", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "لا", style: UIAlertActionStyle.cancel, handler: nil));
            //event handler with closure
            alert.addAction(UIAlertAction(title: "نعم فعلا", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
                
                if self.isInternetAvailable() {
                    let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                    loadingNotification.label.text = "جار التحميل"
                    
                    self.setOrder(sub_total: self.total_charges, delivery_fees: String(self.delivery_charge), total: String(self.grand_total), id: self.idOrder, branch_id: self.branch_id, resturent_id: self.resturent_id, quantity: self.quantity)
                }else {
                    self.ShowAlert("يرجى التحقق من اتصال الشبكة");
                }
                
                
            }));
            alert.view.tintColor = UIColor.red
            present(alert, animated: true, completion: nil)
            
        }else{
        let alert = UIAlertController(title: "Alert", message: "Are you sure to confirm your order?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil));
        //event handler with closure
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            
            
            if self.isInternetAvailable() {
                let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                
                loadingNotification.label.text = "Loading"
                
                self.setOrder(sub_total: self.total_charges, delivery_fees: String(self.delivery_charge), total: String(self.grand_total), id: self.idOrder, branch_id: self.branch_id, resturent_id: self.resturent_id, quantity: self.quantity)
            }else {
                self.ShowAlert("Please check network connection");
            }
            
            
        }));
        alert.view.tintColor = UIColor.red
        present(alert, animated: true, completion: nil)
        }
    }
    
    private func setOrder(sub_total: String, delivery_fees: String, total: String, id: String, branch_id: String, resturent_id: String, quantity: String) {
//        print("orderDict is: ", orderDict)
        
        self.appDel.apiManager.self.setOrder(sub_total: self.total_charges, delivery_fees: String(self.delivery_charge), total: String(self.grand_total), id: self.idOrder, branch_id: self.branch_id, resturent_id: self.resturent_id, quantity: self.quantity, onComplete: {
            (details, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if details != nil {
                print("Set Order details is: ",details!)
                
                let status = (details as AnyObject).value(forKey: "status") as! String
                
                if status == "success" {
                    self.performSegue(withIdentifier: "Review_OrderComplete", sender: self)
                }else{
                    let message = (details as AnyObject).value(forKey: "message") as! String
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
}
