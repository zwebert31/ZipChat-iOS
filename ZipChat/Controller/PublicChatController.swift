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
    
    //MARK: - Messages Controller Delegate
    override func didPressLeftButton(sender: AnyObject!) {
        self.anonymous = !self.anonymous
    }
}
