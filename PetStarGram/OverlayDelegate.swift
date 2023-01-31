//
//  OverlayDelegate.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 8. 3..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

class OverlayDelegate: NSObject  ,  UICollectionViewDataSource, UICollectionViewDelegate {
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
        cell.imgView?.layer.borderColor = UIColor.gray.cgColor;
        cell.imgView?.layer.borderWidth = 1;
        cell.imgView?.layer.cornerRadius = (cell.imgView?.frame.size.width)! / 2;
        
        let dict:FilterData =  itemArray[indexPath.row] as! FilterData
        
        //  cell.imgView?.layer.zPosition = 100
        //   cell.imgView?.image = manager.image
        let thumbStr:String = String(format: "http://www.junsoft.org/thumb/%@", dict.name as! CVarArg)
        let thumbURL:NSURL = NSURL(string: thumbStr)!
        cell.imgView?.setImageWith(thumbURL as URL ,placeholderImage:nil)
      //  cell.name.text = dict.filterName
      //  cell.name.textColor = UIColor.darkGray
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
        let filterData:FilterData =  itemArray[indexPath.row] as! FilterData
        
        let cell:ThumbCell = collectionView.cellForItem(at: indexPath) as! ThumbCell
        
        (self.owner as! CameraViewController).processOverlay(item: filterData.name, type: filterData.type)
        
    }
    
}
