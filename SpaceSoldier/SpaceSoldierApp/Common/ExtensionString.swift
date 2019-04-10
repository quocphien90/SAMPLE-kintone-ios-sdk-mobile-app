//
//  ExtensionString.swift
//  SpaceSoldierApp
//
//  Created by Pham Anh Quoc Phien on 10/16/18.
//  Copyright © 2018 Cuc Kim. All rights reserved.
//

import UIKit
extension String {
    
    func evaluate(with condition: String) -> Bool {
        guard let range = range(of: condition, options: .regularExpression, range: nil, locale: nil) else {
            return false
        }
        
        return range.lowerBound == startIndex && range.upperBound == endIndex
    }
    func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        guard let date = dateFormatter.date(from: self) else {
            return Date()
        }
        return date
    }
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
}
