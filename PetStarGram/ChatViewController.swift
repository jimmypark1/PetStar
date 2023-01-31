//
//  ChatViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 19..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

import JSQMessagesViewController

import FirebaseDatabase

import UserNotifications
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class ChatViewController: JSQMessagesViewController {

    var chat: Chat!

    var messages = [Message]()
    var messagesHandle: DatabaseHandle = 0
    var messagesRef: DatabaseReference?
    
    var selectedUser:JUser!
    //
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage = {
        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
            fatalError("Error creating bubble image factory.")
        }

        let color = UIColor.init(red: 27.0/256.0, green: 147.0/256.0, blue: 216.0/256.0, alpha: 1.0)//UIColor.jsq_messageBubbleBlue()
        return bubbleImageFactory.outgoingMessagesBubbleImage(with: color)
    }()
  
    var incomingBubbleImageView: JSQMessagesBubbleImage = {
        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
            fatalError("Error creating bubble image factory.")
        }

        let color = UIColor.jsq_messageBubbleLightGray()
        return bubbleImageFactory.incomingMessagesBubbleImage(with: color)
    }()
    func addViewOnTop() {
        var offset = 0
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
            case 1334:
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X")
                offset = 20
            default:
                print("unknown")
            }
        }
      //  offset = 0
       
        let selectableView = UIView(frame: CGRect(x: 0, y: 0, width: Int( UIScreen.main.bounds.width), height: 66 + offset))
        selectableView.backgroundColor = UIColor.white
        
        selectableView.layer.shadowColor = UIColor.lightGray.cgColor
        selectableView.layer.shadowOpacity = 1
        selectableView.layer.shadowOffset = CGSize.zero
        selectableView.layer.shadowRadius = 2
        
        let randomViewLabel = UILabel(frame: CGRect(x: 0, y: 30 + offset, width: Int( UIScreen.main.bounds.width), height: 26))
        randomViewLabel.textAlignment = .center
        randomViewLabel.font =  UIFont(name: "Amaranth", size: 16)
        randomViewLabel.textColor = UIColor.init(red: 27.0/256.0, green: 147.0/256.0, blue: 216.0/256.0, alpha: 1.0)
        
       
        let button   = UIButton(type: UIButtonType.system) as UIButton
        button.frame = CGRect(x: 15, y: 30 + offset, width: 26, height: 26)
        button.setImage(UIImage(named: "prev_rev"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(didTapCloseButton), for: UIControlEvents.touchUpInside)

        randomViewLabel.text = "Message"
        selectableView.addSubview(randomViewLabel)
        selectableView.addSubview(button)
      
        view.addSubview(selectableView)
    }
    @objc func didTapCloseButton() {
        
        dismiss(animated: true, completion: nil)

    }
    func initChat()
    {
        let members = [selectedUser, JUser.current]
        
        if(self.chat == nil)
        {
            self.chat = Chat(members: members as! [JUser])
        }
        else
        {
            self.collectionView.reloadData()
            
        }
       //
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addViewOnTop()
        initChat()
        self.collectionView?.collectionViewLayout.sectionInset = UIEdgeInsets(top: 66, left: 10, bottom: 0, right: 10)
       
        setupJSQMessagesViewController()
        tryObservingMessages()
    //    tryObservingMessages2()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        JunSoftUtil.shared.isDetail = true
  
        /*
        UserService.following { [weak self] (following) in
            print(following)
            
            DispatchQueue.main.async {
                //  self?.tableView.reloadData()
            }
        }
         */
     //   let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
     //   appDelegate.setMessageObserver(chatKey: self.chat.key!)
        //setMessageObserver
    }
    deinit {
        messagesRef?.removeObserver(withHandle: messagesHandle)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        setupJSQMessagesViewController()
   }
    
    func setupJSQMessagesViewController() {
        // 1. identify current user
        senderId = JUser.current.uid
        senderDisplayName = JUser.current.username
      //  title = chat.title
      
        // 2. remove attachment button
        
        inputToolbar.contentView.leftBarButtonItem = nil
        
        // 3. remove avatars
        collectionView!.collectionViewLayout.messageBubbleLeftRightMargin = 10
        
      //  collectionView!.collectionViewLayout.messageBubbleLeftRightMargin = 10
        
       // collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
       // collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
   
  
    func tryObservingMessages() {
        guard let chatKey = chat?.key else { return }
     
        //observeChangeMessages
        messagesHandle = ChatService.observeMessages(forChatKey: chatKey, completion: { [weak self] (ref, message) in
                self?.messagesRef = ref
        
            if let message = message {
                    self?.messages.append(message)
                    self?.finishReceivingMessage()
                  }
            })
    }
    func tryObservingMessages2() {
        guard let chatKey = chat?.key else { return }
        
        //observeChangeMessages
        ChatService.observeMessages2(forChatKey: chatKey, completion: { (message) in
            //self?.messagesRef = ref
           
        })
    }
}

// MARK: - JSQMessagesCollectionViewDataSource

extension ChatViewController {
    // 1
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    // 2
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    // 3
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item].jsqMessageValue
    }
  
    // 4
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let sender = message.sender
      
        if sender.uid == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
  
    // 5
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView?.textColor = (message.sender.uid == senderId) ? .white : .black
        //cell.avatarImageView
        
        UserService.show(forUID: message.sender.uid,completion: { (user)in
            
            // let profileURL = user?.profile_url
            // cell.fromImg
            UIImage.circleImage(with: URL(string: (user?.profile_url)!)!, to: cell.avatarImageView)
            
        })
      //  UIImage.circleImage(with: URL(string: (user?.profile_url)!)!, to: cell.avatarImageView)
        
        return cell
    }
}

extension ChatViewController {
    func sendMessage(_ message: Message) {
        // 1
        if chat?.key == nil {
            // 2
            ChatService.create(from: message, with: chat, completion: { [weak self] chat in
                guard let chat = chat else { return }
          
                self?.chat = chat
                
                // 3
                    self?.tryObservingMessages()
            })
        } else {
            // 4
         
            var receive = ""
            for member in chat.memberUIDs
            {
                if(member.compare( message.sender.uid ).rawValue != 0)
                {
                  //  selectedUser = member.
                    receive = member
                }
            }
            print(receive)
            let ref = Database.database().reference().child("mstatus").child(receive).child(chat.key!)
            
            let viewDict = ["sender" : Auth.auth().currentUser?.displayName,
                            "content" : message.content,
                            "chat_key" : chat.key
                            
            ]
          
            
        //    self.SendMessagePush(msg: mstatusData!["content"] as! String, sender: mstatusData!["sender"] as! String)
            
            
            ref.updateChildValues(viewDict)
            
            
            ChatService.sendMessage(message, for: chat)
            
            let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            
            UserService.getUserToken(uid:receive, completion: {  (token) in
                
                appDelegate.SendMessagePush(msg: message.content, sender: (Auth.auth().currentUser?.displayName)!,to:token!)
            })
         
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // 1
        
        
        let message = Message(content: text)
        // 2
        sendMessage(message)
        // 3
        finishSendingMessage()
        
        // 4
            JSQSystemSoundPlayer.jsq_playMessageSentAlert()
    }
}
