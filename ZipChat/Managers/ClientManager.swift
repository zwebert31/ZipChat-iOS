//
//  ClientManager.swift
//  ZipChat
//
//  Created by Zachary Webert on 3/24/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

private let manager = ClientManager()

class ClientManager: NSObject {
    
    var userId: Int?
    {
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "userId")
        }
        
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("userId") as? Int
        }
    }
    
    var user: User? {
        didSet {
            self.saveUser()
        }
    }
    
    func loadUser() {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("user") as? NSData {
            let unarc = NSKeyedUnarchiver(forReadingWithData: data)
            self.user = unarc.decodeObjectForKey("root") as? User
        }
    }
    
    func saveUser() {
        if let user = self.user {
            NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(user), forKey: "user")
        }
    }
    
    class var sharedManager: ClientManager {
        return manager
    }
    
}
