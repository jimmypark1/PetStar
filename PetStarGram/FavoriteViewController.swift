//
//  FavoriteViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 18..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title  = "Favorites"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        
    }

}
