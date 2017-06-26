//
//  ItemMenuViewController.swift
//  cirrb app
//
//  Created by mac on 27/04/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD
import Kingfisher

typealias ButtonHandler = (menuItemCell) -> Void

class menuItemCell: UITableViewCell {
    @IBOutlet weak var lblMenuItemTitle: UILabel!
    @IBOutlet weak var lblMenuItemPrice: UILabel!
    @IBOutlet weak var lblMenuItemQuantity: UILabel!
    @IBOutlet weak var btnIncreaseQuatity: UIButton!
    @IBOutlet weak var btnDecreaseQuatity: UIButton!
    @IBOutlet weak var imgvwMenuItem: UIImageView!
    
    var incrementHandler: ButtonHandler?
    var decrementHandler: ButtonHandler?
    
    func configureWithValue(value: Int, incrementHandler: ButtonHandler?, decrementHandler: ButtonHandler?) {
        
        lblMenuItemQuantity.text = String(value)
        self.incrementHandler = incrementHandler
        self.decrementHandler = decrementHandler
    }
    @IBAction func increment(sender: UIButton) {
        incrementHandler?(self)
    }
    @IBAction func decrement(sender: UIButton) {
        decrementHandler?(self)
    }
}
class ItemMenuViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource{

    var appDel: AppDelegate! = (UIApplication.shared.delegate as! AppDelegate)
    var itemArray = NSMutableArray()
    var menuItemList = NSArray()
    var menuInfoDict = NSDictionary()
    @IBOutlet weak var lblNoDataFound: UILabel!
    var menuList: [Float] = Array(repeating: 0, count: 100)
    
    @IBOutlet weak var totalAmtLabel: UILabel!
    @IBOutlet weak var tblviewMenuItem: UITableView!
    
    @IBOutlet weak var lblTotal: UILabel!
    
    @IBOutlet weak var continueButton: defaultButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.appDel.apiManager.setCurrentViewController(vc: self)
        self.automaticallyAdjustsScrollViewInsets = false
        
        UINavigationBar.appearance().tintColor = UIColor.white
        let menuInfoObject = menuInfoDict
        
        
        
        let id = ((menuInfoObject.value(forKey: "restaurant") as AnyObject).value(forKey: "id") as AnyObject) as! Int
        
        let branch_id = ((menuInfoObject.value(forKey: "branch") as AnyObject).value(forKey: "id") as AnyObject) as! Int
       
        UserDefaults.standard.setValue(String(branch_id), forKey: "branch_id")
        
        let distance = ((menuInfoObject.value(forKey: "branch") as AnyObject).value(forKey: "distance") as AnyObject) as! Int
        
        let per_km_charge = UserDefaults.standard.object(forKey: Constant.User.DELIVERY_CHARGES_PER_KM) as? Float
        
        let delivery_charges = Float(distance) * Float(per_km_charge!)
        
        let minimum_charges = UserDefaults.standard.object(forKey: Constant.User.MINIMUM_DELIVERY_CHARGES) as? Float
        
        if delivery_charges .isLess(than: minimum_charges!) {
        
            UserDefaults.standard.set(minimum_charges, forKey: Constant.User.DELIVERY_CHARGES_FINAL)
          
        }else{
          
            UserDefaults.standard.set(delivery_charges, forKey: Constant.User.DELIVERY_CHARGES_FINAL)
            
        }
        
