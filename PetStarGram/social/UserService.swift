//
//  UserService.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 12..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import Foundation
//import FirebaseAuth.FIRUser
import FirebaseDatabase
import Firebase
import FirebaseAuth
//import FBSDKCoreKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import FirebaseDatabase
import FirebaseStorage

struct UserService {
    
    static func create(_ firUser: User, completion: @escaping (JUser?) -> Void) {
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // let userAttrs = ["username": username]
        var profile_img_url = firUser.photoURL?.absoluteString
        var username = firUser.displayName
        
       // var fullNameArr = firUser.email?.characters.split {$0 == "@"}.map(String.init)
       // let test = fullNameArr![0]
        if(username == nil)
        {
            // let test:String = "test.1234@gmail.com"
            if(firUser.email != nil)
            {
                var fullNameArr = firUser.email?.characters.split {$0 == "@"}.map(String.init)
                
                username = fullNameArr?[0]//firUser.email
                
            }
            else
            {
                username = "lover"
            }
            
        }
        if(profile_img_url == nil)
        {
            profile_img_url = "https://firebasestorage.googleapis.com/v0/b/petstargram-a3ca6.appspot.com/o/images%2Fposts%2Fcell_back.png?alt=media&token=e16eb51b-1905-4f67-9c5a-45834483173b"
        }
        let userAttrs: Dictionary<String, Any> = [
            "username": username,
            "image_url": profile_img_url,
            "token":appDelegate.fcmToken
        ]
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    let user = JUser(snapshot: snapshot)
                    completion(user)
                })
        }
    }
    static func saveProfile(image:UIImage, username:String, completion: @escaping (Bool?) -> Void)
    {
        
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let thumbRef = StorageReference.newProfileImageThumbReference()
        StorageService.uploadImage(image, at: thumbRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                completion(false)
                return
            }
            
            let thumbString = downloadURL.absoluteString
          
            let userAttrs: Dictionary<String, Any> = [
                "username": username,
                "image_url": thumbString,
                "token":appDelegate.fcmToken
            ]
            let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
            ref.setValue(userAttrs) { (error, ref) in
                if(error != nil)
                {
                    completion(false)
                }
                let user = JUser(uid: (Auth.auth().currentUser?.uid)!, username: username, profile: thumbString, token: appDelegate.fcmToken)
                
                JUser.setCurrent(user, writeToUserDefaults: true)
                completion(true)

            }
        }
    }
    
    static func emailLogin(_ firUser: User, completion: @escaping (JUser?) -> Void) {
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // let userAttrs = ["username": username]
       
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let user = JUser(snapshot: snapshot)
            completion(user)
        })
    }
    static func create2(_ firUser: User, name:String, completion: @escaping (JUser?) -> Void) {
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // let userAttrs = ["username": username]
        var profile_img_url = firUser.photoURL?.absoluteString
        var username = name
        
      
        if(profile_img_url == nil)
        {
            profile_img_url = "https://firebasestorage.googleapis.com/v0/b/petstargram-a3ca6.appspot.com/o/images%2Fposts%2Fcell_back.png?alt=media&token=e16eb51b-1905-4f67-9c5a-45834483173b"
        }
        let userAttrs: Dictionary<String, Any> = [
            "username": username,
            "image_url": profile_img_url,
            "token":appDelegate.fcmToken
        ]
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = JUser(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    static func getUserToken(uid:String, completion: @escaping (String?) -> Void)
    {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let user = JUser(snapshot: snapshot)
            
            completion(user?.token)
        })
    }
    
    static func updateUserToken(_ firUser: User, completion: @escaping (JUser?) -> Void) {
        // let userAttrs = ["username": username]
        let profile_img_url = firUser.photoURL?.absoluteString
        let userAttrs: Dictionary<String, Any> = [
            "username": firUser.displayName,
            "image_url": profile_img_url,
            "token": profile_img_url
        ]
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = JUser(snapshot: snapshot)
                completion(user)
            })
        }
        //flaggedPostRef.u.updateChildValues(flaggedDict)
        
    }
  
    static func likeTotalCount(for user: JUser, completion: @escaping (UInt) -> Void) {
        var likeTotalCount = 0
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion(UInt(likeTotalCount))
            }
           // snapshot.reversed().
           // let posts: [JPost] = snapshot.
            //likeTotalCount = likeTotalCount + post.likeCount
            for post in snapshot {
               
                let post =  JPost(snapshot:post)
                if(post != nil)
                {
                    likeTotalCount = likeTotalCount + (post?.likeCount)!
         
                }
            }
            completion(UInt(likeTotalCount))
        })
    }
    static func likeTotalList(for user: JUser, completion: @escaping (UInt) -> Void) {
        var likeTotalCount = 0
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion(UInt(likeTotalCount))
            }
            // snapshot.reversed().
            // let posts: [JPost] = snapshot.
            //likeTotalCount = likeTotalCount + post.likeCount
            for post in snapshot {
                
                let post =  JPost(snapshot:post)
                likeTotalCount = likeTotalCount + (post?.likeCount)!
            }
            completion(UInt(likeTotalCount))
        })
    }
    static func setLikeList(for userID: String, posterID:String, postKey:String) {
        var likeTotalCount = 0
        let ref = Database.database().reference().child("likesList").child(posterID).child(postKey)
        let userAttrs: Dictionary<String, Any> = [
            userID: true,
        ]
        ref.updateChildValues(userAttrs)
        
    }
    static func deleteLikeList(for userID: String, posterID:String, postKey:String) {
        var likeTotalCount = 0
        let ref = Database.database().reference().child("likesList").child(posterID).child(postKey).child(userID)
        
        
        ref.setValue(nil){ (error, _) in
        }
        
    }

    static func followers(for user: JUser, completion: @escaping ([String]) -> Void) {
        let followersRef = Database.database().reference().child("followers").child(user.uid)
            followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let followersDict = snapshot.value as? [String : Bool] else {
                    return completion([])
                }
                let followersKeys = Array(followersDict.keys)
                completion(followersKeys)
            })
    }
    static func show(forUID uid: String, completion: @escaping (JUser?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = JUser(snapshot: snapshot) else {
                return completion(nil)
            }
            
                completion(user)
        })
    }
  
    static func users(completion: @escaping ([JUser]) -> Void) {
        let currentUser = JUser.current
        // 1
        let ref = Database.database().reference().child("users")
        // 2
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            // 3
            let users = snapshot.compactMap(JUser.init)
            // 4
            let dispatchGroup = DispatchGroup()
            users.forEach { (user) in
                dispatchGroup.enter()
                // 5
                FollowService.isUserFollowed(user) { (isFollowed) in
                    user.isFollowed = isFollowed
                    
                    FollowService.isUserFollowing(user, target: (Auth.auth().currentUser?.uid)!) { (isFollowing) in
                        
                        user.isFollowing = isFollowing
                        
                        dispatchGroup.leave()
                        
                    }
                    
                }
            }
            // 6
            dispatchGroup.notify(queue: .main, execute: {
                completion(users)
            })
        })
    }
    static func following(for user: JUser = JUser.current, completion: @escaping ([JUser]) -> Void) {
        // 1
        let followingRef = Database.database().reference().child("following").child(user.uid)
        followingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // 2
            guard let followingDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            // 3
            var following = [JUser]()
            let dispatchGroup = DispatchGroup()
            for uid in followingDict.keys {
                dispatchGroup.enter()
                    show(forUID: uid) { user in
                        if let user = user {
                            following.append(user)
                        }
                            dispatchGroup.leave()
                }
            }
                // 4
                dispatchGroup.notify(queue: .main) {
                    completion(following)
            }
        })
    }
    static func posts(for user: JUser, completion: @escaping ([JPost]) -> Void) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            let dispatchGroup = DispatchGroup()
            let posts: [JPost] = snapshot.reversed().compactMap {
                guard let post = JPost(snapshot: $0)
                    else { return nil }
                dispatchGroup.enter()
                LikeService.isPostLiked(post) { (isLiked) in
                    post.isLiked = isLiked
                    dispatchGroup.leave()
                }
                return post
            }
            dispatchGroup.notify(queue: .main, execute: {
                completion(posts)
            })
        })
    }
    static func getBlockedUser(completion: @escaping ([JUser]) -> Void)
    {
        let ref = Database.database().reference().child("blockedUsers").child(JUser.current.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            var users = [JUser]()
            let valid =  snapshot.children.allObjects.count
            if(valid > 0)
            {
                print(snapshot.value)
                let data:[String:Any] = snapshot.value as! Dictionary
                print(data)
                for blockuserID in data.keys
                {
                    print( data[blockuserID])
                    let _user:[String:Any] = data[blockuserID] as! [String : Any]
                    let user = JUser(uid: blockuserID, username: _user["name"] as! String, profile: _user["image_url"] as! String )
                    users.append(user)
                }
            }
            completion(users)
            
        })
        
    }
    static func deleteBlockedUser(user:JUser)
    {
        let ref = Database.database().reference().child("blockedUsers").child(JUser.current.uid).child(user.uid)
        ref.setValue(NSNull())
        
    }
    
    
    static func usersExcludingCurrentUser(pageSize: UInt, lastPostKey: String? = nil, completion: @escaping ([JUser]) -> Void)
 //   static func usersExcludingCurrentUser(completion: @escaping ([JUser]) -> Void)
    {
        let currentUser = JUser.current
        // 1
        /*
        let ref = Database.database().reference().child("users")
        // 2
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            // 3
            let users = snapshot.compactMap(JUser.init).filter { $0.uid != currentUser.uid }
            // 4
            let dispatchGroup = DispatchGroup()
            users.forEach { (user) in
                dispatchGroup.enter()
                // 5
                FollowService.isUserFollowed(user) { (isFollowed) in
                    user.isFollowed = isFollowed
                    
                    FollowService.isUserFollowing(user, target: (Auth.auth().currentUser?.uid)!) { (isFollowing) in
                        
                        user.isFollowing = isFollowing
                        
                        dispatchGroup.leave()
                        
                    }
                    
                }
            }
            // 6
            dispatchGroup.notify(queue: .main, execute: {
                completion(users)
            })
        })
 */
        ////////
        
        let ref = Database.database().reference().child("users")
        var query = ref.queryOrderedByKey().queryLimited(toLast: pageSize)
        if let lastPostKey = lastPostKey {
            
            query = query.queryEnding(atValue: lastPostKey)
        }
        
        // 2
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            // 3
            //print(snapshot.count)
            var users = [JUser]()
            let dispatchGroup = DispatchGroup()
            
            for userSnap in snapshot
            {
                let user =  JUser(snapshot: userSnap)
                user?.key = user?.uid
               // let userDict = userSnap.value as? [String : Any]
              //  if(user?.uid != currentUser.uid)
               
                dispatchGroup.enter()
               
                
                FollowService.isUserFollowed(user!) { (isFollowed) in
                    
                    PostService.isBlockUser((user)!){ (isBlocked) in
                        
                        if( isBlocked == false)
                        {
                            user?.isFollowed = isFollowed
                            
                            FollowService.isUserFollowing(user!, target: (Auth.auth().currentUser?.uid)!) { (isFollowing) in
                                
                                user?.isFollowing = isFollowing
                                
                                //  posts.append(post)
                                users.append(user!)
                                dispatchGroup.leave()
                                
                                
                            }
                        }
                        else
                        {
                            dispatchGroup.leave()
                            
                        }
                     
                    }//////
                    
                   
                
                
                }
               
              
               // user.key
             
            }
            dispatchGroup.notify(queue: .main, execute: {
                completion(users.reversed())
            })
            /*
            let users = snapshot.compactMap(JUser.init).filter { $0.uid != currentUser.uid }
           // let users = snapshot.compactMap(JUser.init)
            // 4
            let dispatchGroup = DispatchGroup()
            users.forEach { (user) in
                dispatchGroup.enter()
                // 5
                FollowService.isUserFollowed(user) { (isFollowed) in
                    user.isFollowed = isFollowed
                    
                    FollowService.isUserFollowing(user, target: (Auth.auth().currentUser?.uid)!) { (isFollowing) in
                        
                        user.isFollowing = isFollowing
                        
                        dispatchGroup.leave()
                        
                    }
                    
                }
            }
             */
            // 6
           
        })
        
        
    }
    static func recent(pageSize: UInt, lastPostKey: String? = nil, completion: @escaping ([JPost]) -> Void)
    {
        let ref0 = Database.database().reference().child("posts")
        let user_ref = Database.database().reference().child("user-posts").child(JUser.current.uid)
        //.queryOrdered(byChild: "created_at")
        // var query0 = ref0.queryOrdered(byChild: "created_at").queryLimited(toFirst: 100)
        
        var posts = [JPost]()
        let dispatchGroup = DispatchGroup()
        let dispatchGroup0 = DispatchGroup()
        user_ref.setValue(NSNull())
        
       
        ref0.observeSingleEvent(of:.value, with: { (snapshot)  in
            // user_ref.setValue(snapshot)
            //  let child = snapshot.children.allObjects as? [DataSnapshot]
            let snapshot0 = snapshot.children.allObjects as? [DataSnapshot]
            for postSnap in snapshot0! {
                
                
                let postDict = postSnap.value as? [String : Any]
                //  print(postDict)
                user_ref.updateChildValues(postDict!)
                
            }
            
            var ref = Database.database().reference().child("user-posts").child(JUser.current.uid).queryOrdered(byChild: "created_at").queryLimited(toLast: 100)
            
            
          //  ref = ref.queryLimited(toFirst: pageSize)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
             //    let data = JSON(snapshot.value ?? [])
                
               // snapshot.value
             //   let postDict1 = snapshot.value as? [[String : Any]]
                let postDict0 = snapshot.value as? [String : Any]
              //  dispatchGroup0.enter()
                for p in snapshot.children.allObjects {
                  //  print(p)
                    let snap = p as! DataSnapshot
                    print(snap.key)
                    let postDict = snap.value as? [String : Any]
                    let poster =  postDict!["poster"] as? [String : Any]
                    dispatchGroup.enter()
                    
                    PostService.show(forKey: snap.key, posterUID: poster!["uid"] as! String) { (post) in
                        
                        //dispatchGroup0.enter()
                        /*
                        dispatchGroup.enter()
                        PostService.isBlockUser((post?.poster)!){ (isBlocked) in
                            
                            print(isBlocked)
                            if( isBlocked == false)
                            {
                                if let post = post {
                                    posts.append(post)
                                }
                            }
                            
                            dispatchGroup.leave()
                        }
                       
                         dispatchGroup.leave()
 */
                        if let post = post {
                            posts.append(post)
                        }
                        
                        dispatchGroup.leave()
                    }
                   
                }
                //dispatchGroup0.leave()
                
                dispatchGroup.notify(queue: .main, execute: {
                    
                   completion(posts.reversed())
                   
                })
               
                /*
                for postSnap in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    dispatchGroup.enter()
                    print(postSnap.key)
                    let postDict = postSnap.value as? [String : Any]
                    
                    let poster =  postDict!["poster"] as? [String : Any]
                    // print(poster!["uid"])
                    PostService.show(forKey: postSnap.key, posterUID: poster!["uid"] as! String) { (post) in
                        
                        PostService.isBlockUser((post?.poster)!){ (isBlocked) in
                            
                            print(isBlocked)
                            if( isBlocked == false)
                            {
                                if let post = post {
                                    posts.append(post)
                                }
                            }
                            
                            dispatchGroup.leave()
                        }
                        
                    }
                }
 */
              
                
            })
            
            
            //  var posts = [JPost]()
            //completion(posts.reversed())
        })
    }
    static func popular(pageSize: UInt, lastPostKey: String? = nil, completion: @escaping ([JPost]) -> Void)
    {
        let ref0 = Database.database().reference().child("posts")
        let user_ref = Database.database().reference().child("user-posts").child(JUser.current.uid)
        //.queryOrdered(byChild: "created_at")
        // var query0 = ref0.queryOrdered(byChild: "created_at").queryLimited(toFirst: 100)
        
        var posts = [JPost]()
        let dispatchGroup = DispatchGroup()
        user_ref.setValue(NSNull())
        ref0.observeSingleEvent(of:.value, with: { (snapshot)  in
            // user_ref.setValue(snapshot)
            //  let child = snapshot.children.allObjects as? [DataSnapshot]
            let snapshot0 = snapshot.children.allObjects as? [DataSnapshot]
            for postSnap in snapshot0! {
                
                
                let postDict = postSnap.value as? [String : Any]
                //  print(postDict)
                user_ref.updateChildValues(postDict!)
                
            }
            
            var ref = Database.database().reference().child("user-posts").child(JUser.current.uid).queryOrdered(byChild: "views_count").queryLimited(toLast: 50)
            
            
            //  ref = ref.queryLimited(toFirst: pageSize)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                //    let data = JSON(snapshot.value ?? [])
                
                // snapshot.value
                //   let postDict1 = snapshot.value as? [[String : Any]]
                let postDict0 = snapshot.value as? [String : Any]
                //  dispatchGroup0.enter()
                for p in snapshot.children.allObjects {
                    //  print(p)
                    let snap = p as! DataSnapshot
                    print(snap.key)
                    let postDict = snap.value as? [String : Any]
                    let poster =  postDict!["poster"] as? [String : Any]
                    dispatchGroup.enter()
                    
                    PostService.show(forKey: snap.key, posterUID: poster!["uid"] as! String) { (post) in
                        
                        //dispatchGroup0.enter()
                        
                        if let post = post {
                            posts.append(post)
                            
                        }
                        dispatchGroup.leave()
                    }
                    
                }
                //dispatchGroup0.leave()
                
                dispatchGroup.notify(queue: .main, execute: {
                    
                    completion(posts.reversed())
                    
                })
                
                /*
                 for postSnap in snapshot.children.allObjects as! [DataSnapshot] {
                 
                 dispatchGroup.enter()
                 print(postSnap.key)
                 let postDict = postSnap.value as? [String : Any]
                 
                 let poster =  postDict!["poster"] as? [String : Any]
                 // print(poster!["uid"])
                 PostService.show(forKey: postSnap.key, posterUID: poster!["uid"] as! String) { (post) in
                 
                 PostService.isBlockUser((post?.poster)!){ (isBlocked) in
                 
                 print(isBlocked)
                 if( isBlocked == false)
                 {
                 if let post = post {
                 posts.append(post)
                 }
                 }
                 
                 dispatchGroup.leave()
                 }
                 
                 }
                 }
                 */
                
                
            })
            
            
            //  var posts = [JPost]()
            //completion(posts.reversed())
        })
    }
    static func postsAll(pageSize: UInt, lastPostKey: String? = nil, completion: @escaping ([JPost]) -> Void)
    {
    
        let ref = Database.database().reference().child("posts")
        //.queryOrdered(byChild: "created_at")
       // var query = ref.queryOrdered(byChild: "views_count").queryLimited(toLast: pageSize)
        var query = ref.queryOrderedByKey().queryLimited(toLast: pageSize)
        if let lastPostKey = lastPostKey {
        
            query = query.queryEnding(atValue: lastPostKey)
        }
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let child = snapshot.children.allObjects as? [DataSnapshot]
        
            //child.
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            let dispatchGroup = DispatchGroup()
            var posts = [JPost]()
           
            print(snapshot)
            for postSnap in snapshot {
                let postDict = postSnap.value as? [String : Any]
                 let posterID = postSnap.key
                //print(postDict)
               // let ref0 = Database.database().reference().child("posts").child(posterID)
                let ref0 = Database.database().reference().child("posts").child(posterID)
                //
                print(postDict)
                dispatchGroup.enter()
                ref0.observeSingleEvent(of: .value, with: { (snapshot) in
                   
                    
                    for rest in snapshot.children.allObjects as! [DataSnapshot] {
                        
                        print(rest.key)
                        dispatchGroup.enter()
                        PostService.show(forKey: rest.key, posterUID: posterID) { (post) in
                           
                            print(posterID)
                            var post0 = post
                            
                            
                            if(post0 != nil)
                            {
                                PostService.isBlockUser((post0?.poster)!){ (isBlocked) in
                                    
                                    print(isBlocked)
                                    if( isBlocked == false)
                                    {
                                        if let post = post {
                                            posts.append(post)
                                        }
                                    }
                                    
                                    dispatchGroup.leave()
                                }
                            }
                            else
                            {
                                dispatchGroup.leave()
                                
                            }
                            
                            
                          
                            
                        }
                        
                    }
                    dispatchGroup.leave()
                
                })
              
             }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(posts.reversed())
            })
            
 
        })
 
 
    }
    static func timeline(pageSize: UInt, lastPostKey: String? = nil, completion: @escaping ([JPost]) -> Void) {
        let currentUser = JUser.current
      
        let ref = Database.database().reference().child("timeline").child(currentUser.uid)
        var query = ref.queryOrderedByKey().queryLimited(toLast: pageSize)
        if let lastPostKey = lastPostKey {
            query = query.queryEnding(atValue: lastPostKey)
        }
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            let dispatchGroup = DispatchGroup()
            var posts = [JPost]()
            for postSnap in snapshot {
                guard let postDict = postSnap.value as? [String : Any],
                    let posterUID = postDict["poster_uid"] as? String
                    else { continue }
                dispatchGroup.enter()
                print(postSnap.key)
                PostService.show(forKey: postSnap.key, posterUID: posterUID) { (post) in
                    if let post = post {
                        posts.append(post)
                    }
                   
                    dispatchGroup.leave()
                    
              
                }
            }
            dispatchGroup.notify(queue: .main, execute: {
                completion(posts.reversed())
            })
        })
    }
    //pageSize: UInt, lastPostKey: String? = nil,
    static func observeChats( completion: @escaping (DatabaseReference, [Chat]) -> Void) -> DatabaseHandle {
        
        let user: JUser = JUser.current
        let ref = Database.database().reference().child("chats").child(user.uid)
    
        return ref.observe(.value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion(ref, [])
            }
            var chats = snapshot.flatMap(Chat.init)
           // var _chats = chats.reversed()
            completion(ref,chats)
        })
    }
    static func observeChatsLast(for user: JUser = JUser.current, withCompletion completion: @escaping (DatabaseReference, [Chat]) -> Void) -> DatabaseHandle {
        
        
        let ref = Database.database().reference().child("chats").child(user.uid)
        
        return ref.observe(.value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion(ref, [])
            }
            
            let chats = snapshot.flatMap(Chat.init)
            for chat in chats
            {
                let _ref = Database.database().reference().child(user.uid).child(chat.key!)
                _ref.observe(.value, with: { (_snapshot) in
                    
                   
                    print(_snapshot.value)
                    completion(ref, chats)
                    
                })
            }
        //    completion(ref, chats)
        })
    }
    
    static func observeReceive(for user: String, withCompletion completion: @escaping ([String : Any], Bool) -> Void)  {
        
        
        let ref = Database.database().reference().child("mstatus").child(user)
        
        ref.observe(.value, with: { (snapshot) in
            
            
            print(snapshot.value)
            print(snapshot.key)
            let dict = (snapshot.value as AnyObject)  as? [String : Any]
             if(dict != nil)
            {
                let key = dict?.keys.first
                let mstatusData = dict![key!]  as? [String :Any]
                print(dict)
                dict?.keys.first
                let content =  mstatusData!["content"] as! String
                if(content.count > 0)
                {
                    completion(dict!, true)
                    
                }
                else
                {
                    completion(["":""], false)
                    
                }
                
            }
            else
            {
                completion(["":""], false)
                
            }
        
        })
    }
    
    static func observeMessages(forChatKey chatKey: String, completion: @escaping (DatabaseReference, Message?) -> Void) -> DatabaseHandle {
        let messagesRef = Database.database().reference().child("messages").child(chatKey)
      
        return messagesRef.observe(.childAdded, with: { snapshot in
            guard let message = Message(snapshot: snapshot) else {
                return completion(messagesRef, nil)
            }
        
            completion(messagesRef, message)
        })
    }
}

