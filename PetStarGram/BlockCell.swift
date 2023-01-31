//
//  BlockCell.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 8. 30..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

class BlockCell: UICollectionViewCell {
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var unblockBt:UIButton!
    
    var uid:String!
    var user:JUser!
    var owner: BlockUserViewController!
    @IBAction func unblock()
    {
        UserService.deleteBlockedUser(user: self.user)
        self.owner.configure()
    }
    
}
