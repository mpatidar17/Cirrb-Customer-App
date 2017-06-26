//
//  RegisterSuccessViewController.swift
//  cirrb app
//
//  Created by mac on 01/05/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit

class RegisterSuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickRegcontinue(_ sender: Any) {
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let desController = mainstoryboard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        self.present(desController, animated: true, completion: nil)
    }
}
