//
//  EditVideoViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 3..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper

import RSLoadingView
import GoogleMobileAds

class EditVideoViewController: UIViewController {
 
    var exportUrl:NSURL!
    var thumbURL:String!
    var avPlayer:AVPlayer!
    var type:Int!
    var image:UIImage!
    var ratioStatus:Int!
    
    @IBOutlet weak var bannerView:GADBannerView!
    @IBOutlet weak var bannerHeight:NSLayoutConstraint!
  
    
    @IBOutlet weak var captionField: UITextView!
    @IBOutlet weak var videoView: UIImageView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topPrevConstraint: NSLayoutConstraint!
    @IBOutlet weak var topMoreConstraint: NSLayoutConstraint!
    @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
    
    
    @IBOutlet var titleView:UIView!
    @IBOutlet var shareLabel:UILabel!
    
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
        topViewConstraint.constant = topViewConstraint.constant + offset
        topPrevConstraint.constant = topPrevConstraint.constant + offset
        topMoreConstraint.constant = topMoreConstraint.constant + offset
        
        titleView.layer.shadowColor = UIColor.lightGray.cgColor
        titleView.layer.shadowOpacity = 1
        titleView.layer.shadowOffset = CGSize.zero
        titleView.layer.shadowRadius = 2
        
       
    }
    @IBAction func share()
    {
       // let image =  imageWithView(view: self.captuedImageView!)
        
        // set up activity view controller
        if(self.type == 0)
        {
            let imageToShare = [ self.image ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [UIActivityType.airDrop,UIActivityType.copyToPasteboard,UIActivityType.print,UIActivityType.addToReadingList,UIActivityType.assignToContact,UIActivityType.openInIBooks, UIActivityType.saveToCameraRoll ]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
        else
        {
            let activityItems = [self.exportUrl ]
            
            let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [UIActivityType.airDrop,UIActivityType.copyToPasteboard,UIActivityType.print,UIActivityType.addToReadingList,UIActivityType.assignToContact,UIActivityType.openInIBooks, UIActivityType.saveToCameraRoll ]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(self.type  == 1)
        {
            avPlayer = AVPlayer(url: self.exportUrl as! URL)
            
            let videoLayer:AVPlayerLayer = AVPlayerLayer(player: avPlayer)
            if(ratioStatus == 0)
            {
                videoLayer.frame = CGRect(x:0,y:0,width:self.view.bounds.width,height:self.view.bounds.height)
                
            }
            else if(ratioStatus == 1)
            {
                videoLayer.frame = CGRect(x:0,y:0,width:self.view.bounds.width,height:1.333 * self.view.bounds.width)
                
            }
            else if(ratioStatus == 2)
            {
                let rect:CGRect = videoView.bounds;
                videoLayer.frame = rect
                
            }
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            
            videoView.layer.addSublayer(videoLayer)
            avPlayer.play()
        }
        else
        {
            // picture
            //videoView.image
            let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            if(appDelegate.isSimulator == true)
            {
                videoView.image = UIImage(named:"sample")
                self.image = UIImage(named:"sample")
                
            }
            else
            {
                videoView.image = self.image
                
            }
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        
    }
    override func viewWillAppear(_ animated: Bool) {
        JunSoftUtil.shared.isDetail = true
  
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initTopView()
        shareLabel.font = UIFont(name: "Amaranth", size: 13)
        
        ratioStatus = 2
       
       
        let user:UserDefaults = UserDefaults.standard
        
        let bAD:Bool = user.bool(forKey: "isADPurchased")
        if( bAD == false)
        {
            
            
            let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            if(appDelegate.isServiceAD == false)
            {
                bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            }
            else
            {
                bannerView.adUnitID = "ca-app-pub-7915959670508279/1061396854"
            }
            bannerView.rootViewController = self
            let request = GADRequest()
            //  request.testDevices = @[ @"e65885a6f48dfc84c9ae2de2872759fd" ];
            bannerView.load(request)
            
        }
        else
        {
            bannerHeight.constant = 0
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func postToFirebase(imageUrl: String, thumb: String, caption: String) {
        let post: Dictionary<String, Any> = [
            "caption": caption,
            "image_url": imageUrl,
            "thumb_url": thumb,
            "uploaded_by": KeychainWrapper.standard.string(forKey: "uid")!,
            "likes": 0,
            "type":self.type,
            "timestamp": ServerValue.timestamp(),
            "views": 0
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        // clear the post params
     //   self.imageSelected = false
      //  self.captionField.text = ""
     //   self.imageAdd.image = UIImage(named: "add-image")
        
      //  self.tableView.reloadData()
    }
    
    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)

    }

    @IBAction func upload()
    {
        let loadingView = RSLoadingView()
        loadingView.show(on: self.view)
        
        if(type == 0) // image
        {
            PostService.create(for: self.image,thumb: self.image, ratioMode: 0, completion:{ (error) in
              
                RSLoadingView.hide(from: self.view)
                JunSoftUtil.shared.isUpdate = true
                self.dismiss(animated: true, completion: nil)
                
            })
        }
        else
        {
            //video
            let asset = AVAsset(url: self.exportUrl as URL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            let time = CMTimeMake(1, 1)
            let imageRef = try! imageGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage:imageRef)
            
            PostService.createVideo(for: self.exportUrl as URL,thumb: thumbnail, ratioMode: 0, completion:{ (error) in
                RSLoadingView.hide(from: self.view)
                
                JunSoftUtil.shared.isUpdate = true
           
                self.dismiss(animated: true, completion: nil)
                
            })
            
        }
    
        
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }

}
