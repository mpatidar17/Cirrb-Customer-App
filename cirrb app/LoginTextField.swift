//
//  LoginTextField.swift
//  Cirrb app
//
//  Created by Rafet Khallaf on 3/20/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit

public class LoginTextField: UITextField {
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = UIColor(white: 231 / 255, alpha: 1).cgColor
        self.layer.borderWidth = 1
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 3
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 8, dy: 7)
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
}
