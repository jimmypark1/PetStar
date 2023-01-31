//
//  StorageReference+Post.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 12..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseAuth

extension StorageReference {
    static let dateFormatter = ISO8601DateFormatter()
  
    static func newPostImageReference() -> StorageReference {
        let uid:String =  Auth.auth().currentUser!.uid
        let timestamp = dateFormatter.string(from: Date())
    
        return Storage.storage().reference().child("images/posts/\(uid)/\(timestamp).jpg")
    }
    static func newPostImageThumbReference() -> StorageReference {
        let uid:String =  Auth.auth().currentUser!.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("images/posts/\(uid)/thumbs/\(timestamp).jpg")
    }
    static func newPostVideoReference() -> StorageReference {
        let uid:String =  Auth.auth().currentUser!.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("images/posts/\(uid)/\(timestamp).mp4")
    }
    static func newPostVideoThumbReference() -> StorageReference {
        let uid:String =  Auth.auth().currentUser!.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("images/posts/\(uid)/thumbs/\(timestamp).mp4")
    }
}
