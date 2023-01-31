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
    @IBOutlet weak var postImage: UIImageView!
    
    var cellDelegate : ChatListViewController!
    var likeList:LikeList!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        postImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPost))
        postImage.addGestureRecognizer(tapGesture)
        
    }
    @objc func tapPost() {
        
        //
        print("Please tapPost!")
        cellDelegate.viewLikePost(list: self.likeList)
      //  performSegue(withIdentifier: "exec_privacy", sender: nil)
        
        
    }
}
