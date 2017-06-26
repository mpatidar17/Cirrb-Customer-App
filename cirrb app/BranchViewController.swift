//
//  BranchViewController.swift
//  cirrb app
//
//  Created by mac on 27/04/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD
import Kingfisher

class branchCell: UITableViewCell {
    @IBOutlet weak var lblBranchTitle: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblSetDistance: UILabel!
    @IBOutlet weak var imgvwBranch: UIImageView!
    var branchInfoDict = NSDictionary()
}

class BranchViewController: BaseViewController , UITableViewDelegate, UITableViewDataSource {
    var appDel: AppDelegate! = (UIApplication.shared.delegate as! AppDelegate)
    var branchList = NSArray()
    var branchInfoObject = NSDictionary()
    @IBOutlet weak var lblNoDataFound: UILabel!
    @IBOutlet weak var tblviewBranch: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDel.apiManager.setCurrentViewController(vc: self)
        self.navigationController?.isNavigationBarHidden = false
        //self.automaticallyAdjustsScrollViewInsets = true
        
        //Change Navigation title
        //self.navigationController?.navigationBar.topItem?.title = "Back"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        lblNoDataFound.isHidden = true
        
        let latitude = UserDefaults.standard.object(forKey: Constant.User.CURRENT_LATITUDE) as? String
        let longitude = UserDefaults.standard.object(forKey: Constant.User.CURRENT_LONGITUDE) as? String
        self.automaticallyAdjustsScrollViewInsets = false
        if isInternetAvailable() {
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            if appDel.flagLanguage == 1{
            loadingNotification.label.text = "جار التحميل"
            }else{
            loadingNotification.label.text = "Loading"
            }
            getBranches(latitude: latitude!, longitude: longitude!, distance: "1000")
            self.tblviewBranch.separatorStyle = .none
        }else {
            self.ShowAlert("Please check network connection");
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if appDel.flagLanguage == 1{
            
            let path = Bundle.main.path(forResource: "ar-SA", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
            
            let title = bundal.localizedString(forKey: "Restaurant", value: nil, table: nil)
            
            navigationItem.title = title
            
            lblNoDataFound.text = bundal.localizedString(forKey: "No restaurant available near by you", value: nil, table: nil)
            
        }else{
            
            let path = Bundle.main.path(forResource: "en", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
            
            let title = bundal.localizedString(forKey: "Restaurant", value: nil, table: nil)
            
            navigationItem.title = title
            
            lblNoDataFound.text = bundal.localizedString(forKey: "No restaurant available near by you", value: nil, table: nil)
            
        }

    }
    private func getBranches(latitude: String, longitude: String,distance: String) {
        self.appDel.apiManager.getBranches(latitude: latitude, longitude: longitude, distance: distance,onComplete: {
            (details, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if details != nil {
                let branchDetailDict = details as! NSDictionary
                let status = branchDetailDict.value(forKey: "status") as! String
                
                if status == "success"
                {
                  self.branchList = (branchDetailDict.object(forKey: "details") as AnyObject) as! NSArray
                   
                    if self.branchList.count > 0 {
                        print("self.branchList is: ",self.branchList)
                        self.lblNoDataFound.isHidden = true
                        self.tblviewBranch.isHidden = false
                        self.tblviewBranch.reloadData()
                    }else {
                        self.tblviewBranch.isHidden = true
                        self.lblNoDataFound.isHidden = false
                    }
                }else{
                    let message = branchDetailDict.value(forKey: "message") as! String
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
            self.ShowAlert("Server is not responding.")
            }
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return branchList.count
    }


    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "branchCell", for: indexPath) as! branchCell
        
        cell.imgvwBranch.layer.cornerRadius = 2
        cell.imgvwBranch.clipsToBounds = true
        
        cell.lblBranchTitle?.text = (((branchList.object(at: indexPath.row) as AnyObject).object(forKey: "restaurant") as AnyObject).value(forKey: "name") as AnyObject) as? String
            
        
        
        cell.lblSetDistance?.text = "Distance:  " + String((((branchList.object(at: indexPath.row) as AnyObject).object(forKey: "branch") as AnyObject).value(forKey: "distance") as AnyObject) as! Float) + " KM"
        
        cell.lblDistance.text = (((branchList.object(at: indexPath.row) as AnyObject).object(forKey: "branch") as AnyObject).value(forKey: "name") as AnyObject) as? String
        
        let urlstr: String? = (((branchList.object(at: indexPath.row) as AnyObject).object(forKey: "restaurant") as AnyObject).value(forKey: "image") as AnyObject) as? String
        
        if urlstr != nil {
            let url = URL(string: urlstr!)
            cell.imgvwBranch.kf.setImage(with: url)
        }else {
            let url = URL(string: "http://cirrb.3webbox.com/cirrbLaravel/public/images/restaurent-1.png")
            cell.imgvwBranch.kf.setImage(with: url)
        }
        
        cell.branchInfoDict = (branchList.object(at: indexPath.row) as AnyObject) as! NSDictionary
       
        
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! branchCell
        self.branchInfoObject = currentCell.branchInfoDict
        currentCell.selectionStyle = .none
        //currentCell.contentView.backgroundColor = UIColor(white: 1, alpha: 1.0)
        self.performSegue(withIdentifier: "itemDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "itemDetails"){
            let selectedvc = segue.destination as! ItemMenuViewController
            selectedvc.menuInfoDict = self.branchInfoObject

        }
    }
}
