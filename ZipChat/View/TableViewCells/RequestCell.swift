//
//  RequestCell.swift
//  ZipChat
//
//  Created by Zachary Webert on 5/13/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

class RequestCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var avatar: AvatarView!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var delegate: RequestsController?
    
    @IBAction func acceptPressed(sender: UIButton) {
        delegate?.respondToRequest(self, response: .Accepted)
    }
    
    @IBAction func denyPressed(sender: UIButton) {
        delegate?.respondToRequest(self, response: .Denied)
    }
}
