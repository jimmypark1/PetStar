//
//  FollowService.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 12..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

import Foundation
import FirebaseDatabase
import FirebaseAuth.FIRUser

struct FollowService {
    
    
    static func setIsFollowing(_ isFollowing: Bool, fromCurrentUserTo followee: JUser, success: @escaping (Bool) -> Void) {
        if isFollowing {
            followUser(followee, forCurrentUserWithSuccess: success)
        } else {
            unfollowUser(followee, forCurrentUserWithSuccess: success)
        }
    }
    static func isUserFollowed(_ user: JUser, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let currentUID = user.uid
        let ref = Database.database().reference().child("followers").child(user.uid)
            ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? [String : Bool] {
                    completion(true)
                } else {
                    completion(false)
                }
            })
    }
    static func isUserFollowing(_ user: JUser,target:String, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let currentUID = target//user.uid
        let ref = Database.database().reference().child("following").child(currentUID)
        ref.queryEqual(toValue: nil, childKey: user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    static func followersCount(_ user: JUser,completion: @escaping (UInt) -> Void)
    {
        let ref = Database.database().reference().child("followers").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
           completion(snapshot.childrenCount)
        })
    }
    static func followingsCount(_ user: JUser,completion: @escaping (UInt) -> Void)
    {
        let ref = Database.database().reference().child("following").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            completion(snapshot.childrenCount)
        })
    }
    private static func followUser(_ user: JUser, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = JUser.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)" : true,
        "following/\(currentUID)/\(user.uid)" : true]
        let ref = Database.database().reference()
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            }
                // 1
                UserService.posts(for: user) { (posts) in
                    // 2
                    let postKeys = posts.compactMap { $0.key }
                    // 3
                    var followData = [String : Any]()
                    let timelinePostDict = ["poster_uid" : user.uid]
                    postKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                        // 4
                        ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                            if let error = error {
                                assertionFailure(error.localizedDescription)
                            }
                                // 5
                                success(error == nil)
                        })
            }
        }
    }
    private static func unfollowUser(_ user: JUser, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = JUser.current.uid
        // Use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any]
        // http://stackoverflow.com/questions/38462074/using-updatechildvalues-to-delete-from-firebase
        let followData = ["followers/\(user.uid)/\(currentUID)" : NSNull(),
        "following/\(currentUID)/\(user.uid)" : NSNull()]
        let ref = Database.database().reference()
        ref.updateChildValues(followData) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
                UserService.posts(for: user, completion: { (posts) in
                    var unfollowData = [String : Any]()
                    let postsKeys = posts.compactMap { $0.key }
                    postsKeys.forEach {
                        // Use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any]
                        unfollowData["timeline/\(currentUID)/\($0)"] = NSNull()
                        }
                        ref.updateChildValues(unfollowData, withCompletionBlock: { (error, ref) in
                            if let error = error {
                                assertionFailure(error.localizedDescription)
                            }
                                success(error == nil)
                        })
                })
        }
    }
}
