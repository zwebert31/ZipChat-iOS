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
    
    var user = User()
    
    class var sharedManager: ClientManager {
        return manager
    }
    
}
