//
//  PlayerViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 6..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import AFNetworking
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import GoogleMobileAds


class PlayerViewController: UIViewController {

    var strURL:String!
    var thumbURL:String!
    var avPlayer:AVPlayer!
    var post:JPost!
    var uploaderRef: DatabaseReference!
    var likesRef: DatabaseReference!
    var viewsRef: DatabaseReference!
    var byID: String!
    var parentCon:HomeViewController!
    var selectedUser:JUser!
    var bannerView: GADBannerView!

    var owner:ProfileViewController!
    
    @IBOutlet weak var playerView: UIImageView!
    @IBOutlet weak var byImg: UIImageView!
    @IBOutlet weak var by: UILabel!
    @IBOutlet weak var like: UILabel!
    @IBOutlet weak var viewsCount: UILabel!
    @IBOutlet weak var likeBt: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var playerViewHeightConstarint: NSLayoutConstraint!
   
    @IBOutlet weak var messageBt: UIButton!
    @IBOutlet weak var deleteBt: UIButton!
    
    fileprivate var contentView: UILabel!
    
    /// Bottom Bar views.
    fileprivate var imageView: UIImageView!
    fileprivate var dateFormatter: DateFormatter!
    fileprivate var dateLabel: UILabel!
    
    @objc func playerDidFinishPlaying() {
        print("Video Finished")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            let item = object as! AVPlayerItem;
            switch(item.status)
            {
            case AVPlayerItemStatus.failed:
                break
            case AVPlayerItemStatus.readyToPlay:
                print("ready")
           //     indicator.stopAnimating()
                
                break
            case AVPlayerItemStatus.unknown:
                break
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
      //  index = 0
        super.init(coder: aDecoder)
    }
    
    public init(post: JPost) {
     //   self.index = index
        self.post = post
        self.strURL = post.imageURL
        self.thumbURL = self.post.thumbURL
        
        
        super.init(nibName: nil, bundle: nil)
    }
    func prepareToolbar() {
       
        
      //  toolbar.titleLabel.text = "Photo Name"
      //  toolbar.detailLabel.text = "July 19 2017"
        
    }
    fileprivate func prepareImageView() {
        imageView = UIImageView()
        
        imageView.setImageWith(URL(string: self.thumbURL)! ,placeholderImage:UIImage(named: "cell_back"))
        
        if(self.post.mediaType == 1)
        {
            // video
           // indicator.startAnimating()
            
            
            avPlayer = AVPlayer(url: URL(string: self.strURL) as! URL)
            
            avPlayer.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
            let videoLayer:AVPlayerLayer = AVPlayerLayer(player: avPlayer)
            let rect:CGRect = imageView.bounds;
            videoLayer.frame = rect
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            
            imageView.layer.addSublayer(videoLayer)
            
            videoLayer.zPosition = 100
            avPlayer.play()
            
        }
        
        
    }
    func preparePresenterCard() {
     
    }
    @IBAction func didTapClose(_ sender: UIBarButtonItem) {
        close()
    }
    func initLeftBar()
    {
        let leftButton = UIBarButtonItem(image: UIImage(named: "prev"), style: .plain, target: self, action: #selector(didTapClose(_:)))
        
       
        self.tabBarController?.navigationItem.leftBarButtonItem = leftButton
        self.tabBarController?.navigationItem.leftBarButtonItem?.tintColor = UIColor(displayP3Red: 237.0/255.0, green: 246.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(self.post.mediaType == 1)
        {
            avPlayer.pause()
            
        }
        // NotificationCenter.default.removeObserver(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(self.post.mediaType == 1)
        {
            avPlayer.play()
        }
        let bounds = self.view.bounds
        playerViewHeightConstarint.constant = bounds.size.width
        
        if( self.post.poster.uid != Auth.auth().currentUser?.uid)
        {
            self.messageBt.isHidden = false
            self.deleteBt.isHidden = true
        }
        else
        {
            self.messageBt.isHidden = true
            self.deleteBt.isHidden = false
            
        }
        //print(bounds.size.width)
        
    }
    @IBAction func deleteAction()
    {
        
        
        let title =  "Warning"
        let message =  "Are you sure you want to delete Content?"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //  alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) in
            
            //Implement action
            
           
            PostService.delete(self.post, completion:
                { (success) in
                    
                    if(success == true)
                    {
                        self.dismiss(animated: true, completion: nil)
                        self.owner.loadData()
                    }
                    
            })
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            
            //Implement action
            
        }
        
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        
        
        
        present(alert, animated: true, completion: nil)
        
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
     //   self.tabBarController?.navigationItem.backBarButtonItemnavigationItem
        
      
       // self.post.key
        PostService.views(for: self.post)
        let user:UserDefaults = UserDefaults.standard
        
        let bAD:Bool = user.bool(forKey: "isADPurchased")
        if( bAD == false)
        {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            
            addBannerViewToView(bannerView)
            
           
            let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            if(appDelegate.isServiceAD == false)
            {
                bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            }
            else
            {
                bannerView.adUnitID = "ca-app-pub-7915959670508279/1061396854"
            }
            bannerView.rootViewController = self
            let request = GADRequest()
            //  request.testDevices = @[ @"e65885a6f48dfc84c9ae2de2872759fd" ];
            bannerView.load(request)

        }
      

        
        if(self.post.mediaType == 1)
        {
            // video
            indicator.startAnimating()
            
            playerView.setImageWith(URL(string: self.thumbURL)! ,placeholderImage:UIImage(named: "cell_back"))
            
            avPlayer = AVPlayer(url: URL(string: self.strURL) as! URL)
            
            avPlayer.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
            let videoLayer:AVPlayerLayer = AVPlayerLayer(player: avPlayer)
            let rect:CGRect = playerView.bounds;
            videoLayer.frame = rect
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            
            playerView.layer.addSublayer(videoLayer)
            
            
          //  avPlayer.play()
            
        }
        else
        {
            indicator.isHidden = true
            playerView.setImageWith(URL(string: self.thumbURL)! ,placeholderImage:UIImage(named: "cell_back"))
            
        }
        
       
        if(self.post.isLiked )
        {
            self.likeBt.setImage(UIImage(named: "filled-heart"), for: .normal)
            
        }
        else
        {
            self.likeBt.setImage(UIImage(named: "empty-heart"), for: .normal)
            
        }
        self.like.text = String(format: "%d", self.post.likeCount)
        self.by.text = self.post.poster.username
        
        self.byID = self.post.poster.uid
        
     
        self.byImg.layer.masksToBounds = true
        self.byImg.layer.cornerRadius = self.byImg.frame.size.width/2
        self.byImg.layer.borderWidth = 1
        self.byImg.layer.borderColor = UIColor.white.cgColor
        
        self.byImg.setImageWith(URL(string:self.post.poster.profile_url)! ,placeholderImage:nil)
        
    
        selectedUser = JUser(uid: self.post.poster.uid, username: self.post.poster.username, profile: self.post.poster.profile_url)
        self.viewsCount.text = String(format: "%d", self.post.viewsCount)
        
    
    }
    func prepareCloseButton() {
    
    }
    @objc
    func handleCloseButton(button: UIButton) {
        if(self.post.mediaType == 1)
        {
            avPlayer.currentItem?.removeObserver(self, forKeyPath: "status")
            
        }
       // toolbarController?.transition(to: HomeViewController())
        dismiss(animated: true, completion: nil)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let touch = touches.first
        let position = touch?.location(in: self.view)
        
        var rect:CGRect = byImg.frame;
       
        if(rect.contains(position!))
        {
            performSegue(withIdentifier: "exec_p_profile", sender: self.byID)
            
            
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "exec_p_profile"{
            
            if let profileViewController = segue.destination as? ProfileViewController{
                
                profileViewController.byID = self.byID
                profileViewController.byUser = self.selectedUser
            }
            
        }
       
        if segue.identifier == "exec_chat"{
            
            if let chatViewController = segue.destination as? ChatViewController{
                
                chatViewController.selectedUser = self.selectedUser
            }
            
        }
        
    }
    

    @IBAction func close()
    {
      
        if(self.post.mediaType == 1)
        {
            avPlayer.currentItem?.removeObserver(self, forKeyPath: "status")
            
        }
 
     //   dismiss(animated: true, completion: nil)
        self.view.window!.rootViewController?.dismiss(animated: false, completion: {
            if(self.parentCon != nil)
            {
                self.parentCon.reloadCollectionView()
                
            }
        })
        
        
    }
   
    @IBAction func likeTapped()
    {
        
        LikeService.setIsLiked(!post.isLiked, for: post) { (success) in
            // 5
            defer {
              //  likeButton.isUserInteractionEnabled = true
            }
            // 6
            guard success else { return }
                // 7
         
            if(self.post.isLiked)
            {
                self.likeBt.setImage(UIImage(named: "empty-heart"), for: .normal)
                
            }
            else
            {
                self.likeBt.setImage(UIImage(named: "filled-heart"), for: .normal)
                
            }
            
            self.post.likeCount += !self.post.isLiked ? 1 : -1
            self.post.isLiked = !self.post.isLiked
            self.like.text = String(format: "%d", self.post.likeCount)
            // 8
            
        }
      
    }
    func addViewCount()
    {
        //self.post.adjustLikes(addLike: true)
        
    }
    
    @IBAction func sendMessage()
    {
        
        performSegue(withIdentifier: "exec_chat", sender: nil)

    }
   
}
