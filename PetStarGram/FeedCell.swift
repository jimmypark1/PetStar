//
//  FeedCell.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 4..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import MaterialComponents

class FeedCell: MDCCollectionViewCell {
   
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var play: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var likeCnt: UILabel!
    @IBOutlet weak var viewCnt: UILabel!
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgView.isHidden = false
     //   data = nil
    }
}