        if isInternetAvailable() {
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            if appDel.flagLanguage == 1{
            loadingNotification.label.text = "جار التحميل"
            }else{
            loadingNotification.label.text = "Loading"
            }
            getBranchMenu(res_ID: String(id))
        }else {
            self.ShowAlert("Please check network connection");
        }
        lblNoDataFound.isHidden = true
        // Do any additional setup after loading the view.
        self.tblviewMenuItem.separatorStyle = .none
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if appDel.flagLanguage == 1{
            
            let path = Bundle.main.path(forResource: "ar-SA", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
            
            let btn = bundal.localizedString(forKey: "Continue", value: nil, table: nil)
            
            lblTotal.text = bundal.localizedString(forKey: "Total", value: nil, table: nil)
            
            lblNoDataFound.text = bundal.localizedString(forKey: "Menu for restaurant not available", value: nil, table: nil)
            
            continueButton.setTitle(btn, for: .normal)
            
            let title = bundal.localizedString(forKey: "MENU", value: nil, table: nil)
            
            navigationItem.title = title
            
            
        }else{
            
            let path = Bundle.main.path(forResource: "en", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
            
            let btn = bundal.localizedString(forKey: "Continue", value: nil, table: nil)
            
            lblTotal.text = bundal.localizedString(forKey: "Total", value: nil, table: nil)
            
            lblNoDataFound.text = bundal.localizedString(forKey: "Menu for restaurant not available", value: nil, table: nil)
            
            continueButton.setTitle(btn, for: .normal)
            
            let title = bundal.localizedString(forKey: "MENU", value: nil, table: nil)
            
            navigationItem.title = title
        }

        
    }
    private func getBranchMenu(res_ID: String) {
        self.appDel.apiManager.getBranchMenu(restaurantId: res_ID, onComplete: {
            (details, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if details != nil {
                let branchMenuDict = details as! NSDictionary
                let status = branchMenuDict.value(forKey: "status") as! String
                if status == "success"
                {
                    self.menuItemList = branchMenuDict.object(forKey: "details") as! NSArray
                    
                    if self.menuItemList.count > 0 {
                        print("menuItemList is: ",self.menuItemList)
                        self.lblNoDataFound.isHidden = true
                        self.tblviewMenuItem.isHidden = false
                        self.tblviewMenuItem.reloadData()
                    }else {
                        self.tblviewMenuItem.isHidden = true
                        self.lblNoDataFound.isHidden = false
                    }
                }else{
                    let message = branchMenuDict.value(forKey: "message") as! String
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
            }else
            {
                self.ShowAlert("Server is not responding")
            }

        })
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItemCell", for: indexPath) as! menuItemCell
        
        cell.imgvwMenuItem.layer.cornerRadius = 2
        cell.imgvwMenuItem.clipsToBounds = true
        
        cell.lblMenuItemTitle?.text = ((menuItemList.object(at: indexPath.row) as AnyObject).value(forKey: "name") as AnyObject) as? String
        
        cell.lblMenuItemPrice?.text = "Price: SR " + String(((menuItemList.object(at: indexPath.row) as AnyObject).value(forKey: "price") as AnyObject) as! Float)
        
        let urlstr: String? = ((menuItemList.object(at: (indexPath.row)) as AnyObject).value(forKey: "image") as AnyObject) as? String
        
        if urlstr != nil {
            let url = URL(string: urlstr!)
            cell.imgvwMenuItem.kf.setImage(with: url)
        }else {
            let url = URL(string: "http://cirrb.3webbox.com/cirrbLaravel/public/images/restaurent-1.png")
            cell.imgvwMenuItem.kf.setImage(with: url)
        }
        
        cell.configureWithValue(value: Int(menuList[indexPath.row]), incrementHandler: incrementHandler(), decrementHandler: decrementHandler())
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! menuItemCell
        currentCell.selectionStyle = .none
   }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemList.count
    }
    private func incrementHandler() -> ButtonHandler {
        return { [unowned self] cell in
            guard let row = self.tblviewMenuItem.indexPath(for: cell)?.row else { return }
            self.menuList[row] = self.menuList[row] + Float(1)
            var total : Float = 0
            for i in 0..<self.menuItemList.count
            {
               let price_amt = (((self.menuItemList[i] as AnyObject).value(forKey: "price") as AnyObject) as! Float)
                 print("price_amt is: ",price_amt)
                
                let price_value = Float(price_amt)
                let value = Float(price_value) * (self.menuList[i])
                total = total + value
            }
            //print("Value is :>",total)
            self.totalAmtLabel.text = "SR " + String(total)
            self.reloadCellAtRow(row: row)
        }
    }
    private func decrementHandler() -> ButtonHandler {
        return { [unowned self] cell in
            guard
                let row = self.tblviewMenuItem.indexPath(for: cell)?.row, self.menuList[row] > 0
                else { return }
            self.menuList[row] = self.menuList[row] - Float(1)
            
            var total : Float = 0
            for i in 0..<self.menuItemList.count
            {
                let price_amt = (((self.menuItemList[i] as AnyObject).value(forKey: "price") as AnyObject) as! Float)
                print("price_amt is: ",price_amt)
                
                let price_value = Float(price_amt)
                let value = Float(price_value) * (self.menuList[i])
                total = total + value
            }
            //print("Value is :>",total)
            self.totalAmtLabel.text = "SR " + String(total)
            self.reloadCellAtRow(row: row)
        }
    }
    private func reloadCellAtRow(row: Int) {
        let indexPath = NSIndexPath(row: row, section: 0)          
        tblviewMenuItem.beginUpdates()
        tblviewMenuItem.reloadRows(at: [indexPath as IndexPath], with: .automatic)
        tblviewMenuItem.endUpdates()
    }
    @IBAction func clickContinue(_ sender: Any) {
        
        if self.lblNoDataFound.isHidden {
            
            self.itemArray = NSMutableArray()
            for i in 0..<self.menuItemList.count
            {
                if (self.menuList[i] > 0) {
                    let objectDict: NSDictionary = (self.menuItemList[i] as AnyObject) as! NSDictionary
                    print("Object is: ",objectDict)
                    let myMutableDict: NSMutableDictionary = NSMutableDictionary(dictionary: objectDict)
                    myMutableDict.setValue(self.menuList[i], forKey: "quantity")
                    print("myMutableDict is: ",myMutableDict)
                    self.itemArray.add(myMutableDict)
                    
                }
                
            }
            print("self.itemArray: ", self.itemArray)
            if self.itemArray.count > 0 {
                self.performSegue(withIdentifier: "Menu_Review", sender: self)
            }else{
                self.ShowAlert("Please add your order.");
            }
        }else {
            self.ShowAlert("Sorry! Menu list for restaurant not available.");
        }
        
        
      }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Menu_Review"{
            let total = self.totalAmtLabel.text
            print("total Amount: ", total!)
            UserDefaults.standard.setValue(total!, forKey: Constant.User.TOTAL_AMOUNT)
            let selectedvc = segue.destination as! OrderReviewViewController
            print("self.itemArray: ", self.itemArray)
            selectedvc.selectedMenuItemArray = self.itemArray
        }
    }
}
