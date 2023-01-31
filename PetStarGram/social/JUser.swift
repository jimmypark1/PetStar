//
//  JUser.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 12..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class JUser : Codable,MGKeyed{
    var key: String?
    
   
    let uid: String
    let username: String
    let profile_url: String
    let token: String
    private static var _current: JUser?

    var isFollowed = false
    var isFollowing = false
    
    init(uid: String, username: String, profile:String = "", token:String="") {
        self.uid = uid
        self.username = username
        
        self.profile_url = profile
        self.token = token
    }
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
        
            let username = dict["username"] as? String
            else { return nil }
        
        let image_url = dict["image_url"] as? String
        let fcm_token = dict["token"] as? String
        
        
        self.uid = snapshot.key
        self.username = username
        self.profile_url = image_url!
        if(fcm_token != nil)
        {
            self.token = fcm_token!
        }
        else
        {
            self.token = ""
        }
       
//        print(snapshot.key)
        self.key = snapshot.key
        
    }
    static var current: JUser {
        // 3
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        // 4
        return currentUser
    }
    
    static func setCurrent(_ user: JUser, writeToUserDefaults: Bool = false) {
        // 2
        if writeToUserDefaults {
            // 3
            if let data = try? JSONEncoder().encode(user) {
                // 4
              
                UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
            }
        }
        
        _current = user
    }
}
