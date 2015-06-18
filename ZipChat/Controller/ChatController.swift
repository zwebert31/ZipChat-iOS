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
    var socket: SRWebSocket!
    var room: Room!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.placeholder = "Send a message..."
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerNib(UINib(nibName: "ChatMessageCell", bundle: nil), forCellReuseIdentifier: "message")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.textInputbar.leftButton.setImage(UIImage(named: "nearby"), forState: .Normal)
        
        //Load chat history
        self.loadMessages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let userId = ClientManager.sharedManager.user?.userId,
           let authToken = ClientManager.sharedManager.user?.authToken
        {
            self.joinRoom(room.roomId, userId: userId, authToken: authToken)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.socket.close()
    }
    
    func joinRoom(roomId: Int, userId: Int, authToken: String) {
        assertionFailure("Implement join room in subclass")
    }
    
    func loadMessages() {
        assertionFailure("Implement load messages in subclass")
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
