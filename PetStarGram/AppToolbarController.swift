//
//  AppToolbarController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 13..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import Material

class AppToolbarController: ToolbarController {

    open override func prepare() {
        super.prepare()
        //rootViewController  = HomeViewController()
       // self.rootViewController = HomeViewController()
        isMotionEnabled = true
        
        toolbar.depthPreset = .none
        toolbar.dividerColor = Color.grey.lighten2
    }

}
