//
//  PublicChatController.swift
//  ZipChat
//
//  Created by Zachary Webert on 6/17/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

class PublicChatController: ChatController {
    
    var anonymous: Bool = false {
        didSet {
            if !self.anonymous {
                self.user?.getProfileImage({ (profile) -> () in
                    self.setLeftButtonImage(profile)
                })
            } else {
                let image = UIImage(named: "Spy_64")?.imageWithRenderingMode(.AlwaysOriginal)
                self.setLeftButtonImage(image!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.anonymous = false
    }
    
    
    //MARK: - Messages
    override func loadMessages() {
        Message.getMessagesForRoomId(room.roomId, success: { (messages) -> () in
                self.messages = messages
                self.tableView.reloadData()
            }) { (error) -> () in
                NSLog(error.localizedDescription)
        }
    }
    
    //MARK: - Messages Controller Delegate
    override func didPressLeftButton(sender: AnyObject!) {
        self.anonymous = !self.anonymous
    }
    
    //MARK: - Socket
    override func joinRoom(roomId: Int, userId: Int, authToken: String) {
        let baseUrl = EnvironmentManager.sharedManager.baseUrl?.stringByReplacingOccurrencesOfString("http://", withString: "ws://") ?? ""
        
        if let url = NSURL(string:"\(baseUrl)/\(PublicRoomsEndPoint)/\(roomId)/\(ChatEndPoint)?userId=\(userId)&authToken=\(authToken)") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            self.socket = SRWebSocket(URLRequest: request)
            self.socket.delegate = self;
            self.socket.open()
        }
    }
    

}
