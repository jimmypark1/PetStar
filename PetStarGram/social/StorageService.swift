//
//  StorageService.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 12..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth

struct StorageService {
    // provide method for uploading images
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        // 1
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
            // 2
            reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
                // 3
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    return completion(nil)
                }
                    // 4
                    reference.downloadURL(completion: { (url, error) in
                        if let error = error {
                            assertionFailure(error.localizedDescription)
                            return completion(nil)
                        }
                        completion(url)
                    })
            })
    }
    static func upload(_ url: URL, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        // 1
        let movieData = NSData(contentsOf:  url)
        
        
        // 2
        reference.putData(movieData as! Data, metadata: nil, completion: { (metadata, error) in
            // 3
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            // 4
            reference.downloadURL(completion: { (url, error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    return completion(nil)
                }
                completion(url)
            })
        })
    }
    
    static func delete(name:String, completion: @escaping (Bool) -> Void)
    {
        let uid:String =  Auth.auth().currentUser!.uid
        
        let reference  = Storage.storage().reference().child("images/posts/\(uid)/\(name)")
        reference.delete { error in
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
