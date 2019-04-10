//  Copyright © 2018 Cybozu. All rights reserved.

import Foundation
public extension Date {
    /**
     Initializes an NSDate object from a python datetime string
     */
    init(datetime: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = dateFormatter.date(from: datetime) {
            self.init(timeInterval: 0, since: date)
        }
        else {
            self.init()
        }
    }
    
    
    /**
     Initializes an NSDate object from a python date string
     */
    init(date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: date) {
            self.init(timeInterval: 0, since: date)
        }
        else {
            self.init()
        }
    }
    
    
    /**
     Formats the date to the format and returns it as a string
     */
    func formatToString(dateFormat: String, timezone: String = "UTC") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = TimeZone(abbreviation: timezone)
        return formatter.string(from: self)
    }
}
