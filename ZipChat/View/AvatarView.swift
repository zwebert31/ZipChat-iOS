//
//  AvatarView.swift
//  ZipChat
//
//  Created by Zachary Webert on 5/18/15.
//  Copyright (c) 2015 Zachary Webert. All rights reserved.
//

import UIKit

class AvatarView: SMFBProfileImageView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.pictureCropping = FBProfilePictureCropping.Square;
        self.layer.cornerRadius = self.frame.size.height/2;
        self.layer.borderWidth = 2;
        self.layer.borderColor = ColorManager.blueColor().CGColor;
    }


}
