//  Copyright © 2018 Cuc Kim. All rights reserved.

import Foundation

class UserList: Codable {
    var users: Array<User>
    
    public func getUsers() -> Array<User> {
        return self.users
    }
}
