//
//  ChatController.swift
//  ZipChat
//
//  Created by Zachary Webert on 5/9/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//
import UIKit

enum ChatEvent: String {
    case Message = "talk"
    case Favorite = "favorite"
    case Join = "join"
}

class ChatController: SLKTextViewController, UITableViewDelegate, UITableViewDataSource, SRWebSocketDelegate {
    
    var messages: [Message] = []
    var socket: SRWebSocket!
    var room: Room!
    let user: User? = ClientManager.sharedManager.user
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.placeholder = "Send a message..."
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerNib(UINib(nibName: "ChatMessageCell", bundle: nil), forCellReuseIdentifier: "message")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //Load chat history
        self.loadMessages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let userId = self.user?.userId,
           let authToken = self.user?.authToken
        {
            self.joinRoom(room, userId: userId, authToken: authToken)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.socket.close()
    }
    
    func joinRoom(room: Room, userId: Int, authToken: String) {
        let baseUrl = EnvironmentManager.sharedManager.baseUrl?.stringByReplacingOccurrencesOfString("http://", withString: "ws://") ?? ""
        
        if let url = NSURL(string:"\(baseUrl)/\(room.isPublic ? PublicRoomsEndPoint : PrivateRoomsEndPoint)/\(room.roomId)/\(ChatEndPoint)?userId=\(userId)&authToken=\(authToken)") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            self.socket = SRWebSocket(URLRequest: request)
            self.socket.delegate = self;
            self.socket.open()
        }
    }
    
    func loadMessages() {
        Message.getMessagesForRoom(room, limit: 100, offset: 0, success: { (messages) -> () in
            self.messages = messages
            self.tableView.reloadData()
            }) { (error) -> () in
                NSLog(error.localizedDescription)
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
        if let eventString = message as? String
        {
            let eventDict = RequestManager.dictionary(eventString)
            if let eventTypeString = eventDict["event"] as? String,
               let event = ChatEvent(rawValue:eventTypeString) {
                switch event {
                case .Message:
                    if let messageString = eventDict["message"] as? String {
                        self.handleMessageEvent(RequestManager.dictionary(messageString))
                    }
                default:
                    return
                }
            }
            
        }
    }
    
    func handleMessageEvent(messageDict:[String:AnyObject]) {
        if messageDict["sender"] != nil {
            let messageObject = Message(dictionary:messageDict)
            self.messages.insert(messageObject, atIndex:0)
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Helper Methods
    
    func setLeftButtonImage(image: UIImage) {
        self.textInputbar.leftButton.setImage(image, forState: .Normal)
        self.textInputbar.leftButton.imageView?.layer.borderColor = ColorManager.blueColor().CGColor
        self.textInputbar.leftButton.imageView?.layer.borderWidth = 2
        self.textInputbar.leftButton.imageView?.layer.cornerRadius = image.size.width/2
    }
}
