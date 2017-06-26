//
//  Constant.swift
//  cirrb app
//
//  Created by mac on 27/04/17.
//  Copyright © 2017 3WebBox, Inc. All rights reserved.
//

import UIKit

class Constant: NSObject {
    
    struct CommanURLs {
       static let SERVER_URL = "http://api.cirrb.com/api/"
        //"http://13.56.74.245/api/"
        //"http://ec2-54-153-46-19.us-west-1.compute.amazonaws.com/apicirrbcom/public/api/"
        //"http://websitework.in/apicirrbcom/public/index.php/api/"        
        //"http://api.cirrb.com/public/api/"
        //"http://cirrb.com/cirrbLaravel/public/api/"
        //"http://cirrb.3webbox.com/cirrbLaravel/public/api/"
    }
    
    struct Methods {
        
        static let LOGIN = "login"
        static let REGISTER = "register"
        static let FORGOT_PASSWORD = "password/email"
        static let SET_PASSWORD = "password/reset"
        static let SET_ORDER =  "setOrder"
    }
    
    struct User {
        static let USER_ID = "user_id"
        static let TOTAL_AMOUNT = "total_amount"
        static let FIRST_NAME = "first_name"
        static let LAST_NAME = "last_name"
        static let PHONE = "phone"
        static let EMAIL_USER = "email_user"
        static let IMAGE_PATH = "image_path"
        
        static let AUTH_TOKEN = "auth_token"
        static let CURRENT_LATITUDE = "latitude"
        static let CURRENT_LONGITUDE = "longitude"
        static let DELIVERY_CHARGES_FINAL = "delivery_charges_final"
        static let DELIVERY_CHARGES_PER_KM = "delivery_charges_per_km"
        static let MINIMUM_DELIVERY_CHARGES = "minimum_delivery_charges"
        static let ORDER_LIMIT = "order_limit"
        
        static let SET_EMAIL = "set_email"
        static let SET_PASSWORD = "set_password"
        static let SET_DEVICE_TOKEN = "set_device_token"
    }

}
