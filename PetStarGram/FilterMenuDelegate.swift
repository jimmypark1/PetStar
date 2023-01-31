//
//  FilterMenuDelegate.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 9..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

class FilterMenuDelegate: NSObject,UICollectionViewDataSource, UICollectionViewDelegate {
    
    //   var itemArray:NSArray
    //   var dataDict:NSDictionary
    
    var owner:Any
    var oldIndex:Int
    var oldIndexPath:NSIndexPath
    
    init(owner:Any) {
        self.owner = owner
        // var items:[String] //= self.dataDict["item"]
        self.oldIndex = -1
        self.oldIndexPath = NSIndexPath(index: 0)
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return 7//self.itemArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbCell", for: indexPath) as! ThumbCell;
        
      //  cell.indicator?.isHidden = true
        cell.imgView?.image = UIImage(named: "button")
        
        let index = indexPath.row
        
        if(index == 0)
        {
            cell.name?.text = "Basic"
        }
        if(index == 1)
        {
            cell.name?.text = "Vintage"
        }
        if(index == 2)
        {
            cell.name?.text = "Haze"
        }
        if(index == 3)
        {
            cell.name?.text = "Modern"
        }
        if(index == 4)
        {
            cell.name?.text = "Wedding"
        }
        if(index == 5)
        {
            cell.name?.text = "Studio"
        }
        if(index == 6)
        {
            cell.name?.text = "Floral"
        }
        if( indexPath.row == self.oldIndex)
        {
            cell.name?.textColor = UIColor.black//UIColor(red: 25.0/255.0, green: 159.0/255.0, blue: 216.0/255.0, alpha: 1.0)//UIColor(red: 243.0/255.0, green: 188.0/255.0, blue: 81.0/255.0, alpha: 1.0)
            //  oldIndexPath = indexPath as NSIndexPath
            
        }
        else if( indexPath.row == 0 && self.oldIndex == -1)
        {
            cell.name?.textColor = UIColor.black//UIColor(red: 25.0/255.0, green: 159.0/255.0, blue: 216.0/255.0, alpha: 1.0)//UIColor(red: 243.0/255.0, green: 188.0/255.0, blue: 81.0/255.0, alpha: 1.0)
            //  oldIndexPath = indexPath as NSIndexPath
            
        }
        else
        {
            cell.name?.textColor = UIColor.lightGray//UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            
        }
        
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath)
    {
        
        let cell:ThumbCell = collectionView.cellForItem(at: indexPath) as! ThumbCell
        cell.name?.textColor = UIColor.lightGray//UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
        let cell:ThumbCell = collectionView.cellForItem(at: indexPath) as! ThumbCell
        
        
        let user:UserDefaults = UserDefaults.standard
        
        let bBuyFilter:Bool = user.bool(forKey: "isFilterPurchased")
        
        
        if(indexPath.row != 0  && bBuyFilter == false)
        {
            (self.owner as! CameraViewController).processBuy()
            
        }
        else
        {
            cell.name?.textColor = UIColor.black//UIColor(red: 25.0/255.0, green: 159.0/255.0, blue: 216.0/255.0, alpha: 1.0)//UIColor(red: 243.0/255.0, green: 188.0/255.0, blue: 81.0/255.0, alpha: 1.0)
            
            (self.owner as! CameraViewController).makeFilterList(category: indexPath.row)
            self.oldIndex = indexPath.row
            self.oldIndexPath = indexPath as NSIndexPath
            
            user.set(indexPath.row, forKey: "FILTER_MENU")
            
            collectionView.reloadData()
        }
        
    
    }
        
}
