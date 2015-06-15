//
//  Request.swift
//  ZipChat
//
//  Created by Zachary Webert on 5/12/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

enum RequestStatus: String {
    case Pending = "pending"
    case Accepted = "accepted"
    case Denied = "denied"
    case None = "none"
}
class Request: NSObject {
    var requestId: Int!
    var sender: User!
    var receiver: User!
    var message: String?
    var status: RequestStatus!
    var timeStamp: Int!
    var respondedTimeStamp: Int?
    
    init(dictionary:[String:AnyObject]) {
        if let requestId = dictionary["requestId"] as? Int {
            self.requestId = requestId
        }
        
        if let sender = dictionary["sender"] as? [String:AnyObject] {
            self.sender = User(dictionary: sender)
        }
        
        if let receiver = dictionary["receiver"] as? [String:AnyObject] {
            self.receiver = User(dictionary: receiver)
        }
        
        if let message = dictionary["message"] as? String {
            self.message = message
        }
        
        if let status = dictionary["status"] as? String {
            self.status = RequestStatus(rawValue: status)
        }
        
        if let timeStamp = dictionary["timeStamp"] as? Int {
            self.timeStamp = timeStamp
        }
        
        if let respondedTimeStamp = dictionary["respondedTimeStamp"] as? Int {
            self.respondedTimeStamp = respondedTimeStamp
        }
    }
    
    func timeSinceLastActivity() -> NSTimeInterval {
        let seconds = NSTimeInterval(self.timeStamp) - NSDate().timeIntervalSince1970
        return seconds;
    }
    
    class func getRequestsForReceiver(receiverUserId: Int, success:((requests: [Request])->())?, failure:((error: NSError)->())?) {
        let clientManager = ClientManager.sharedManager
        let requestManager = RequestManager.sharedManager
        
        requestManager.operationManager.GET(RequestsEndPoint, parameters: ["userId": receiverUserId], success: { (operation, response) -> Void in
            var requests = [Request]()
            for requestData in (response as? [[String:AnyObject]] ?? []) {
                let request = Request(dictionary: requestData)
                requests.append(request)
            }
            success?(requests:requests)
            return
            }) { (operation, error) -> Void in
                failure?(error: error)
                NSLog(error.localizedDescription)
        }
    }

    class func getRequestStatus(receiverId: Int, success:((status: RequestStatus)->())?, failure:((error: NSError)->())?) {
        let requestManager = RequestManager.sharedManager
        let clientManager = ClientManager.sharedManager
        requestManager.operationManager.GET("\(RequestsEndPoint)/status", parameters: ["senderId":clientManager.user.userId, "receiverId":receiverId], success: { (operation, response) -> Void in
            if let statusString = response as? String {
                if let status = RequestStatus(rawValue: statusString) {
                    success?(status: status)
                }
            }
            }) { (operation, error) -> Void in
                failure?(error:error)
        }
    }
    
    class func respondToRequest(requestId: Int, responseStatus: RequestStatus, success:(()->())?, failure:((error: NSError)->())?) {
        let requestManager = RequestManager.sharedManager
        
        requestManager.operationManager.PUT("\(RequestsEndPoint)/\(requestId)", parameters: ["status":responseStatus.rawValue], success: { (operation, response) -> Void in
            success?()
        }) { (operation, error) -> Void in
            failure?(error:error)
        }
    }
    
    class func sendRequest(receiverId: Int, success:((request: Request)->())?, failure:((error: NSError)->())?) {
        let requestManager = RequestManager.sharedManager
        let clientManager = ClientManager.sharedManager
        requestManager.operationManager.POST(RequestsEndPoint, parameters: ["sender":clientManager.user.userId, "receiver":receiverId], success: { (operation, response) -> Void in
            if let requestData = response as? [String:AnyObject] {
                success?(request: Request(dictionary:requestData))
            }
            }) { (operation, error) -> Void in
                failure?(error:error)
        }
    }
    
}
