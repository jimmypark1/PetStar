//
//  ChatListViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 19..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MaterialComponents
import RSLoadingView
import GoogleMobileAds

class ChatListViewController: MDCCollectionViewController {

    let paginationHelper = MGPaginationHelper<JUser>(pageSize:10, serviceMethod: UserService.usersExcludingCurrentUser)

    var chats = [Chat]()
    var chat :Chat!
    var userChatsHandle: DatabaseHandle = 0
    var userChatsRef: DatabaseReference?
    
    var sizingCell: ChatListCell!
    var messages = [Message]()
    var messagesHandle: DatabaseHandle = 0
    var messagesRef: DatabaseReference?
    
    var lastSenderMessage:String!
    var bannerView: GADBannerView!

    @IBOutlet weak var tableView:UITableView!

    func initCollectionView()
    {
        let nib = UINib(nibName: "ChatListCell", bundle: nil)
        
        guard let collectionView = collectionView else {
            return
        }
        collectionView.register(nib, forCellWithReuseIdentifier: "ChatListCell")
       
        sizingCell = Bundle.main.loadNibNamed("ChatListCell", owner: self, options: nil)?[0]
            as? ChatListCell
        
        self.styler.cellStyle = .card
        self.styler.cellLayoutType = .grid
        self.styler.gridColumnCount = 1
        let insets = self.collectionView(collectionView,
                                         layout: collectionViewLayout,
                                         insetForSectionAt: 0)
       
        
        let cellFrame = CGRect(x: 0, y: 0, width: collectionView.bounds.width - insets.left - insets.right,
                               height: collectionView.bounds.height)
        
        let user:UserDefaults = UserDefaults.standard
        
        let bAD:Bool = user.bool(forKey: "isADPurchased")
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if( bAD == false && appDelegate.isSimulator == false)
        {
            var rect = collectionView.frame
            rect.size.height = rect.size.height - 66
            collectionView.frame = rect
            
        }
        
        sizingCell.frame = cellFrame
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        // bannerView.frame = CGRect(x:0,y:166,width:self.view.bounds.size.width, height:66)
        
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(displayP3Red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        
        initCollectionView()
        let user:UserDefaults = UserDefaults.standard
        
        let bAD:Bool = user.bool(forKey: "isADPurchased")
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if( bAD == false && appDelegate.isSimulator == false)
        {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            addBannerViewToView(bannerView)
            
        }
    
        // Do any additional setup after loading the view.
        
    }
    @IBAction func didTapNewMessage(_ sender: UIBarButtonItem) {
        // self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        // self.navigationController?.popViewController(animated: true)
        
        performSegue(withIdentifier: "exec_new_msg", sender: nil)
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "add_m"), style: .plain, target: self, action: #selector(didTapNewMessage(_:)))
        
        self.tabBarController?.navigationItem.title  = "Messages"
        self.tabBarController?.navigationItem.rightBarButtonItem = rightButton
       
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        let user:UserDefaults = UserDefaults.standard
        let bAD:Bool = user.bool(forKey: "isADPurchased")
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if( bAD == false && appDelegate.isSimulator == false)
        {
            if(appDelegate.isServiceAD == false)
            {
                bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            }
            else
            {
                bannerView.adUnitID = "ca-app-pub-7915959670508279/4337053616"
            }
            bannerView.rootViewController = self
            let request = GADRequest()
            //  request.testDevices = @[ @"e65885a6f48dfc84c9ae2de2872759fd" ];
            bannerView.load(request)

            
        }
        else
        {
            if(bannerView != nil)
            {
                bannerView.removeFromSuperview()
                bannerView = nil
                
            }
        }
      
        let loadingView = RSLoadingView()
        loadingView.show(on: self.view)
        
        userChatsHandle = UserService.observeChats { [weak self] (ref, chats) in
            self?.userChatsRef = ref
            self?.chats = chats.reversed()
                // 3
       
            DispatchQueue.main.async {
                //  self?.tableView.reloadData()
               
                self?.collectionView?.reloadData()
                RSLoadingView.hide(from: (self?.view)!)
            }
            
          
            
            ///
            
        }
 
        /*
        UserService.following(completion: {(followings) in
            
            print("following")
            for following in followings {
                ChatService.checkForExistingChat(with: following) { (chat) in
                    
                    print("following")
                    if(chat != nil)
                    {
                        self.chats.append(chat!)
                        
                    }
                    // 4
                    //   print(char)
                    //sender.isEnabled = true
                    // self.existingChat = chat
                    
                    //self.performSegue(withIdentifier: "toChat", sender: self)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        })
 */
        /*
        ChatService.checkForExistingChat(with: selectedUser) { (chat) in
            // 4
         //   print(char)
            //sender.isEnabled = true
           // self.existingChat = chat
           
            //self.performSegue(withIdentifier: "toChat", sender: self)
        }
        */
        
    }
    deinit {
        // 4
        userChatsRef?.removeObserver(withHandle: userChatsHandle)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "exec_chat"{
            
            if let chatViewController = segue.destination as? ChatViewController{
                chatViewController.chat = self.chat
              
            }
            
        }
        
        //
        
        
    }
   
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int
    {
        // return self.itemArray.count
        return chats.count
      
    }
    
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatListCell", for: indexPath) as! ChatListCell;
        
