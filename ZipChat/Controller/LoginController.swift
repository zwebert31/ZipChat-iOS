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
        self.loginView?.readPermissions = ["public_profile", "user_friends"];
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true;
    }

    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        loginView.delegate = nil
        let clientManager: ClientManager = ClientManager.sharedManager
        clientManager.user.name = user.name
        clientManager.user.facebookId = user.objectID.toInt()
        if clientManager.userId == nil {
            User.createUserWithSuccess({ (userId) -> () in
                clientManager.userId = userId
                clientManager.user.userId = userId
                self.performSegueWithIdentifier("showHome", sender: self)
                }, failure: { (error) -> () in
                    NSLog(error.localizedDescription)
            })
        } else {
            clientManager.user.userId = clientManager.userId
            self.performSegueWithIdentifier("showHome", sender: self)
        }
    }
}
