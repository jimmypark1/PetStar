//
//  FilterShowViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 8. 22..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import AFNetworking

class FilterShowViewController: UIViewController {
    var filterSet : FilterSet!
    var imagesArraySlideshow : [UIImage] = []
    var slideShowIndex:NSInteger = 0
    var slideShowMax:NSInteger = 0
    
    @IBOutlet weak var ivSlideshow:UIImageView!
    @IBOutlet weak var top:NSLayoutConstraint!
    
    var end:Bool!
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.end = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ivSlideshow.layer.masksToBounds = true
        ivSlideshow.layer.cornerRadius = ivSlideshow.frame.size.width/2.0
        ivSlideshow.layer.borderColor = UIColor.black.cgColor
        ivSlideshow.layer.borderWidth = 2
        
        filterSet = FilterSet()
        
        filterSet.makeVintage()
        filterSet.makeHaze()
        filterSet.makeModern()
        filterSet.makeWdding()
        filterSet.makeStudio()
        filterSet.makeFloral()
        end = false
        buildImagesArraySlideshow()
      
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        top.constant = (self.view.frame.size.height - 400 ) / 2.0
    }
    func buildImagesArraySlideshow(){
        // example: localImageFilePath:URL = *URLs FOR SOME LOCAL IMAGE FILES*
        
        for i in 45 ... 150
        {
         
            let dict:FilterData =  self.filterSet.filters[i] as! FilterData
            
         //   imagesArraySlideshow.setImageWith(thumbURL as URL ,placeholderImage:UIImage(named: "sample"))
            var name : String = dict.name
            print(name)
            let image = UIImage(named: name)
            if(image != nil)
            {
                imagesArraySlideshow.append(image!)
                
            }
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.end = false
        self.slideShowMax = self.imagesArraySlideshow.count
        DispatchQueue.global(qos: .userInteractive).async (
            execute: {() -> Void in
                while self.end == false {
                    print ("MAX:"+String(self.slideShowMax))
                    
                    DispatchQueue.main.async(execute: {() -> Void in
                        let toImage = self.imagesArraySlideshow[self.slideShowIndex]
                        print ("index:"+String(self.slideShowIndex))
                        UIView.transition(
                            with: self.ivSlideshow,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: {self.ivSlideshow.image = toImage},
                            completion: nil
                        )
                    })
                    self.slideShowIndex += 1
                    if self.slideShowIndex == self.slideShowMax {
                        self.slideShowIndex = 0
                    }
                    sleep(1)
                }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
