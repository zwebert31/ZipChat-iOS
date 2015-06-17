//
//  Message.swift
//  ZipChat
//
//  Created by Zachary Webert on 5/9/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

class Message: NSObject {
    var messageId: Int!
    var sender: User!
    var message: String?
    var timeStamp: Int!
    
    override init() {}
    
    init(dictionary:[String:AnyObject]) {
        if let messageId = dictionary["messageId"] as? Int {
            self.messageId = messageId
        }
        
        if let sender = dictionary["sender"] as? [String:AnyObject] {
            self.sender = User(dictionary: sender)
        }
        
        if let message = dictionary["message"] as? String {
            self.message = message
        }
        
        if let timeStamp = dictionary["timeStamp"] as? Int {
            self.timeStamp = timeStamp
        }
    }
    
    class func getMessagesForRoomId(roomId: Int, success:((messages: [Message])->())?, failure:((error: NSError)->())?) {
        let clientManager = ClientManager.sharedManager
        let requestManager = RequestManager.sharedManager
        
        let endpoint = "\(PublicRoomsEndPoint)/\(roomId)/\(MessagesEndPoint)"
        NSLog(endpoint)
        requestManager.operationManager.GET(endpoint, parameters:["limit":100, "offset":0], success: { (operation, response) -> Void in
            var messages = [Message]()
            for messageData in (response as? [[String:AnyObject]] ?? []) {
                let message = Message(dictionary: messageData)
                messages.insert(message, atIndex: 0)
            }
            success?(messages: messages)
            return
            }) { (operation, error) -> Void in
                failure?(error: error)
                NSLog(error.localizedDescription)
        }
    }
}
