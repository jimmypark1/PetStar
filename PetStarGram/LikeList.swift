//
//  LikeList.swift
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 9. 19..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

class LikeList: NSObject {
    
    var postKey:String!
    var list:[String:Any]!
    init(postKey: String, list: [String:Any]) {
       
        self.postKey = postKey
        self.list = list
        
    }
}
