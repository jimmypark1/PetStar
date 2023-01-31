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
import Hue
import Segmentio
import SDWebImage
import GoogleMobileAds
import Hero

class ChatListViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

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
   // var bannerView: GADBannerView!
    @IBOutlet weak var  bannerView: GADBannerView!
    
    @IBOutlet weak var  collectionView: UICollectionView!

    @IBOutlet weak var bannerHeight:NSLayoutConstraint!

    @IBOutlet weak var segmentioView:Segmentio!

    var likeList:NSMutableArray!
    
    let dispatchGroup = DispatchGroup()

    @IBOutlet weak var tableView:UITableView!

    func initCollectionView()
    {
        var offset:CGFloat = 0.0
        var dummy:CGFloat = 0.0
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
                offset = 20.0
                dummy = 25
            default:
                print("unknown")
            }
        }
        
        let nib = UINib(nibName: "ChatListCell", bundle: nil)
        
        guard let collectionView = collectionView else {
            return
        }
        collectionView.register(nib, forCellWithReuseIdentifier: "ChatListCell")
       
        sizingCell = Bundle.main.loadNibNamed("ChatListCell", owner: self, options: nil)?[0]
            as? ChatListCell
        
     //   let segmentioViewRect = CGRect(x: 0, y: 66 + offset, width: UIScreen.main.bounds.width, height: 50)
     //   segmentioView = Segmentio(frame: segmentioViewRect)
        
        var content = [SegmentioItem]()
        
        let follower = SegmentioItem(title: "Messages",
                                     image: nil )
        let foryou = SegmentioItem(title: "Likes",
                                   image: nil )
        
        
        content.append(follower)
        content.append(foryou)
        
        let indicator =  SegmentioIndicatorOptions(
            type: .bottom,
            ratio: 1,
            height: 5,
            color: .red
        )
        let states = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: .black
            ),
            selectedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: .black
            ),
            highlightedState: SegmentioState(
                backgroundColor: UIColor.lightGray.withAlphaComponent(0.6),
                titleFont: UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: .black
            )
        )
        let options = SegmentioOptions(
            backgroundColor: .white,
            segmentPosition: SegmentioPosition.dynamic,
            scrollEnabled: true,
            indicatorOptions: indicator,
            horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(color:UIColor.clear),
            verticalSeparatorOptions: SegmentioVerticalSeparatorOptions(color:UIColor.clear),
            imageContentMode: .center,
            labelTextAlignment: .center,
            segmentStates: states
        )
        segmentioView.setup(
            content: content,
            style: SegmentioStyle.onlyLabel,
            options: options
        )
        segmentioView.selectedSegmentioIndex = 0
        
        view.addSubview(segmentioView)
        /*
        self.styler.cellStyle = .card
        self.styler.cellLayoutType = .grid
        self.styler.gridColumnCount = 1
        let insets = self.collectionView(collectionView,
                                         layout: collectionViewLayout,
                                         insetForSectionAt: 0)
       
        
        
     
   
        var rect = collectionView.frame
        rect.origin.y = rect.origin.y + 60 + 60 + offset
        rect.size.height = rect.size.height - 120  - offset - dummy
        collectionView.frame = rect
        
        let cellFrame = CGRect(x: 0, y: 110, width: collectionView.bounds.width - insets.left - insets.right,
                               height: collectionView.bounds.height)
        */
        let user:UserDefaults = UserDefaults.standard
        
        let bAD:Bool = user.bool(forKey: "isProUpgradePurchased1")
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        /*
        if( bAD == false )//&& appDelegate.isSimulator == false)
        {
            var rect = collectionView.frame
            rect.size.height = rect.size.height - 66
            collectionView.frame = rect
            
        }
        */
     //   sizingCell.frame = cellFrame
        
    
        
        
        segmentioView.valueDidChange = { segmentio, segmentIndex in
            
            AudioServicesPlaySystemSound(1521)
            
            if(segmentIndex == 0)
            {
                self.tabBarController?.navigationItem.title  = "Messages"
                
                // Messages
                if(self.likeList != nil)
                {
                    self.likeList.removeAllObjects()
                    
                }
               // self.collectionView?.reloadData()
                if(Auth.auth().currentUser != nil)
                {
                    let loadingView = RSLoadingView()
                    loadingView.show(on: self.view)
                    
                    self.userChatsHandle = UserService.observeChats { [weak self] (ref, chats) in
                        self?.userChatsRef = ref
                        self?.chats = chats.reversed()
                        // 3
                        
                        DispatchQueue.main.async {
                            //  self?.tableView.reloadData()
                            
                            self?.collectionView?.reloadData()
                            RSLoadingView.hide(from: (self?.view)!)
                        }
                    }
                }
            }
            else
            {
                self.tabBarController?.navigationItem.title  = "Likes"
                
                if(self.chats.count != nil )
                {
                    self.chats.removeAll()
                    self.collectionView?.reloadData()
                }
                
                LikeService.getLikeList(completion:{ (likes) in
                    print(likes)
                    self.likeList = likes
                    self.collectionView?.reloadData()
                    
                })
                
            }
           
        }
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
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.minimumLineSpacing = 10
  
        let width = (UIScreen.main.bounds.size.width )
        layout.itemSize = CGSize(width: width,height: 50)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        initCollectionView()
        let user:UserDefaults = UserDefaults.standard
        
        let bAD:Bool = user.bool(forKey: "isProUpgradePurchased1")
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if( bAD == false && appDelegate.isSimulator == false)
        {
           // bannerView = GADBannerView(adSize: kGADAdSizeBanner)
           // addBannerViewToView(bannerView)
            
        }
    
        // Do any additional setup after loading the view.
        
    }
    @IBAction func didTapNewMessage(_ sender: UIBarButtonItem) {
        // self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        // self.navigationController?.popViewController(animated: true)
       // AudioServicesPlaySystemSound(1521)
        
        if(Auth.auth().currentUser != nil)
        {
            performSegue(withIdentifier: "exec_new_msg", sender: nil)
            
        }
        else
        {
            performSegue(withIdentifier: "exec_c_login", sender: nil)
            
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        JunSoftUtil.shared.isDetail = true
  
        var offset:CGFloat = 0.0
        var dummy:CGFloat = 0.0
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
                offset = 20.0
                dummy = 25
            default:
                print("unknown")
            }
        }
        let user:UserDefaults = UserDefaults.standard
        
        var bAD:Bool = user.bool(forKey: "isProUpgradePurchased1")
     
      //  bAD = true
        if( bAD == true || appDelegate.isSimulator == true)
        {
            var rect:CGRect! = collectionView?.frame
            rect.origin.y = 120 + offset
            rect.size.height = self.view.frame.size.height - 120 - offset
            collectionView?.frame = rect
            
        }
        else
        {
            var rect:CGRect! = collectionView?.frame
            rect.origin.y = 120 + offset
            rect.size.height = self.view.frame.size.height - 120 - offset - 66
            collectionView?.frame = rect
            
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "add_m"), style: .plain, target: self, action: #selector(didTapNewMessage(_:)))
        rightButton.tintColor = UIColor(hex: "d4d2d2")
        self.tabBarController?.navigationItem.title  = "Messages"
        self.tabBarController?.navigationItem.rightBarButtonItem = rightButton
       
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        let user:UserDefaults = UserDefaults.standard
        let bAD:Bool = user.bool(forKey: "isProUpgradePurchased1")
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if( bAD == false && appDelegate.isSimulator == false)
        {
            if(appDelegate.isServiceAD == false)
            {
                bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            }
            else
            {
                bannerView.adUnitID = "ca-app-pub-7915959670508279/1095516870"
            }
            bannerView.rootViewController = self
            let request = GADRequest()
            //  request.testDevices = @[ @"e65885a6f48dfc84c9ae2de2872759fd" ];
            bannerView.load(request)

            
        }
        else
        {
            bannerHeight.constant = 0
    
        }
        let defaults = UserDefaults.standard
        
        let userData = defaults.object(forKey: Constants.UserDefaults.currentUser) as? Data
        if(Auth.auth().currentUser != nil)
        {
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
            }
        }
        else
        {
            let offset:CGFloat = 66.0
            //     performSegue(withIdentifier: "exec_login", sender: nil)
            let imgView = UIImageView(frame: CGRect(x:0,y:66,width:self.view.frame.size.width,height:self.view.frame.size.height - 2 * 66))
            
            imgView.isUserInteractionEnabled = true
            
            imgView.contentMode = .scaleAspectFit
            imgView.image = UIImage(named: "hi")
            
            let labelWidth = 1.2 * self.view.frame.size.width / 3.0
            let x = ( self.view.frame.size.width - labelWidth - 150 - 10) / 2.0
            let descView = UILabel(frame: CGRect(x:x,y: offset + 28 , width:labelWidth,height:20))
            
            descView.font =  UIFont(name: "Helvetica Neue", size: 13)
            
            descView.text = "Sign in for more fun!"
            descView.backgroundColor = UIColor.clear
            descView.textAlignment = .center
            
            
            let button   = UIButton(type: UIButtonType.custom) as UIButton
            
            button.backgroundColor = UIColor.init(red: 27.0/255.0, green: 147.0/255.0, blue: 216.0/255.0, alpha: 1.0)
            button.titleLabel?.textColor = UIColor.white
            button.titleLabel?.font =  UIFont(name: "Helvetica Neue", size: 13)
            button.frame = CGRect(x: labelWidth + x + 10, y: offset + 25 , width: 150, height: 30)
            button.setTitle("Let's Sign in", for: UIControlState.normal)
            button.addTarget(self, action: #selector(self.didTapSignIn), for: UIControlEvents.touchUpInside)
            button.layer.zPosition = 200
            imgView.addSubview(descView)
            imgView.addSubview(button)
            //self.view.addSubview(button)
            
            self.collectionView?.backgroundView = imgView
        }
        
  
 
        
        
    }
    @objc func didTapSignIn() {
        
        //dismiss(animated: true, completion: nil)
        //   self.tabBarController?.selectedIndex = 1
        performSegue(withIdentifier: "exec_c_login", sender: nil)
        
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
        //exec_likes_post
        if segue.identifier == "exec_likes_post"{
            
            if let playerViewController = segue.destination as? PlayerViewController{
                
                var destinationViewController = segue.destination
                let selectedPost =   sender as! JPost
                // Set the modal presentation style of your destinationViewController to be custom.
                /*
                destinationViewController.modalPresentationStyle = UIModalPresentationStyle.custom
                
                // Create a new instance of your fadeTransition.
                
                let fadeTransition = FadeTransition()
                
                // Tell the destinationViewController's  transitioning delegate to look in fadeTransition for transition instructions.
                destinationViewController.transitioningDelegate = fadeTransition as! UIViewControllerTransitioningDelegate
                fadeTransition.duration = 0.15
                */
                playerViewController.strURL = selectedPost.imageURL
                playerViewController.thumbURL = selectedPost.imageURL
                playerViewController.post = selectedPost
               // playerViewController.owner2 = self
            }
            
        }
        //exec_likelist
        //
        if segue.identifier == "exec_likelist"{
            
            if let listViewCon = segue.destination as? LikeListViewController{
               // chatViewController.chat = self.chat
                listViewCon.list = sender as! LikeList
            }
            
        }
        
        
    }
   
     func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int
    {
        // return self.itemArray.count
        if( self.segmentioView.selectedSegmentioIndex == 0)
        {
            return chats.count
            
        }
        else
        {
            //return 0
            if(self.likeList != nil)
            {
                return self.likeList.count
                
            }
            else
            {
                return 0
            }
        }
      
    }
    
    
     func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatListCell", for: indexPath) as! ChatListCell;
        
        cell.hero.modifiers = [.fade, .scale(0.5)]
        
        if( self.segmentioView.selectedSegmentioIndex == 0)
        {
            cell.alarm.isHidden = false
            cell.postImage.isHidden = true
            configure(cell: cell, atIndexPath: indexPath)
            
        }
        else
        {
            cell.cellDelegate = self
            cell.alarm.isHidden = true
            cell.postImage.isHidden = false
            
            let dict:LikeList = self.likeList.object(at: indexPath.row) as! LikeList
            var text:String = ""
            cell.likeList = dict
            PostService.show(forKey: dict.postKey, posterUID: JUser.current.uid) { (post) in
                
                //dispatchGroup0.enter()
             //   cell.alarm.image
                cell.postImage.contentMode = .scaleAspectFill
                cell.postImage.sd_setImage(with:URL(string: (post?.thumbURL)!)!, placeholderImage: UIImage(named: "cell_back"))
                
               
            }
            var cnt = 0
            for user in dict.list{
                dispatchGroup.enter()
                print(user.key)
                UserService.show(forUID: user.key,completion: { (user)in
                    
                    // let profileURL = user?.profile_url
                    // cell.fromImg
                    // UIImage.circleImage(with: URL(string: (user?.profile_url)!)!, to: cell.fromImg)
                    if(cnt == 0)
                    {
                        cell.fromImg.layer.masksToBounds = true
                        cell.fromImg.layer.cornerRadius = cell.fromImg.frame.size.width / 2.0
                        
                      //  UIImage.circleImage(with: URL(string: (user?.profile_url)!)!, to: cell.fromImg)
                        cell.fromImg.sd_setImage(with:URL(string: (user?.profile_url)!)!, placeholderImage: UIImage(named: "cell_back"))
                        
                    }
                    text.append((user?.username)!)
                    if(cnt < (dict.list.count - 1) )
                    {
                        text.append(", ")
                      
                        
                    }
                    
                    cnt = cnt + 1
                    
                    self.dispatchGroup.leave()
                    
                })
            }
            cell.time.text = String(format: "%d people likes this post", dict.list.count)
          
            dispatchGroup.notify(queue: .main, execute: {
              //  completion(posts.reversed())
                cell.lastMessageLabel.textColor = UIColor(hex: "eec9c9")
                 cell.lastMessageLabel.text = text
            })
           
        }
 
        
        
        return cell
    }
     func collectionView(_ collectionView: UICollectionView, cellHeightAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        AudioServicesPlaySystemSound(1521)
     
        if( self.segmentioView.selectedSegmentioIndex == 0)
        {
            self.chat = chats[indexPath.row]
            performSegue(withIdentifier: "exec_chat", sender: nil)

        }
        else
        {
           //
            let dict:LikeList = self.likeList.object(at: indexPath.row) as! LikeList
            
            performSegue(withIdentifier: "exec_likelist", sender: dict)
     }
   
    }
    
    func viewLikePost(list:LikeList)
    {
        AudioServicesPlaySystemSound(1521)
        
        PostService.show(forKey: list.postKey, posterUID: JUser.current.uid) { (post) in
            
            //dispatchGroup0.enter()
            self.performSegue(withIdentifier: "exec_likes_post", sender: post)
            
        }
    }
   
    func configure(cell: ChatListCell, atIndexPath indexPath: IndexPath) {
        
        let chat = chats[indexPath.row]
        
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
        
        UserService.show(forUID: fromUID,completion: { (user)in
            
            // let profileURL = user?.profile_url
            // cell.fromImg
            UIImage.circleImage(with: URL(string: (user?.profile_url)!)!, to: cell.fromImg)
            
        })
        
        cell.lastMessageLabel.text = split[1]
        cell.time.text = chat.lastMessageSent?.timeAgo()
      
    }
}

