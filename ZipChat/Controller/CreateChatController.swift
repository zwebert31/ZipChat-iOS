//
//  CreateChatController.swift
//  ZipChat
//
//  Created by Zachary Webert on 5/10/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

class CreateChatController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: UIBarButtonItemStyle.Done, target: self, action: Selector("createPressed:"))
    }
}
