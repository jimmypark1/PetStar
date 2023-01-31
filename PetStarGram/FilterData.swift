//
//  FilterData.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 9..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

class FilterData: NSObject {
    var name:String = ""
    var filterName:String = ""
    var thumb:String = ""
    var type:String = ""
    var category:String = ""
    
    init(name:String,filterName:String, thumb:String, type:String, category:String) {
        
        self.name = name
        self.thumb = thumb
        self.type = type
        self.filterName = filterName
        self.category = category
        
        super.init()
    }
}
