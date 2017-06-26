//
//  DefaultViewController.swift
//  cirrb app
//
//  Created by mac on 08/05/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit

class DefaultViewController: UIViewController {

    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.revealToggle(_:))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
