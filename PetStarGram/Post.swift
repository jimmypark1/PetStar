//
//  Post.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 4..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage


class Post {
    private var _caption: String!
    private var _imageUrl: String!
    private var _thumbUrl: String!
    private var _likes: Int!
    private var _views: Int!
    private var _type: Int!
    private var _postKey: String!
    private var _uploadedByUser: String!
    private var _postRef: DatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    var thumbUrl: String {
        return _thumbUrl
    }
    
    var likes: Int {
        return _likes
    }
    var views: Int {
        return _views
    }
    var type: Int {
        return _type
    }
    var postKey: String {
        return _postKey
    }
    
    var uploadedByUser: String {
        return _uploadedByUser
    }
    
    init(caption: String, imageUrl: String, likes: Int) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
    }
    
    init(postKey: String, postData: [String: Any]) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["image_url"] as? String {
            self._imageUrl = imageUrl
        }
        if let imageUrl = postData["thumb_url"] as? String {
            self._thumbUrl = imageUrl
        }
        
        if let uploadedByUser = postData["uploaded_by"] as? String {
            self._uploadedByUser = uploadedByUser
        }
        
        if let likes = postData["likes"] as? Int{
            self._likes = likes
        }
        if let views = postData["views"] as? Int{
            self._views = views
        }
        if let type = postData["type"] as? Int{
            self._type = type
        }
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        _postRef.child("likes").setValue(_likes)
    }
    func adjustView() {
        _views = _views + 1
        
        _postRef.child("views").setValue(_views)
    }
}
