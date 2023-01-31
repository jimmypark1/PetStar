//
//  BuyViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 8. 14..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import MPSkewed
import AFNetworking
import SwiftyStoreKit


class BuyViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate{

    @IBOutlet weak var titleView:UIView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var priceLabel:UILabel!
    
    var filterSet : FilterSet!
  
    func getFiterPrice()
    {
        var price:String = ""
        
        SwiftyStoreKit.retrieveProductsInfo(["com.petstar.filterpack"]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                self.priceLabel?.text = priceString
                
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
        }
        
    }
    func initTopView()
    {
        
        titleView.layer.shadowColor = UIColor.lightGray.cgColor
        titleView.layer.shadowOpacity = 1
        titleView.layer.shadowOffset = CGSize.zero
        titleView.layer.shadowRadius = 2
        
        titleLabel.font = UIFont(name: "Amaranth", size: 18)
        titleLabel.textColor = UIColor.init(red: 27.0/256.0, green: 147.0/256.0, blue: 216.0/256.0, alpha: 1.0)
        titleLabel.text = "Filter Pack"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTopView()
        imgView.image = UIImage(named: "sample")
        imgView.layer.masksToBounds = true;
        imgView.layer.borderColor = UIColor.black.cgColor;
        imgView.layer.borderWidth = 1;
        imgView.layer.cornerRadius = (imgView?.frame.size.width)! / 2;
        
        getFiterPrice()

        filterSet = FilterSet()

        filterSet.makeVintage()
        filterSet.makeHaze()
        filterSet.makeModern()
        filterSet.makeWdding()
        filterSet.makeStudio()
        filterSet.makeFloral()
        let layout =  collectionView.collectionViewLayout as! MPSkewedParallaxLayout
        layout.itemSize = CGSize(width: self.view.bounds.width, height: 250)
        
      
        collectionView.backgroundColor = UIColor.black
        collectionView.register(MPSkewedCell.classForCoder(), forCellWithReuseIdentifier: "MPSkewedCell")
        
        collectionView.reloadData()
    
     
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func buyFilter()
    {
        SwiftyStoreKit.purchaseProduct("com.petstar.filterpack", quantity: 1, atomically: true) { result in
            
            if case .success(let purchase) = result {
                let user:UserDefaults = UserDefaults.standard
                //  let initSettings:Bool = user.bool(forKey: "isProUpgradePurchased4")
                user.set(true, forKey: "isFilterPurchased")
                user.synchronize()
              
                
                self.dismiss(animated: true, completion: {
                    //  self.takePicture0()
                    // self.performSegue(withIdentifier: "exec_photo0", sender: nil)
                    
                })
            }
            else
            {
                
            }
            
        
        }
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout =  collectionView.collectionViewLayout as! MPSkewedParallaxLayout
        layout.itemSize = CGSize(width: self.view.bounds.width, height: 250)
        
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: self.view.bounds.width, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filterSet.filters.count
       // return (filters?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MPSkewedCell", for: indexPath) as! MPSkewedCell;
        
        let dict:FilterData =  filterSet.filters[indexPath.row] as! FilterData
        
        let thumbStr:String = String(format: "http://www.junsoft.org/pthumb/%@", dict.name as! CVarArg)
        let thumbURL:NSURL = NSURL(string: thumbStr)!
   
       // cell..setImageWith(thumbURL as URL ,placeholderImage:UIImage(named: "sample"))
        cell.text = dict.filterName as NSString 
        
        
        return cell
        
    }

}