        configure(cell: cell, atIndexPath: indexPath)
        
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, cellHeightAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.chat = chats[indexPath.row]
        
        performSegue(withIdentifier: "exec_chat", sender: nil)

    }
    func sendNoti()
    {
        
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.sendNoti()
        
    }
    func configure(cell: ChatListCell, atIndexPath indexPath: IndexPath) {
        let chat = chats[indexPath.row]
      //  cell.titleLabel.text = chat.title
        let fromUIDs = chat.memberUIDs
       
        var fromUID = fromUIDs[0]
        for uid in fromUIDs
        {
            if(Auth.auth().currentUser?.uid != uid)
            {
                fromUID = uid
                
            }
        }
        
        let message:String = chat.lastMessage!
        let split = message.components(separatedBy:":")
      
        if(Auth.auth().currentUser?.displayName == split[0])
        {
            // outcome
            cell.alarm.image = UIImage(named: "outcomming")
        }
        else
        {
            //income
            cell.alarm.image = UIImage(named: "incomming")
        }
        //static func show(forUID uid: String, completion: @escaping (JUser?) -> Void) {
        
        UserService.show(forUID: fromUID,completion: { (user)in
            
           // let profileURL = user?.profile_url
           // cell.fromImg
            UIImage.circleImage(with: URL(string: (user?.profile_url)!)!, to: cell.fromImg)
            
        })
     //   split(message) {$0 == ":"}
        cell.lastMessageLabel.text = split[1]
        cell.time.text = chat.lastMessageSent?.timeAgo()
        
        
        /*
        let user = users[indexPath.row]
        
        cell.delegate = self
        cell.index = indexPath.row
        //  cell.followButton.isSelected = user.isFollowed
        cell.usernameLabel.text = user.username
        
        if(user.isFollowing == true)
        {
            cell.followButton.setImage(UIImage(named: "remove_user"), for: .normal)
            
        }
        else
        {
            cell.followButton.setImage(UIImage(named: "add_user"), for: .normal)
            
        }
 
        UIImage.circleImage(with: URL(string: user.profile_url)!, to: cell.profile)
        */
        //   cell.profile.setImageWith(URL(string: user.profile_url)! ,placeholderImage:UIImage(named: "cell_back"))
        
    }
}
/*
extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
        let chat = chats[indexPath.row]
        cell.titleLabel.text = chat.title
        cell.lastMessageLabel.text = chat.lastMessage
        return cell
    }
}
extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.chat = chats[indexPath.row]
        
        performSegue(withIdentifier: "exec_chat", sender: nil)

    }
}
 */
