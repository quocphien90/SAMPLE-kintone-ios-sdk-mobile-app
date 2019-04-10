//  Copyright © 2018 Cuc Kim. All rights reserved.

import Foundation

class User: Codable {
    var timezone: String?
    
    public func getTimezone() -> String? {
        return self.timezone
    }
}
