//
//  NearByController.swift
//  ZipChat
//
//  Created by Zachary Webert on 5/5/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit
import CoreLocation

class NearByController: UITableViewController, TabController {

    let filters = [Filter.Distance.rawValue, Filter.Activity.rawValue]
    let timeFormatter = TTTTimeIntervalFormatter()
    
    weak var delegate: HomeController?
    var rooms: [PublicRoom] = []
    var filter: Filter = .Distance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: Selector("refreshTable:"), forControlEvents: UIControlEvents.ValueChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("locationFound:"), name: DidFindLocationNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //setup filter control
        let filterControl = UISegmentedControl(items: filters)
        filterControl.selectedSegmentIndex = find(filters, self.filter.rawValue) ?? 0
        filterControl.addTarget(self, action: Selector("filterChanged:"), forControlEvents: .ValueChanged)
        self.delegate?.navigationItem.titleView = filterControl
        self.sortByFilter()
        self.tableView.reloadData()
        
        //setup add button
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addPressed:"))
        self.delegate?.navigationItem.rightBarButtonItem = addButton
    }
    
    //MARK: - Location
    func locationFound(notification: NSNotification) {
        PublicRoom.getRoomsWithLocation(notification.object as! CLLocation, success: { (rooms: [PublicRoom]) -> () in
            self.rooms = rooms
            self.sortByFilter()
            self.tableView.reloadData()
            return
        }) { (error) -> () in
            
        }
        self.refreshControl?.endRefreshing()
    }
    
    //MARK: - Sorting
    func sortRoomsByDistance() {
        if let location = self.delegate?.currentLocation {
            self.rooms.sort { (roomA, roomB) -> Bool in
                roomA.location.distanceFromLocation(location) < roomB.location.distanceFromLocation(location)
            }
        }
    }
    
    func sortRoomsByActivity() {
        if let location = self.delegate?.currentLocation {
            self.rooms.sort { (roomA, roomB) -> Bool in
                roomA.lastActivity > roomB.lastActivity
            }
        }
    }
    
    func sortByFilter() {
        switch self.filter {
        case .Activity:
            self.sortRoomsByActivity()
        case .Distance:
            self.sortRoomsByDistance()
        }
    }
    
    //MARK: - Navigation Bar
    func addPressed(sender: AnyObject) {
        self.delegate?.addChatRoom(sender)
    }

    func filterChanged(sender: UISegmentedControl) {
        if let filter = Filter(rawValue: sender.titleForSegmentAtIndex(sender.selectedSegmentIndex) ?? "") {
            self.filter = filter
            self.sortByFilter()
            self.tableView.reloadData()
        }
    }
    
    //MARK: - TableView
    
    func refreshTable(sender:AnyObject) {
        self.delegate?.searchForLocation()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rooms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatRoom") as! PublicRoomCell
        let room = rooms[indexPath.row]

        if let location = self.delegate?.currentLocation {
            cell.name.text = room.name
            cell.distance.text = String(format: "%im", Int(location.distanceFromLocation(room.location)))
            cell.timestamp.text = room.timeSinceLastActivity()
            cell.selectionStyle = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.showChat(self.rooms[indexPath.row])
    }
    
    
}
