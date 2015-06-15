//
//  RequestsController.swift
//  ZipChat
//
//  Created by Zachary Webert on 5/12/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

class RequestsController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    let timeFormatter = TTTTimeIntervalFormatter()
    
    var requests: [Request] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateRequests()
    }
    
    //MARK: - Requests
    func updateRequests() {
        let clientManager = ClientManager.sharedManager
        Request.getRequestsForReceiver(clientManager.user.userId, success: { (requests) -> () in
            self.requests = requests
            self.tableView.reloadData()
            }) { (error) -> () in
                NSLog(error.description)
        }
    }
    
    func respondToRequest(cell: RequestCell, response: RequestStatus) {
        if let indexPath: NSIndexPath = self.tableView.indexPathForCell(cell) {
            let request = requests[indexPath.row]
            
        Request.respondToRequest(request.requestId, responseStatus: response, success: { () -> () in
            self.updateRequests()
            return
        }, failure: { (error) -> () in
            NSLog(error.description)
        })
        }
    }
    
    //MARK: - Table View
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RequestCell") as! RequestCell
        let request = requests[indexPath.row]
        cell.name.text = request.sender.name
        cell.avatar.profileID = String(request.sender.facebookId)
        cell.timestamp.text = self.timeFormatter.stringForTimeInterval(request.timeSinceLastActivity())
        return cell
    }
    
}
