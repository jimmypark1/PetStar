//
//  NewMsgCell.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 8. 21..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

protocol NewMsgCellDelegate: class {
    func didTabNewMsg(_ user:JUser)
}

class NewMsgCell: UICollectionViewCell {
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var sendBt:UIButton!
    
    var selectedUser:JUser!
    var owner: NewMsgListViewController!
    weak var delegate: NewMsgCellDelegate?
    
    
    @IBAction func didTabNewMsg(_ sender: UIButton)
    {
        print(self.delegate)
        self.delegate?.didTabNewMsg(self.selectedUser)
        
     //   self.owner.processNewMsg(user: self.selectedUser)
    }

}
