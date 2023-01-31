//
//  FilterDelegate.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 9..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

class FilterDelegate: NSObject ,  UICollectionViewDataSource, UICollectionViewDelegate {
    var itemArray:NSMutableArray
    var owner:Any
  //  let manager :SDKManager = SDKManager.sharedManager() as! SDKManager
    
    func documentsDirectoryURL() -> NSURL {
        let manager = FileManager.default
        let URLs = manager.urls(for: .documentDirectory, in: .userDomainMask)
        return URLs[0] as NSURL
    }
    init(items: NSMutableArray,owner:Any) {
        self.itemArray = items
        self.owner = owner
        
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return self.itemArray.count
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbCell", for: indexPath) as! ThumbCell;
        
        
        cell.imgView?.layer.masksToBounds = true;
        cell.imgView?.layer.borderColor =  UIColor.gray.cgColor;
        cell.imgView?.layer.borderWidth = 1;
        cell.imgView?.layer.cornerRadius = (cell.imgView?.frame.size.width)! / 2;
        
        let dict:FilterData =  itemArray[indexPath.row] as! FilterData
        
      //  cell.imgView?.layer.zPosition = 100
     //   cell.imgView?.image = manager.image
        let thumbStr:String = String(format: "http://www.junsoft.org/thumb/%@", dict.name as! CVarArg)
        let thumbURL:NSURL = NSURL(string: thumbStr)!
        cell.imgView?.setImageWith(thumbURL as URL ,placeholderImage:nil)
        
        var rect =  cell.name.frame
        let img_rect =  cell.contentView.frame
        rect.size.width = img_rect.size.width * 0.8
        rect.origin.x = img_rect.origin.x + ( img_rect.size.width - rect.size.width ) / 2.0
        cell.name.frame = rect
        cell.name.textAlignment = .center
        cell.name.text = dict.filterName
        cell.name.textColor =  UIColor.darkGray//UIColor(red: 52.0/255.0,green: 182.0/255.0,blue: 237.0/255.0,alpha: 1.0)
        
       
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
        let user:UserDefaults = UserDefaults.standard
        
        let bBuyFilter:Bool = user.bool(forKey: "isFilterPurchased")
        
        
        let filterData:FilterData =  itemArray[indexPath.row] as! FilterData
        
        if(filterData.type != "ToneCurve" && bBuyFilter == false)
        {
            //processBuy
            (self.owner as! CameraViewController).processBuy()
            
        }
        else
        {
            let cell:ThumbCell = collectionView.cellForItem(at: indexPath) as! ThumbCell
            
            (self.owner as! CameraViewController).processFilter(item: filterData.name, type: filterData.type)
        }
        
     
     
        //
        //
        
        
    }
    
}
