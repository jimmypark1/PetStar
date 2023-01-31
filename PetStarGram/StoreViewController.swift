//
//  StoreViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 8. 13..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import SwiftyStoreKit


class StoreViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var titleView:UIView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var adPrice:UILabel!
    @IBOutlet weak var waterPrice:UILabel!
    @IBOutlet weak var filterPrice:UILabel!
    @IBOutlet var titleHeight:NSLayoutConstraint!
    @IBOutlet var closeTop:NSLayoutConstraint!
    @IBOutlet var titleTop:NSLayoutConstraint!
    
    
    var filters:NSMutableArray!
    
    func initTopView()
    {
        var offset:CGFloat = 0.0
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
            case 1334:
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X")
                offset = 20.0
            default:
                print("unknown")
            }
        }
        /*
        titleHeight.constant =  titleHeight.constant + offset
        closeTop.constant =  closeTop.constant + offset
        titleTop.constant =  titleTop.constant + offset
        
        */
        
        titleView.layer.shadowColor = UIColor.lightGray.cgColor
        titleView.layer.shadowOpacity = 1
        titleView.layer.shadowOffset = CGSize.zero
        titleView.layer.shadowRadius = 2
        
        titleLabel.font = UIFont(name: "Amaranth", size: 18)
        titleLabel.textColor = UIColor.init(red: 27.0/256.0, green: 147.0/256.0, blue: 216.0/256.0, alpha: 1.0)
        titleLabel.text = "Store"
        
    }
    func getFiterPrice()
    {
        var price:String = ""
        
        SwiftyStoreKit.retrieveProductsInfo(["com.petstar.filterpack"]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                self.filterPrice?.text = priceString
                
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
    func getADPrice()
    {
        var price:String = ""
        
        SwiftyStoreKit.retrieveProductsInfo(["com.petstar.removead"]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                self.adPrice?.text = priceString
                
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
    func getWaterPrice()
    {
        var price:String = ""
        
        SwiftyStoreKit.retrieveProductsInfo(["com.petstar.watermark"]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                self.waterPrice?.text = priceString
                
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
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        filters = NSMutableArray()
        
        getFiterPrice()
        getWaterPrice()
        getADPrice()
        initTopView()
        makeBasic()
        makeVintage()
        makeHaze()
        makeModern()
        makeStudio()
        makeFloral()
        makeWdding()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func buyFilter()
    {
        SwiftyStoreKit.purchaseProduct("com.petstar.filterpack", quantity: 1, atomically: true) { result in
          
            if case .success(let purchase) = result {
                let user:UserDefaults = UserDefaults.standard
                //  let initSettings:Bool = user.bool(forKey: "isProUpgradePurchased4")
                user.set(true, forKey: "isFilterPurchased")
                user.synchronize()
            }
            
            
           
        }
    }
    @IBAction func buyAD()
    {
        SwiftyStoreKit.purchaseProduct("com.petstar.removead", quantity: 1, atomically: true) { result in
            
            if case .success(let purchase) = result {
                let user:UserDefaults = UserDefaults.standard
                //  let initSettings:Bool = user.bool(forKey: "isProUpgradePurchased4")
                user.set(true, forKey: "isADPurchased")
                user.synchronize()
              
            }
            else
            {
                
            }
          
        }
    }
    @IBAction func buyWater()
    {
        SwiftyStoreKit.purchaseProduct("com.petstar.watermark", quantity: 1, atomically: true) { result in
           
            if case .success(let purchase) = result {
                let user:UserDefaults = UserDefaults.standard
                //  let initSettings:Bool = user.bool(forKey: "isProUpgradePurchased4")
                user.set(true, forKey: "isWaterPurchased")
                user.synchronize()
            }
           
        }
    }
    @IBAction func restore()
    {
        let user:UserDefaults = UserDefaults.standard
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            for purchase in results.restoredPurchases {
                if(purchase.productId == "com.petstar.filterpack")
                {
                    user.set(true, forKey: "isFilterPurchased")
                    user.synchronize()
                    
                }
                else if(purchase.productId == "com.petstar.removead")
                {
                    user.set(true, forKey: "isADPurchased")
                    user.synchronize()
                    
                }
                else if(purchase.productId == "com.petstar.watermark")
                {
                    user.set(true, forKey: "isWaterPurchased")
                    user.synchronize()
                //    self.bannerView.isHidden = true
                    
                    
                }
                
                //  let initSettings:Bool = user.bool(forKey: "isProUpgradePurchased4")
                
                
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                } else if purchase.needsFinishTransaction {
                    // Deliver content from server, then:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            self.showAlert(self.alertForRestorePurchases(results))
        }
    }
    
    @IBAction func close()
    {
        dismiss(animated: false, completion: nil)
    }
    func setTexture(name:String, filterName:String, thumb:String, type:String, category:String)
    {
        var data:FilterData
        data = FilterData(name: name, filterName:filterName,thumb: thumb,type: type,category: category)
        
        filters.add(data)
    }
    func makeBasic() -> NSMutableArray
    {
        setTexture(name: "midnight.acv", filterName: "Midnight", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "coffee.acv", filterName: "Coffee", thumb: "", type: "ToneCurve",category:"Basic")
        
        setTexture(name: "sweet_day.acv", filterName: "Sweet Day", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "canela.acv", filterName: "Canela", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "winter.acv", filterName: "Winter", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "warm_pink.acv", filterName: "Warm Pink", thumb: "", type: "ToneCurve",category:"Basic")
        
        setTexture(name: "haze_green.acv", filterName: "Haze Green", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "old_memories.acv", filterName: "Old Memories", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "wine.acv", filterName: "Wine", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "old_magenta.acv", filterName: "Old Magenta", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "night.acv", filterName: "Night", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "christmas.acv", filterName: "Christmas", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "orange_dream.acv", filterName: "Orange Dream", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "red_dream.acv", filterName: "Red Dream", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "uva.acv", filterName: "UVA", thumb: "", type: "ToneCurve",category:"Basic")
        
        return filters!
        
    }
    
    func makeVintage() -> NSMutableArray
    {
        
        setTexture(name: "lookup_vintage_aged.png", filterName: "Vintage Aged", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_antique.png", filterName: "Vintage Antique", thumb: "", type: "Lookup",category:"Vintage")
        
        setTexture(name: "lookup_vintage_blue_fade.png", filterName: "Vintage Blue Fade", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_brash.png", filterName: "Vintage Brashs", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_classic_fade.png", filterName: "Vintage Classic Fade", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_classica.png", filterName: "Vintage Classica", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_colors.png", filterName: "Vintage Colors", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_cool.png", filterName: "Vintage Cool", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_cool2.png", filterName: "Vintage Cool2", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_creamy.png", filterName: "Vintage Creamy", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_darkness.png", filterName: "Vintage Darkness", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_days_gone_by.png", filterName: "Vintage Days Gone by", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_depth.png", filterName: "Vintage Depth", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_earthy.png", filterName: "Vintage Earthy", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_earthy2.png", filterName: "Vintage Earthy2", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_fade.png", filterName: "Vintage Fade", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_fade2.png", filterName: "Vintage Fade2", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_glory_days.png", filterName: "Vintage Glory Days", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_golden_fade.png", filterName: "Vintage Golden Fade", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_haze.png", filterName: "Vintage Haze", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_heaven.png", filterName: "Vintage Heaven", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_history.png", filterName: "Vintage History", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_icy.png", filterName: "Vintage Icy", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_insomnia.png", filterName: "Vintage Insomnia", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_intense.png", filterName: "Vintage Intense", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_light.png", filterName: "Vintage Light", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_lostdays.png", filterName: "Vintage Lost Days", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_matte.png", filterName: "Vintage Matte", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_matte2.png", filterName: "Vintage Matte2", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_memories.png", filterName: "Vintage Memories", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_morning.png", filterName: "Vintage Morning", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_old_timer.png", filterName: "Vintage Old Timer", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_outdated.png", filterName: "Vintage Outdated", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_overcast.png", filterName: "Vintage Overcast", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_past_tense.png", filterName: "Vintage Past Tense", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_peach.png", filterName: "Vintage Peach", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_pressed.png", filterName: "Vintage Pressed", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_purpleish.png", filterName: "Vintage Purple-ish", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_retro_fix.png", filterName: "Vintage Retro Fix", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_retro_red.png", filterName: "Vintage Retro Red", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_retro_red2.png", filterName: "Vintage Retro Red2", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_rose.png", filterName: "Vintage Rose", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_second_hand.png", filterName: "Vintage Second Hand", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_serious.png", filterName: "Vintage Serious", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_soft.png", filterName: "Vintage Soft", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_something_blue.png", filterName: "Vintage Something Blue", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_something_old.png", filterName: "Vintage Something Old", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_sun.png", filterName: "Vintage Sun", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_sun2.png", filterName: "Vintage Sun2", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_timid.png", filterName: "Vintage Timid", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_touch.png", filterName: "Vintage Touch", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_very.png", filterName: "Vintage Very", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_wash.png", filterName: "Vintage Wash", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_vintage_whisper.png", filterName: "Vintage Whisper", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_old_beach.png", filterName: "Vintage Beach", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_old_broadway.png", filterName: "Vintage Broadway", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_old_covershot.png", filterName: "Vintage Covershot", thumb: "", type: "Lookup",category:"Vintage")
        setTexture(name: "lookup_oldmemories.png", filterName: "Vintage Memories", thumb: "", type: "Lookup",category:"Vintage")
        
        return filters!
        
    }
    func makeHaze()->NSMutableArray
    {
        
        
        setTexture(name: "lookup_haze_basic.png", filterName: "Haze Basic", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_blueberry.png", filterName: "Haze Blueberry", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_bw_heavy.png", filterName: "Haze B&W Heavy", thumb: "", type: "Lookup",category:"Haze")
        
        setTexture(name: "lookup_haze_bw_high_contrast.png", filterName: "Haze High Contrast", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_bw.png", filterName: "Haze B&W", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_cool.png", filterName: "Haze Cool", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_desaturation.png", filterName: "Haze Desaturation", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_gold.png", filterName: "Haze Gold", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_heavy.png", filterName: "Haze Heavy", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_high_contrast.png", filterName: "Haze High Contrast", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_purple.png", filterName: "Haze Purple", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_strawberry.png", filterName: "Haze Strawberry", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_vibrant.png", filterName: "Haze Vibrant", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_warm.png", filterName: "Haze Warm", thumb: "", type: "Lookup",category:"Haze")
        
        return filters!
        
    }
    func makeFloral()->NSMutableArray
    {
        setTexture(name: "lookup_floral_aureolin.png", filterName: "Floral Aureolin", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_black_cherry.png", filterName: "Floral Black Cherry", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_bliss.png", filterName: "Floral Bliss", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_california.png", filterName: "Floral California", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_caramel.png", filterName: "Floral Caramel", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_colorwheel.png", filterName: "Floral Color Wheel", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_cross_proccesing.png", filterName: "Floral Cross processing", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_echo.png", filterName: "Floral Echo", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_edition.png", filterName: "Floral Edition", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_expedition.png", filterName: "Floral Expedition", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_extravagant.png", filterName: "Floral Extravagant", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_focus_highlight.png", filterName: "Floral Focus Highlight", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_frontpage.png", filterName: "Floral Frontpage", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_gamma.png", filterName: "Floral Gamma", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_golden_yellow.png", filterName: "Floral Golden Yellow", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_hazel.png", filterName: "Floral Hazel", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_infrared.png", filterName: "Floral Infra Red", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_iris.png", filterName: "Floral Iris", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_lavender.png", filterName: "Floral Lavender", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_long_journey.png", filterName: "Floral Long Journey", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_neutral_density.png", filterName: "Floral Neutral Density", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_nonphoto_blue.png", filterName: "Floral Nonphoto Blue", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_orton.png", filterName: "Floral Orton", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_overexposure_soft.png", filterName: "Floral Overexposure Soft", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_passion.png", filterName: "Floral Passion", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_pole.png", filterName: "Floral Pole", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_raw_filter.png", filterName: "Floral Raw Filter", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_saffron.png", filterName: "Floral Saffron", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_seashell.png", filterName: "Floral Sea Shell", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_silent_night.png", filterName: "Floral Silent Night", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_skin.png", filterName: "Floral Skin", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_spring.png", filterName: "Floral Spring", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_twistedline.png", filterName: "Floral Twisted line", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_velvet.png", filterName: "Floral Velvet", thumb: "", type: "Lookup",category:"Floral")
        setTexture(name: "lookup_floral_white.png", filterName: "Floral White", thumb: "", type: "Lookup",category:"Floral")
        
        return filters!
    }
    func makeStudio()->NSMutableArray
    {
        
        setTexture(name: "lookup_studio_coldfocus.png", filterName: "Studio Cold Focus", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_studio_elegant.png", filterName: "Studio Elegant", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_studio_memories.png", filterName: "Studio Memories", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_studio_overexposure_soft.png", filterName: "Studio Over Exposure", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_studio_ultracontrast.png", filterName: "Studio Ultra Contrast", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_studio_wavelength.png", filterName: "Studio Wavelength", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_classic.png", filterName: "Studio Classic", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_hill.png", filterName: "Studio Hill", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_photo_master.png", filterName: "Studio Photo Master", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_toning_classic_summer.png", filterName: "Studio Toning Classic Summer", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_toning_everest.png", filterName: "Studio Toning Everest", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_toning_polaroid.png", filterName: "Studio Toning Polaroid", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_toning_selenium.png", filterName: "Studio Toning Selenium", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_toning_strawberry.png", filterName: "Studio Toning Strawberry", thumb: "", type: "Lookup",category:"Studio")
        setTexture(name: "lookup_bw_waves.png", filterName: "Studio Waves", thumb: "", type: "Lookup",category:"Studio")
        
        return filters!
    }
    func makeWdding()->NSMutableArray
    {
        
        setTexture(name: "lookup_wdding_apollo.png", filterName: "Wedding Apollo", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wdding_aquamarine.png", filterName: "Wedding Aqua Marine", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wdding_bronzer.png", filterName: "Wedding Bronzer", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_autumnal.png", filterName: "Wedding Autumnal", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_bw_diana.png", filterName: "Wedding B&W Diana", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_bw_lowkey.png", filterName: "Wedding B&W Lowkey", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_dramatic_light.png", filterName: "Wedding Dramatic Light", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_enhance.png", filterName: "Wedding Enhance", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_ezon.png", filterName: "Wedding Ezon", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_fashion.png", filterName: "Wedding Fashion", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_galaxy.png", filterName: "Wedding Galaxy", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_hazel.png", filterName: "Wedding Hazel", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_highbubble.png", filterName: "Wedding High Bubble", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_layan.png", filterName: "Wedding Layan", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_pastel.png", filterName: "Wedding Pastel", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_summer.png", filterName: "Wedding Summer", thumb: "", type: "Lookup",category:"Wedding")
        setTexture(name: "lookup_wedding_urban_style.png", filterName: "Wedding Urbal Style", thumb: "", type: "Lookup",category:"Wedding")
        
        return filters!
    }
    
    func makeModern()->NSMutableArray
    {
        setTexture(name: "lookup_modern_apricot.png", filterName: "Modern Apicot", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_delicate.png", filterName: "Modern Delicate", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_deluxe.png", filterName: "Modern Deluxe", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_dot_digital.png", filterName: "Modern Dot Digital1", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_dot_digital2.png", filterName: "Modern Dot Digital2", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_ecru.png", filterName: "Modern Ecru", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_emerald.png", filterName: "Modern Emerald", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_exquisite.png", filterName: "Modern Exquisite", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_graceful.png", filterName: "Modern Graceful", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_light_faded.png", filterName: "Modern Light Faded", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_muted.png", filterName: "Modern Muted", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_orange_peel.png", filterName: "Modern Orange Peel", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_peri_winkle.png", filterName: "Modern Periwinkle", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_pistachio.png", filterName: "Modern Pistachio", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_sunny.png", filterName: "Modern Sunny", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_vanilla.png", filterName: "Modern Vanilla", thumb: "", type: "Lookup",category:"Modern")
        setTexture(name: "lookup_modern_white_smoke.png", filterName: "Modern White Smoke", thumb: "", type: "Lookup",category:"Modern")
        
        return filters!
    }
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return filters.count
        //return self.itemArray.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbCell", for: indexPath) as! ThumbCell
        
        let dict:FilterData =  filters[indexPath.row] as! FilterData
        
        let thumbStr:String = String(format: "http://www.junsoft.org/pthumb/%@", dict.name as! CVarArg)
        let thumbURL:NSURL = NSURL(string: thumbStr)!
        cell.imgView?.setImageWith(thumbURL as URL ,placeholderImage:UIImage(named: "sample"))
        
        
        return cell
        
    }
}
extension StoreViewController {
    
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertForProductRetrievalInfo(_ result: RetrieveResults) -> UIAlertController {
        
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        } else if let invalidProductId = result.invalidProductIDs.first {
            return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
        } else {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
            return alertWithTitle("Could not retrieve product info", message: errorString)
        }
    }
    
   
    
    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
        
        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
        } else if results.restoredPurchases.count > 0 {
            print("Restore Success: \(results.restoredPurchases)")
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }
    
    func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> UIAlertController {
        
        switch result {
        case .success(let receipt):
            print("Verify receipt Success: \(receipt)")
            return alertWithTitle("Receipt verified", message: "Receipt verified remotely")
        case .error(let error):
            print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return alertWithTitle("Receipt verification", message: "No receipt data. Try again.")
            case .networkError(let error):
                return alertWithTitle("Receipt verification", message: "Network error while verifying receipt: \(error)")
            default:
                return alertWithTitle("Receipt verification", message: "Receipt verification failed: \(error)")
            }
        }
    }
    
    func alertForVerifySubscriptions(_ result: VerifySubscriptionResult, productIds: Set<String>) -> UIAlertController {
        
        switch result {
        case .purchased(let expiryDate, let items):
            print("\(productIds) is valid until \(expiryDate)\n\(items)\n")
            return alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)")
        case .expired(let expiryDate, let items):
            print("\(productIds) is expired since \(expiryDate)\n\(items)\n")
            return alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)")
        case .notPurchased:
            print("\(productIds) has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
    
    func alertForVerifyPurchase(_ result: VerifyPurchaseResult, productId: String) -> UIAlertController {
        
        switch result {
        case .purchased:
            print("\(productId) is purchased")
            return alertWithTitle("Product is purchased", message: "Product will not expire")
        case .notPurchased:
            print("\(productId) has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
}
