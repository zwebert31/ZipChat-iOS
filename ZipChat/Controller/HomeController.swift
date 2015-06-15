//
//  HomeController.swift
//  ZipChat
//
//  Created by Zachary Webert on 5/5/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit
import CoreLocation

@objc
protocol TabController {
    weak var delegate: HomeController? {get set}
}

enum Filter: String {
    case Activity = "Activity"
    case Distance = "Distance"
}

let DidFindLocationNotification = "didFindLocation"

class HomeController: UITabBarController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var filter: Filter = .Distance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigation bar
        self.navigationController?.navigationBarHidden = false;
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        //tab bar
        self.tabBar.tintColor = ColorManager.blueColor()
        
        //location manager
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.distanceFilter = 100
        
        for controller in self.viewControllers ?? [] {
            if let vc = controller as? TabController {
                vc.delegate = self
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.searchForLocation()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChat" {
            if let room = sender as? Room {
                if let vc = segue.destinationViewController as? ChatController {
                    vc.room = room
                }
            }
        }
    }
    
    func showChat(room: Room) {
        self.performSegueWithIdentifier("showChat", sender: room)
    }
    
    func addChatRoom(sender: AnyObject) {
        self.performSegueWithIdentifier("showAddChat", sender: nil)
    }
    
    //MARK: - Tab Bar
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        self.navigationItem.title = nil
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
    }
    
    //MARK: - Location Manager
    
    func searchForLocation() {
        NSLog("Search For Location")
        self.locationManager.stopUpdatingLocation()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        NSLog("Location Manager Failed: \(error.description)")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last as? CLLocation {
            NSLog("Did update locations, accuracy: %i", location.horizontalAccuracy)
            NSNotificationCenter.defaultCenter().postNotificationName(DidFindLocationNotification, object: location)
            self.currentLocation = location
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
}
