//
//  singleTextField.swift
//  Cirrb app
//
//  Created by Rafet Khallaf on 3/20/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit

public class singleTextField: UITextField {
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = UIColor(white: 231 / 255, alpha: 1).cgColor
        self.layer.borderWidth = 1
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 3
    }
    
}
