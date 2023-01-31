//
//  ListViewCell.swift
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 9. 19..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

class ListViewCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var user:JUser!
    
}
