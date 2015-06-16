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
    var authToken: String?
    
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
        
        if let authToken = dictionary["authToken"] as? String {
            self.authToken = authToken
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        if let userId = aDecoder.decodeObjectForKey("userId") as? Int {
            self.userId = userId
        }
        
        if let facebookId = aDecoder.decodeObjectForKey("facebookId") as? Int {
            self.facebookId = facebookId
        }
        
        if let name = aDecoder.decodeObjectForKey("name") as? String {
            self.name = name
        }
        
        if let authToken = aDecoder.decodeObjectForKey("authToken") as? String {
            self.authToken = authToken
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(userId, forKey: "userId")
        aCoder.encodeObject(facebookId, forKey: "facebookId")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(authToken, forKey: "authToken")
    }
    
    class func createUserWithSuccess(accessToken: String, success:((user:User) -> ())?, failure:((error: NSError)->())?) {
        let requestManager = RequestManager.sharedManager
        requestManager.operationManager.PUT(UsersEndPoint, parameters: ["fbAccessToken":accessToken], success: { (operation, response) -> Void in
            if let userData = response as? [String:AnyObject] {
                success?(user:User(dictionary:userData))
            }
        }) { (operation, error) -> Void in
            NSLog(error.localizedDescription)
        }
    }
    
    class func authenticateUserWithSuccess(accessToken: String, success:((authToken: String) -> ())?, failure:((error: NSError)->())?) {
        let requestManager = RequestManager.sharedManager
        requestManager.operationManager.GET(AuthenticationEndPoint, parameters: ["fbAccessToken":accessToken], success: { (operation, response) -> Void in
            if let token = response["authToken"] as? String {
                success?(authToken: token)
            }
            }) { (operation, error) -> Void in
                NSLog(error.localizedDescription)
        }
    }
}

