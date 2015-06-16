//
//  LoginController.swift
//  ZipChat
//
//  Created by Zachary Webert on 3/24/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

class LoginController: UIViewController, FBLoginViewDelegate {

    @IBOutlet weak var loginView: FBLoginView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginView?.delegate = self;
        self.loginView?.readPermissions = ["public_profile"];
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loginView?.delegate = self;
        self.navigationController?.navigationBarHidden = true;
    }

    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        self.loginView?.delegate = nil
        let clientManager: ClientManager = ClientManager.sharedManager
       
        let accessToken = FBSession.activeSession().accessTokenData.accessToken
        if let user = clientManager.user {
            User.authenticateUserWithSuccess(accessToken, success: { (authToken) -> () in
                clientManager.user?.authToken = authToken
                clientManager.saveUser()
                self.performSegueWithIdentifier("showHome", sender: self)
            }, failure: { (error) -> () in
                NSLog(error.localizedDescription)
            })    
        } else {
            User.createUserWithSuccess(accessToken, success: { (user) -> () in
                clientManager.user = user
                self.performSegueWithIdentifier("showHome", sender: self)
            }, failure: { (error) -> () in
                NSLog(error.localizedDescription)
            })
        }
    }
}
