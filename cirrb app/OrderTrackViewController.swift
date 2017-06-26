//
//  OrderTrackViewController.swift
//  cirrb app
//
//  Created by mac on 28/04/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit

class OrderTrackViewController: UIViewController {
    
    
    @IBOutlet weak var lblOrderComplete: UILabel!
    
    
    @IBOutlet weak var lblWeHaveReceived: UILabel!
    
    
    @IBOutlet weak var trackMyOrderButton: defaultButton!

    var appDel: AppDelegate! = (UIApplication.shared.delegate as! AppDelegate)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        if appDel.flagLanguage == 1{
            
            let path = Bundle.main.path(forResource: "ar-SA", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
    
            lblOrderComplete.text = bundal.localizedString(forKey: "Order Complete", value: nil, table: nil)
            
            lblWeHaveReceived.text = bundal.localizedString(forKey: "We've recieved your order. Cirrb is locating the closest driver to deliver your order", value: nil, table: nil)
            
            let btn = bundal.localizedString(forKey: "TRACK MY ORDER", value: nil, table: nil)
            
            trackMyOrderButton.setTitle(btn, for: .normal)
            
            
        }else{
            
            let path = Bundle.main.path(forResource: "en", ofType: "lproj")
            
            let bundal = Bundle.init(path: path!)! as Bundle
            
            lblOrderComplete.text = bundal.localizedString(forKey: "Order Complete", value: nil, table: nil)
            
            lblWeHaveReceived.text = bundal.localizedString(forKey: "We've recieved your order. Cirrb is locating the closest driver to deliver your order", value: nil, table: nil)
            
            let btn = bundal.localizedString(forKey: "TRACK MY ORDER", value: nil, table: nil)
            
            trackMyOrderButton.setTitle(btn, for: .normal)
        }
   
    }
    
    @IBAction func clickTrackOrder(_ sender: Any) {
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let desController = mainstoryboard.instantiateViewController(withIdentifier: "homeViewController") as! HomeViewController
        let newFrontController = UINavigationController.init(rootViewController: desController)
        self.revealViewController().pushFrontViewController(newFrontController, animated: true)
    }
}
