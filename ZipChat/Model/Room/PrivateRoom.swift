//
//  PrivateRoom.swift
//  ZipChat
//
//  Created by Zachary Webert on 5/18/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

class PrivateRoom: Room {
    var sender: User!
    var receiver: User!
    var senderInRoom: Bool!
    var receiverInRoom: Bool!
    var request: Request!
    
    override var isPublic: Bool {
        return false
    }
    
    override init(dictionary:[String:AnyObject]) {
        super.init(dictionary: dictionary)
        if let sender = dictionary["sender"] as? [String:AnyObject] {
            self.sender = User(dictionary: sender)
        }
        
        if let receiver = dictionary["receiver"] as? [String:AnyObject] {
            self.receiver = User(dictionary: receiver)
        }
        
        if let senderInRoom = dictionary["senderInRoom"] as? Bool {
            self.senderInRoom = senderInRoom
        }

        if let receiverInRoom = dictionary["receiverInRoom"] as? Bool {
            self.receiverInRoom = receiverInRoom
        }
        
        if let request = dictionary["request"] as? [String:AnyObject] {
            self.request = Request(dictionary:request)
        }
    }
    
    func getOtherUser() -> User? {
        let clientManager = ClientManager.sharedManager
        let userId = clientManager.user?.userId
        if sender.userId == userId {
            return receiver
        } else if receiver.userId == userId {
            return sender
        }
        return nil
    }
    
    class func getRooms(userId: Int, success:((rooms: [PrivateRoom])->())?, failure:((error: NSError)->())?) {
        let clientManager = ClientManager.sharedManager
        let requestManager = RequestManager.sharedManager
        
        requestManager.operationManager.GET(PrivateRoomsEndPoint, parameters: ["userId":userId], success: { (operation, response) -> Void in
            var rooms = [PrivateRoom]()
            for roomData in (response as? [[String:AnyObject]] ?? []) {
                let room = PrivateRoom(dictionary: roomData)
                rooms.append(room)
            }
            success?(rooms:rooms)
            return
            }) { (operation, error) -> Void in
                failure?(error: error)
                NSLog(error.localizedDescription)
        }
    }
    
    
}
