//
//  Room.swift
//  ZipChat
//
//  Created by Zachary Webert on 5/18/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

class Room: NSObject {
    var roomId: Int = -1
    var lastActivity: Int = 0
    
    let timeFormatter = TTTTimeIntervalFormatter()
    
    init(dictionary:[String:AnyObject]) {
        if let roomId = dictionary["roomId"] as? Int {
            self.roomId = roomId
        }
        if let lastActivity = dictionary["lastActivity"] as? Int {
            self.lastActivity = lastActivity
        }
    }
    
    func timeSinceLastActivity() -> String {
        let seconds = NSTimeInterval(self.lastActivity) - NSDate().timeIntervalSince1970
        return timeFormatter.stringForTimeInterval(seconds)
    }
}
