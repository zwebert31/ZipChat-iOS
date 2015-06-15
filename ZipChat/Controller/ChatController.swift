//
//  ChatController.swift
//  ZipChat
//
//  Created by Zachary Webert on 5/9/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//
import UIKit

class ChatController: SLKTextViewController, UITableViewDelegate, UITableViewDataSource, SRWebSocketDelegate {
    
    var messages: [Message] = []
    var room: Room!
    var socket: SRWebSocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.placeholder = "Send a message..."
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerNib(UINib(nibName: "ChatMessageCell", bundle: nil), forCellReuseIdentifier: "message")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //self.navigationItem.title = room.name
        
        //Load chat history
        Message.getMessagesForRoomId(room.roomId, success: { (messages) -> () in
            self.messages = messages
            self.tableView.reloadData()
        }) { (error) -> () in
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.joinRoom(room.roomId, userId: ClientManager.sharedManager.userId ?? -1)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.socket.close()
    }
    
    func joinRoom(roomId: Int, userId: Int) {
        let baseUrl = EnvironmentManager.sharedManager.baseUrl?.stringByReplacingOccurrencesOfString("http://", withString: "ws://") ?? ""
        if let url = NSURL(string:"\(baseUrl)/\(RoomsEndPoint)/\(roomId)/\(ChatEndPoint)?userId=\(userId)") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            self.socket = SRWebSocket(URLRequest: request)
            self.socket.delegate = self;
            self.socket.open()
        }
        
    }
    
    //MARK: - Table view
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("message") as! ChatMessageCell
        let message = self.messages[indexPath.row]
        
        cell.message.text = message.message
        cell.name.text = message.sender.name

        cell.avatar.profileID = String(message.sender.facebookId)

        cell.selectionStyle = .None
        
        cell.transform = self.tableView.transform;
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 108
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    //MARK: - Messages Controller delegate
    override func didPressRightButton(sender: AnyObject!) {
        let messageText = self.textView.text
        super.didPressRightButton(sender)
        self.sendMessage(messageText)
    }
    
    //MARK: - Socket
    func sendMessage(message:String) {
        socket.send(RequestManager.jsonString(["event":"talk", "message":message]))
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        NSLog("Socket Closed")
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        NSLog("Socket Open")
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        NSLog("Socket Failed")
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        NSLog(message.description)
        if let eventString = message as? String {
            let eventDict = RequestManager.dictionary(eventString)
            if eventDict["event"] as? String == "talk" {
                if let messageString = eventDict["message"] as? String {
                    let messageDict = RequestManager.dictionary(messageString)
                    if messageDict["sender"] != nil {
                        let messageObject = Message(dictionary:messageDict)
                        self.messages.insert(messageObject, atIndex:0)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}
