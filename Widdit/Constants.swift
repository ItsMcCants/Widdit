//
//  Constants.swift
//  Widdit
//
//  Created by JH Lee on 03/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit

class Constants {
    struct Parse {
        static let APPLICATION_ID           = "CbvFKWpmIJFzo8gKzwPXdM5lN1bGPXu2Ln3lbjGx"
        static let CLIENT_KEY               = "H6X4RPx8lay4X1YUCu9gA1kPjI2gFxepr152h5x6"
        static let SERVER                   = "http://159.203.232.104:1337/parse"
    }
    
    struct SMSVerification {
        static let APPLICATION_KEY          = "50bd9bd8-7468-4484-8185-e53ee94e00c9"
    }
    
    struct UserDefaults {
        static let FIRST_START              = "UserDefaultsFirstStart"
    }
    
    struct Arrays {
        static let TUTORIAL_TITLES          = [
                                                "Be down to collaborate",
                                                "Be down to buy/sell",
                                                "Be down to do anything",
                                                "Go ahead and tap the I'm down button",
                                                "We want to notify you on downs, replies, and updates 💯",
                                                "We need your location to show you posts 🌎"
                                            ]
    }
    
    struct String {
        static let APP_NAME                 = "Widdit"
        static let NO_USERNAME              = "Please input username"
        static let NO_NAME                  = "Please input name"
        static let INVALID_EMAIL            = "Invalid email address"
        static let SHORT_PASSWORD           = "Password should be 6 characters at least"
    }
    
    struct Integer {
        static let AVATAR_SIZE              = 200
        static let FEED_REGION              = 25.0
        static let MAX_POST_LENGTH          = 140
    }
}
