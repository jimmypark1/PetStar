//
//  FindFriendsCell.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 12..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import MaterialComponents

protocol FindFriendsCellDelegate: class {
    func didTapFollowButton(_ followButton: UIButton, on cell: FindFriendsCell)
}

class FindFriendsCell: MDCCollectionViewCell {
    
    weak var delegate: FindFriendsCellDelegate?
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profile: UIImageView!
   
    
    var index :Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // index = -1
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        delegate?.didTapFollowButton(sender, on: self)
        
    }
}
