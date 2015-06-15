//
//  MyChatsController.swift
//  ZipChat
//
//  Created by Zachary Webert on 5/5/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

class MyChatsController: UITableViewController, TabController {
    
    weak var delegate: HomeController?
    var rooms: [PrivateRoom] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: Selector("updateRooms"), forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateRooms()
    }
    
    //MARK: - Rooms
    func updateRooms() {
        let clientManager = ClientManager.sharedManager
        PrivateRoom.getRooms(clientManager.user.userId, success: { (rooms) -> () in
            self.rooms = rooms
            self.tableView.reloadData()
        }) { (error) -> () in
            NSLog(error.description)
        }
    }
    
    //MARK: - TableView
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let room = rooms[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("privateChatRoom") as! PrivateRoomCell
        
        if let otherUser = room.getOtherUser() {
            cell.name.text = otherUser.name
            cell.avatar.profileID = String(otherUser.facebookId)
        }
        
        cell.timeStamp.text = room.timeSinceLastActivity()
        
        cell.selectionStyle = .None
            
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.showChat(self.rooms[indexPath.row])
    }
}
