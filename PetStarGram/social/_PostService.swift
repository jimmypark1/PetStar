//
//  PostService.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 12..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth.FIRUser
import RSLoadingView

struct PostService {
    
    static func create(for image: UIImage, thumb:UIImage, ratioMode:Int, completion: @escaping (Bool?) -> Void){
       
        
        let imageRef = StorageReference.newPostImageReference()
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                completion(false)
                return
            }
            
            let urlString = downloadURL.absoluteString
            let thumbRef = StorageReference.newPostImageThumbReference()
            StorageService.uploadImage(thumb, at: thumbRef) { (downloadURL) in
                guard let downloadURL = downloadURL else {
                    completion(false)
                    return
                }
                
                let thumbString = downloadURL.absoluteString
                //  let aspectHeight = 0//image.aspectHeight
                
                create(forURLString: urlString, thumb: thumbString, completion:completion)
            }
        }
        
       
    }
    static func createVideo(for videoURL: URL, thumb:UIImage, ratioMode:Int, completion: @escaping (Bool?) -> Void) {
        
        
        let imageRef = StorageReference.newPostVideoReference()
        StorageService.upload(videoURL, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                completion(false)
                return
            }
            
            let urlString = downloadURL.absoluteString
            let thumbRef = StorageReference.newPostVideoThumbReference()
            StorageService.uploadImage(thumb, at: thumbRef) { (downloadURL) in
                guard let downloadURL = downloadURL else {
                    completion(false)
                    return
                }
                
                let thumbString = downloadURL.absoluteString
                //  let aspectHeight = 0//image.aspectHeight
                
                create(forURLString: urlString, thumb: thumbString, mediaType: 1, ratioMode:0, completion:completion)
            }
        }
      
        
    }
    static func views(for post: JPost) {
        
        
        let ref = Database.database().reference().child("posts").child(post.poster.uid).child(post.key!)
        
        post.viewsCount = post.viewsCount + 1
        let viewDict = ["views_count" : post.viewsCount]
        
        ref.updateChildValues(viewDict)
        
    }
  /*
    static func create(for  url:URL) {
        
        let imageRef = StorageReference.newPostImageReference()
        StorageService.upload(url, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteString
            let aspectHeight = 0//image.aspectHeight
            create(forURLString: urlString)
        }
    }
 */
    private static func create(forURLString urlString: String, thumb:String, mediaType:Int = 0, ratioMode:Int = 0, completion: @escaping (Bool?) -> Void){
        let currentUser = JUser.current
        let post = JPost(imageURL: urlString, thumbURL: thumb, mediaType:mediaType, ratioMode:ratioMode)
        // 1
       
        let rootRef = Database.database().reference()
        let newPostRef = rootRef.child("posts").child(currentUser.uid).childByAutoId()
        let newPostKey = newPostRef.key
            // 2
        UserService.followers(for: currentUser) { (followerUIDs) in
                // 3
            let timelinePostDict = ["poster_uid" : currentUser.uid]
                // 4
            var updatedData: [String : Any] = ["timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
                // 5
                for uid in followerUIDs {
                    updatedData["timeline/\(uid)/\(newPostKey)"] = timelinePostDict
                }
                // 6
                let postDict = post.dictValue
            updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
                    // 7
                    rootRef.updateChildValues(updatedData)
            
            completion(true)
        }
    
    }
    static func show(forKey postKey: String, posterUID: String, completion: @escaping (JPost?) -> Void) {
        let ref = Database.database().reference().child("posts").child(posterUID).child(postKey)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let post = JPost(snapshot: snapshot) else {
                    return completion(nil)
                }
                    LikeService.isPostLiked(post) { (isLiked) in
                        post.isLiked = isLiked
                        completion(post)
                }
            })
    }
    static func flag(_ post: JPost) {
        guard let postKey = post.key else { return }
        // 2
        let flaggedPostRef = Database.database().reference().child("flaggedPosts").child(postKey)
        // 3
        let flaggedDict = ["image_url": post.imageURL,
        "poster_uid": post.poster.uid,
        "reporter_uid": JUser.current.uid]
        // 4
        flaggedPostRef.updateChildValues(flaggedDict)
        // 5
        let flagCountRef = flaggedPostRef.child("flag_count")
        flagCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
            let currentCount = mutableData.value as? Int ?? 0
            mutableData.value = currentCount + 1
            return TransactionResult.success(withValue: mutableData)
        })
    }
    static func blockUser(_ user: JUser ) {
        // 2
        let blockRef = Database.database().reference().child("blockedUsers").child(JUser.current.uid)
        // 3
        let flaggedDict = [user.uid: ["image_url":user.profile_url,"name":user.username]]
        // 4
        blockRef.updateChildValues(flaggedDict)
        // 5
       
    }
    static func isBlockUser(_ user: JUser, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let currentUID = user.uid
        print(JUser.current.uid)
        let ref = Database.database().reference().child("blockedUsers").child(JUser.current.uid)//.child(user.uid)
        ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Any] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    static func delete(_ post:JPost, completion: @escaping (Bool) -> Void)
    {
        
        print(post.key)
        let deleteRef =     Database.database().reference().child("posts").child(post.poster.uid).child(post.key!)
   
        let timelineRef =     Database.database().reference().child("timeline").child(post.poster.uid).child(post.key!)
        let followingRef =     Database.database().reference().child("following").child(post.poster.uid)
        
       // let timelinesRefs = Database.database().reference().child("timelinesRefs").queryEqual(toValue: post.key!)
        print(post.poster.uid)
        followingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists())
            {
                let dict:Dictionary = snapshot.value as! Dictionary<String,Bool>
                // print(dict)
                for key in dict.keys
                {
                    print(key)
                    let timelineRef =     Database.database().reference().child("timeline").child(key).child(post.key!)
                    timelineRef.setValue(NSNull())
                    
                }
            }
         
            
        })
    
        let timelineRef0 =     Database.database().reference().child("timeline").child(post.poster.uid).child(post.key!)
        timelineRef0.setValue(NSNull())
        
        deleteRef.setValue(NSNull())
        
        
        let uid:String =  Auth.auth().currentUser!.uid
      //  let name = post.imageURL
        let name:NSString = URL(string:post.imageURL)!.lastPathComponent as NSString
        let thumb_name:NSString = URL(string:post.thumbURL)!.lastPathComponent as NSString
        
        print(name)
        
        let reference  = Storage.storage().reference().child("images/posts/\(uid)/\(name)")
      
        let thumb_reference  = Storage.storage().reference().child("images/posts/\(uid)/thumbs/\(thumb_name)")
        
        reference.delete { error in
            if let error = error {
                // Uh-oh, an error occurred!
                return completion(false)
                
            } else {
                // File deleted successfully
                thumb_reference.delete { error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                        return completion(false)
                        
                    } else {
                        // File deleted successfully
                        return completion(true)
                        
                    }
                }
                
            }
        }
       
    
        
    }
}
