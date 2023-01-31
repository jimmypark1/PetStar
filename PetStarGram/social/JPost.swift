//
//  JPost.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 12..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import FirebaseDatabase.FIRDataSnapshot
import FirebaseAuth
import FirebaseAuth.FIRUser

class JPost: MGKeyed {
    var key: String?
    let imageURL: String
    let thumbURL: String
    let creationDate: Date
   
    var likeCount: Int
    var viewsCount: Int
    var mediaType: Int
    var ratioMode: Int
    let poster: JUser
    var isLiked = false
    
    var dictValue: [String : Any] {
        let createdAgo = creationDate.timeIntervalSince1970
        let userDict = ["uid" : poster.uid,
        "username" : poster.username,
        "profile_url" : poster.profile_url,]
        
       
        return ["image_url" : imageURL,
                "thumb_url" : thumbURL,
                "created_at" : createdAgo,
                "like_count" : likeCount,
                "views_count" : viewsCount,
                "media_type" : mediaType,
                "ratio_mode" : ratioMode,
                "poster" : userDict]
    }
    init(imageURL: String, thumbURL: String, mediaType:Int = 0, ratioMode:Int = 0) {
        self.imageURL = imageURL
        self.creationDate = Date()
        self.likeCount = 0
        self.poster = JUser.current
        self.viewsCount = 0
        self.mediaType = mediaType
        self.ratioMode = ratioMode
        self.thumbURL = thumbURL

    }
   
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
        // ...
        let likeCount = dict["like_count"] as? Int,
        let viewsCount = dict["views_count"] as? Int,
        let userDict = dict["poster"] as? [String : Any],
        let uid = userDict["uid"] as? String,
        let username = userDict["username"] as? String,
        let profile = userDict["profile_url"] as? String
        else { return nil }
    
        self.likeCount = likeCount
        self.viewsCount = viewsCount
        self.poster = JUser(uid: uid, username: username,profile:profile)
        guard let dict2 = snapshot.value as? [String : Any],
            let imageURL = dict2["image_url"] as? String,
            let thumbURL = dict2["thumb_url"] as? String,
            let mediaType = dict2["media_type"] as? Int,
            let ratioMode = dict2["ratio_mode"] as? Int,
            let createdAgo = dict2["created_at"] as? TimeInterval
            else { return nil }
      
        self.ratioMode = ratioMode
        self.mediaType = mediaType
        self.thumbURL = thumbURL
        self.key = snapshot.key
        self.imageURL = imageURL
        self.creationDate = Date(timeIntervalSince1970: createdAgo)
    }
}
