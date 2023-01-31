//
//  MyNavigationController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 17..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class MyNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UIBarButtonItem.appearance()
        appearance.setBackButtonTitlePositionAdjustment(UIOffset.init(horizontal: 0.0, vertical: -60), for: .default)
        self.navigationBar.isTranslucent = true
        self.navigationBar.barTintColor = UIColor.white//UIColor.init(red: 238.0/256.0, green: 247.0/256.0, blue: 252.0/256.0, alpha: 1.0)//UIColor.init(red: 90/255.0, green: 189/255.0, blue: 246/255.0, alpha: 1.0)
        #if swift(>=4.0)
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.init(red: 27.0/255.0, green: 147.0/255.0, blue: 216.0/255.0, alpha: 1.0), NSAttributedStringKey.font:  UIFont(name: "Amaranth", size: 20)]
        #elseif swift(>=3.0)
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName:  UIFont(name: "Amaranth", size: 16)];
        #endif
        let barAppearance =  UINavigationBar.appearance()
        barAppearance.barTintColor = UIColor.white
        self.navigationBar.tintColor = UIColor.white//UIColor.init(red: 27.0/256.0, green: 147.0/256.0, blue: 216.0/256.0, alpha: 1.0)//UIColor.init(red: 238.0/256.0, green: 247.0/256.0, blue: 252.0/256.0, alpha: 1.0)
        self.navigationItem.title = "Pet Star"
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
