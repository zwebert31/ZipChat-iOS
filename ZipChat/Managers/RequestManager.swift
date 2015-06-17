//
//  RequestManager.swift
//  ZipChat
//
//  Created by Zachary Webert on 3/25/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

private let manager = RequestManager()
let ChatEndPoint = "join"
let UsersEndPoint = "users"
let AuthenticationEndPoint = "auth"
let PublicRoomsEndPoint = "publicRooms"
let PrivateRoomsEndPoint = "privateRooms"
let RoomsEndPoint = "rooms"
let MessagesEndPoint = "messages"
let RequestsEndPoint = "requests"
class RequestManager: NSObject {
    
    private var _operationManager: AFHTTPRequestOperationManager?
    var operationManager: AFHTTPRequestOperationManager {
        if _operationManager == nil {
            let baseUrl = NSURL(string: EnvironmentManager.sharedManager.baseUrl ?? "")
            _operationManager = AFHTTPRequestOperationManager(baseURL:baseUrl)
            NSLog("\(_operationManager?.baseURL!)")
            _operationManager?.requestSerializer = AFHTTPRequestSerializer()
            _operationManager?.responseSerializer = AFJSONResponseSerializer()
        }
        return _operationManager!
    }

    func cleanDictionary(dictionary:[String:AnyObject?]) -> [String:AnyObject] {
        var cleanDictionary = [String:AnyObject]()
        for (key, optionalValue) in dictionary {
            if let value: AnyObject = optionalValue
            where !(value is NSNull) {
                cleanDictionary[key] = value
            }
        }
        return cleanDictionary
    }
    
    func addParameter(dict: NSMutableDictionary, object: AnyObject?, key: String) {
        if let param: AnyObject = object {
            dict[key] = param
        }
    }
    
    func setAuthToken(token: String?) {
        _operationManager?.requestSerializer.setValue(token, forHTTPHeaderField: "X-Auth-Token")
    }
    
    class func jsonString(dictionary:[String:AnyObject]) -> String {
        if NSJSONSerialization.isValidJSONObject(dictionary) {
            if let data = NSJSONSerialization.dataWithJSONObject(dictionary, options: nil, error: nil) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }
            }
        }
        return ""
    }
    
    class func dictionary(jsonString: String) -> [String:AnyObject] {
        if let stringData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            if let dict = NSJSONSerialization.JSONObjectWithData(stringData, options: nil, error: nil) as? [String:AnyObject] {
                return dict
            }
        }
        return [String:AnyObject]()
    }
    
    
    class var sharedManager: RequestManager {
        return manager
    }
    
    
}
