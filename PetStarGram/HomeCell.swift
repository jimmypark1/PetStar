//
//  HomeCell.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 13..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import Material

class HomeCell: UICollectionViewCell {
  
    open var imageView: UIImageView!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareImageView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepareImageView()
    }
    
}
extension HomeCell {
    fileprivate func prepareImageView() {
        imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        contentView.clipsToBounds = true
        contentView.layout(imageView).edges()
    }
}
