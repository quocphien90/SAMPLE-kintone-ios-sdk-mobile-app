//
//  ExtensionUITextField.swift
//  SpaceSoldierApp
//
//  Created by Pham Anh Quoc Phien on 10/16/18.
//  Copyright © 2018 Cuc Kim. All rights reserved.
//

import UIKit
extension UITextField {
    func isPhoneNumberValid(text: String) -> Bool {
        let regexp = "^[0-9]{10}$"
        return text.evaluate(with: regexp)
    }
    
    func isZipCodeValid(text: String) -> Bool {
        let regexp = "^[0-9]{5}$"
        return text.evaluate(with: regexp)
    }
    
    func isStateValid(text: String) -> Bool {
        let regexp = "^[A-Z]{2}$"
        return text.evaluate(with: regexp)
    }
    
    func isCVCValid(text: String) -> Bool {
        let regexp = "^[0-9]{3,4}$"
        return text.evaluate(with: regexp)
    }
    
    func isEmailValid(text: String) -> Bool {
        let regexp = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
        return text.evaluate(with: regexp)
    }
    
    func isNumberValid(text: String) -> Bool {
        let regexp = "^[0-9]+$"
        return text.evaluate(with: regexp)
    }
    
    func isNameValid(text: String) -> Bool {
        let regexp = "^[a-zA-Z]+$"
        return text.evaluate(with: regexp)
    }
}
