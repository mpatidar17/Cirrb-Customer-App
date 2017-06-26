//
//  defaultButton.swift
//  Cirrb app
//
//  Created by Rafet Khallaf on 3/20/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit

public class defaultButton: UIButton {
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 3
    }
    
}
