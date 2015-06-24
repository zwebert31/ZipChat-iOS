//
//  EnvironmentManager.swift
//  ZipChat
//
//  Created by Zachary Webert on 3/25/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

private let manager = EnvironmentManager()

class EnvironmentManager: NSObject {
    private var _configuration: NSDictionary?
    
    var configuration: [String:String]? {
        if _configuration == nil {
            if let configPath = NSBundle.mainBundle().pathForResource(NSBundle.mainBundle().infoDictionary?["Configuration"] as?String, ofType: "plist") {
            _configuration = NSDictionary(contentsOfFile: configPath)
            }
        }
        return _configuration as? [String:String]
    }
    
    var baseUrl: String? {
        let config = self.configuration
        return config?["baseURL"]
    }
    
    class var sharedManager: EnvironmentManager {
        return manager
    }
}
