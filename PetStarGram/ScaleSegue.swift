//
//  ScaleSegue.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 17..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

class ScaleSegue: UIStoryboardSegue {
    var fadeTransition: FadeTransition!
    override func perform()
    {
       
        scale()
        
    }
    func scale()
    {
        let toViewController = self.destination
        let fromViewController = self.source
        
        fadeTransition = FadeTransition()
        
        fromViewController.transitioningDelegate = fadeTransition as! UIViewControllerTransitioningDelegate
        
        // Adjust the transition duration. (seconds)
     //   fadeTransition.duration = 1.0

    }

}
