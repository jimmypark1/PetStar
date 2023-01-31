//
//  IntroContentViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 2..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import UserNotifications
import EventKit
import AVFoundation
import Photos
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth

class IntroContentViewController: UIViewController {

    var pageIndex : Int!
    var titleText : String!
    var imageFile : String!
    var parentCon : ViewController!
    
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var imgageView: UIImageView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var stButton: UIButton!

    @IBOutlet var cameraBt: UIButton!
    @IBOutlet var micBt: UIButton!
    @IBOutlet var albumBt: UIButton!
    @IBOutlet var notiBt: UIButton!

    @IBOutlet var desc: UITextView!

    @IBOutlet var cameraBt1: UIButton!
    @IBOutlet var micBt1: UIButton!
    @IBOutlet var albumBt1: UIButton!
    @IBOutlet var notiBt1: UIButton!
    @IBOutlet var startBt: UIButton!
    
 
    @IBOutlet var check1: UIImageView!
    @IBOutlet var check2: UIImageView!
    @IBOutlet var check3: UIImageView!
    @IBOutlet var check4: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgageView.image = UIImage(named: self.imageFile)
        self.labelTitle.text = self.titleText
        
        pageControl.currentPage = pageIndex
        
        desc.backgroundColor = UIColor.clear
        
        check1.isHidden = true
        check2.isHidden = true
        check3.isHidden = true
        check4.isHidden = true
        
       
        if( pageIndex != 2)
        {
            startBt.isHidden = true
 
            cameraBt.isHidden = true
            micBt.isHidden = true
            albumBt.isHidden = true
            notiBt.isHidden = true
        
            cameraBt1.isHidden = true
            micBt1.isHidden = true
            albumBt1.isHidden = true
            notiBt1.isHidden = true
            
            
            desc.text = ""
            
        }
        else
        {
            if(isCameraAccess() == false)
            {
                check1.isHidden = true
            }
            else
            {
                check1.isHidden = false
            }
            if(isPhotoAccess() == false)
            {
                check2.isHidden = true
            }
            else
            {
                check2.isHidden = false
            }
            if(isMicAccess() == false)
            {
                check3.isHidden = true
            }
            else
            {
                check3.isHidden = false
            }
            if(isNotiAccess() == false)
            {
                check4.isHidden = true
            }
            else
            {
                check4.isHidden = false
            }
            cameraBt.isHidden = false
            micBt.isHidden = false
            albumBt.isHidden = false
            notiBt.isHidden = false
            startBt.isHidden = false
            
            cameraBt1.layer.borderWidth = 1
            cameraBt1.layer.borderColor = UIColor.white.cgColor
            cameraBt1.layer.cornerRadius = 10
      
            micBt1.layer.borderWidth = 1
            micBt1.layer.borderColor = UIColor.white.cgColor
            micBt1.layer.cornerRadius = 10
            
            notiBt1.layer.borderWidth = 1
            notiBt1.layer.borderColor = UIColor.white.cgColor
            notiBt1.layer.cornerRadius = 10
            
            albumBt1.layer.borderWidth = 1
            albumBt1.layer.borderColor = UIColor.white.cgColor
            albumBt1.layer.cornerRadius = 10
            
            
            startBt.layer.borderWidth = 1
            startBt.layer.borderColor = UIColor.white.cgColor
            startBt.layer.cornerRadius = 10
            
            
            cameraBt1.isHidden = false
            micBt1.isHidden = false
            albumBt1.isHidden = false
            notiBt1.isHidden = false
            
            
            
            desc.text = "앱을 사용하기 위해서는 아래의 권한이 필요합니다. 해당권한들을 활성화하세요"
            
        }
        // Do any additional setup after loading the view.
    }

   
    func isCameraAccess()->Bool
    {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized {
            return true
        } else {
            return false
        }
    }
    func isNotiAccess()->Bool
    {
        let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
        if notificationType == [] {
            return false
        } else {
            return true
        }
    }
    func isPhotoAccess()->Bool
    {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            return true
        } else {
            return false
        }
    }
    func isMicAccess()->Bool
    {
        if AVAudioSession.sharedInstance().recordPermission() == .granted {
            return true
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enableCamera(){
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
            finished in
            DispatchQueue.main.async {
              //  complectionHandler()
                self.check1.isHidden = false
                
            }
        })
    }
    @IBAction func enableMic(){
        
        AVAudioSession.sharedInstance().requestRecordPermission {
            granted in
            DispatchQueue.main.async {
              //  complectionHandler()
                self.check3.isHidden = false
                
            }
        }
    }
    @IBAction func enablePhoto(){
        PHPhotoLibrary.requestAuthorization({
            finished in
            DispatchQueue.main.async {
               // complectionHandler()
                self.check2.isHidden = false
                
            }
        })
    }
    @IBAction func enableNoti(){
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                DispatchQueue.main.async {
                   // complectionHandler()
                    self.check4.isHidden = false
                    
                }
            }
        } // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            DispatchQueue.main.async {
              //  complectionHandler()
                self.check4.isHidden = false
                
            }
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            DispatchQueue.main.async {
               // complectionHandler()
                self.check4.isHidden = false
                
            }
        }
            // iOS 7 support
        else {
            DispatchQueue.main.async {
                //complectionHandler()
                self.check4.isHidden = false
                
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    @IBAction func startService(){
        
        if(isCameraAccess() == true && isPhotoAccess() == true && isMicAccess())
        {
            
            let user:UserDefaults = UserDefaults.standard
            
            user.set(true, forKey: "INIT_SETTINGS")
            user.synchronize()
            
          //  processFaceBookLogin()
            
            parentCon.startService()
        }
    }

}
