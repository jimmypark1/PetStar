//
//  ChatService.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 19..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseDatabase.FIRDataSnapshot

struct ChatService {

    static func create(from message: Message, with chat: Chat, completion: @escaping (Chat?) -> Void) {
        // 1
        var membersDict = [String : Bool]()
        for uid in chat.memberUIDs {
            membersDict[uid] = true
        }
        // 2
        let lastMessage = "\(message.sender.username): \(message.content)"
        chat.lastMessage = lastMessage
        let lastMessageSent = message.timestamp.timeIntervalSince1970
        chat.lastMessageSent = message.timestamp
       // 3
        let chatDict: [String : Any] = ["title" : chat.title,
        "memberHash" : chat.memberHash,
        "members" : membersDict,
        "lastMessage" : lastMessage,
        "lastMessageSent" : lastMessageSent]
        // 4
        let chatRef = Database.database().reference().child("chats").child(JUser.current.uid).childByAutoId()
        chat.key = chatRef.key
        // 5
        var multiUpdateValue = [String : Any]()
        // 6
        for uid in chat.memberUIDs {
            multiUpdateValue["chats/\(uid)/\(chatRef.key)"] = chatDict
        }
        // 7
        let messagesRef = Database.database().reference().child("messages").child(chatRef.key!).childByAutoId()
        let messageKey = messagesRef.key
        // 8
        multiUpdateValue["messages/\(chatRef.key)/\(messageKey)"] = message.dictValue
        // 9
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
                completion(chat)
        }
    }
    static func checkForExistingChat(with user: JUser, completion: @escaping (Chat?) -> Void) {
        // 1
        let members = [user, JUser.current]
        let hashValue = Chat.hash(forMembers: members)
        // 2
        let chatRef = Database.database().reference().child("chats").child(JUser.current.uid)
        // 3
        let query = chatRef.queryOrdered(byChild: "memberHash").queryEqual(toValue: hashValue)
            // 4
            query.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let chatSnap = snapshot.children.allObjects.first as? DataSnapshot,
                    let chat = Chat(snapshot: chatSnap)
                    else { return completion(nil) }
                completion(chat)
            })
    }
    static func sendMessage(_ message: Message, for chat: Chat, success: ((Bool) -> Void)? = nil) {
        guard let chatKey = chat.key else {
            success?(false)
            return
        }
        var multiUpdateValue = [String : Any]()
        for uid in chat.memberUIDs {
            let lastMessage = "\(message.sender.username): \(message.content)"
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessage"] = lastMessage
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessageSent"] = message.timestamp.timeIntervalSince1970
        }
        let messagesRef = Database.database().reference().child("messages").child(chatKey).childByAutoId()
        let messageKey = messagesRef.key
        multiUpdateValue["messages/\(chatKey)/\(messageKey)"] = message.dictValue
        
        message.sender
        
        let statusRef = Database.database().reference().child("message_status").child(chatKey).childByAutoId()
       // let messageKey = statusRef.key
        multiUpdateValue["messages/\(chatKey)/\(messageKey)"] = message.dictValue
        
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
                success?(true)
        })
    }
    static func sendMessageStatus(_ message: Message, for chat: Chat, success: ((Bool) -> Void)? = nil) {
        guard let chatKey = chat.key else {
            success?(false)
            return
        }
        var multiUpdateValue = [String : Any]()
        for uid in chat.memberUIDs {
            let lastMessage = "\(message.sender.username): \(message.content)"
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessage"] = lastMessage
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessageSent"] = message.timestamp.timeIntervalSince1970
        }
        let messagesRef = Database.database().reference().child("messages").child(chatKey).childByAutoId()
        let messageKey = messagesRef.key
        multiUpdateValue["messages/\(chatKey)/\(messageKey)"] = message.dictValue
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            success?(true)
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
    static func observeMessages2(forChatKey chatKey: String, completion: @escaping (Bool?)-> Void) {
       
        
        let ref = Database.database().reference().child("messages").child(chatKey)
        ref.observe(.childAdded, with: { snapshot in
           
            print("test")
            completion(true)
        })
    }
}
