//
//  User.swift
//  ZipChat
//
//  Created by Zachary Webert on 3/25/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

class User: NSObject {
    var userId: Int!
    var facebookId: Int!
    var name: String!
    var registrationId: String?
    var platform: String?
    
    override init() {}
    
    init(dictionary:[String:AnyObject]) {
        if let userId = dictionary["userId"] as? Int {
            self.userId = userId
        }
        
        if let facebookId = dictionary["facebookId"] as? String {
            self.facebookId = facebookId.toInt()
        }
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let registrationId = dictionary["registrationId"] as? String {
            self.registrationId = registrationId
        }
        
        if let platform = dictionary["platform"] as? String {
            self.platform = platform
        }
    }
    
    class func createUserWithSuccess(success:((userId: Int)->())?, failure:((error: NSError)->())?) {
        let clientManager = ClientManager.sharedManager
        let requestManager = RequestManager.sharedManager
        var params: NSMutableDictionary = NSMutableDictionary()
        requestManager.addParameter(params, object: clientManager.user.facebookId, key: "facebookId")
        requestManager.addParameter(params, object: clientManager.user.name, key: "name")
        requestManager.addParameter(params, object: clientManager.user.registrationId, key: "registrationId")
        requestManager.addParameter(params, object: "ios", key: "platform")
        
        requestManager.operationManager.POST(UsersEndPoint, parameters: params, success: { (operation, response) -> Void in
            success?(userId: (response["userId"] as? Int) ?? -1)
            return
            }) { (operation, error) -> Void in
                failure?(error: error)
                NSLog(error.localizedDescription)
        }
    }
}

