//
//  CustomPermissionsViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 2..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import PAPermissions

class CustomPermissionsViewController: PAPermissionsViewController {

    let bluetoothCheck = PABluetoothPermissionsCheck()
    let locationCheck = PALocationPermissionsCheck()
    let microphoneCheck = PAMicrophonePermissionsCheck()
    let motionFitnessCheck = PAMotionFitnessPermissionsCheck()
    let cameraCheck = PACameraPermissionsCheck()
    let photoLibraryCheck = PAPhotoLibraryPermissionsCheck()
    lazy var notificationsCheck : PAPermissionsCheck = {
        if #available(iOS 10.0, *) {
            return PAUNNotificationPermissionsCheck()
        } else {
            return PANotificationsPermissionsCheck()
        }
    }()
    
    let calendarCheck = PACalendarPermissionsCheck()
    let reminderCheck = PARemindersPermissionsCheck()
    let contactsCheck  : PAPermissionsCheck = {
        if #available(iOS 9.0, *) {
            return PACNContactsPermissionsCheck()
        } else {
            return PAABAddressBookCheck()
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let permissions = [
            PAPermissionsItem.itemForType(.camera, reason: PAPermissionDefaultReason)!,
            PAPermissionsItem.itemForType(.microphone, reason: PAPermissionDefaultReason)!,
            PAPermissionsItem.itemForType(.photoLibrary, reason: PAPermissionDefaultReason)!,
            PAPermissionsItem.itemForType(.notifications, reason: "Required to send you great updates")!
            
        ]
        
        let handlers = [
            PAPermissionsType.camera.rawValue: self.cameraCheck,
            PAPermissionsType.microphone.rawValue: self.microphoneCheck,
            PAPermissionsType.photoLibrary.rawValue: self.photoLibraryCheck,
            PAPermissionsType.notifications.rawValue: self.notificationsCheck
        ]
        
        self.setupData(permissions, handlers: handlers)
        
        //////Colored background//////
        self.tintColor = UIColor.white
        self.backgroundColor = UIColor(red: 245.0/255.0, green: 94.0/255.0, blue: 78.0/255.0, alpha: 1.0)
        
        //////Blur background//////
        //self.tintColor = UIColor.white
        self.backgroundImage = UIImage(named: "per_back.png")
        self.useBlurBackground = true
        self.titleText = "PetStarGram"
        self.detailsText = "PetStarGram을 사용하려면 아래의 권한이 필요합니다."
      
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
