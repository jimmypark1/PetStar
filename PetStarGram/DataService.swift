//
//  DataService.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 4..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

import SwiftKeychainWrapper

let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    // DB References
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    
    // Storage references
    private var _REF_POST_PICS = STORAGE_BASE.child("post-pics")
    private var _REF_PROFILE_PICS = STORAGE_BASE.child("profile-pics")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: DatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_CURRENT_USER: DatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: "uid")
        let currentUser = _REF_USERS.child(uid!)
        return currentUser
    }
    
    var REF_POST_PICS: StorageReference {
        return _REF_POST_PICS
    }
    
    var REF_PROFILE_PICS: StorageReference {
        return _REF_PROFILE_PICS
    }
    
    func createFirebaseUser(uid: String, userData: Dictionary<String, String>) {
        _REF_USERS.child(uid).updateChildValues(userData)
    }
}
