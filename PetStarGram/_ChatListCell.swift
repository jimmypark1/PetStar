//
//  ChatListCell.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 19..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import MaterialComponents

class ChatListCell: MDCCollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var fromImg: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var alarm: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
