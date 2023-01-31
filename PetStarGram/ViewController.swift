//
//  ViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 2..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
//import PAPermissions
import Sparrow
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper

import MMPlayerView
import AFNetworking

import TRMosaicLayout
import GoogleSignIn




class ViewController: UIViewController,UIPageViewControllerDataSource, UICollectionViewDelegate, UICollectionViewDataSource,GIDSignInUIDelegate,GIDSignInDelegate
{

    lazy var mmPlayerLayer: MMPlayerLayer = {
        let l = MMPlayerLayer()
        l.cacheType = .memory(count: 5)
        l.coverFitType = .fitToPlayerView
        l.videoGravity = AVLayerVideoGravity.resizeAspectFill
      //  l.replace(cover: CoverA.instantiateFromNib())
        return l
    }()

//    let microphoneCheck = PAMicrophonePermissionsCheck()
//    let cameraCheck = PACameraPermissionsCheck()

 //   let permissins: [SPRequestPermissionType] = [.camera, .photoLibrary,.microphone, .notification]

    let transitionManager = TransitionManager()
    var pageViewController : UIPageViewController!
    var pageTitles : NSArray!
    var pageImages : NSArray!
    
    var bannerView: GADBannerView!

    var uploaderRef: DatabaseReference!
   // var posts = [Post]()
    var posts = [JPost]()
    var selectedVideoURL: String!
    var selectedThumbURL: String!
    var selectedPost: JPost!
    
    var bFaceBookLogInProcessing:Bool!
    
    @IBOutlet var emailBt: UIButton!
    @IBOutlet var facebookBt: UIButton!
    @IBOutlet var logoImg: UIImageView!
    @IBOutlet var titleLable: UILabel!
    
    @IBOutlet var addBt: UIButton!
    @IBOutlet var homeBt: UIButton!
    @IBOutlet var myBt: UIButton!
    @IBOutlet var notiBt: UIButton!
   
    
    
    @IBOutlet var backView: UIView!
    
    @IBOutlet var feedView: UICollectionView!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
   
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        bFaceBookLogInProcessing = true
        
        if let error = error {
            // ...
            return
        }
      //  self.facebookBt.isHidden = true
        self.feedView.isHidden = false
        self.homeBt.isHidden = false
        self.addBt.isHidden = false
        self.myBt.isHidden = false
        self.logoImg.isHidden = true
        self.titleLable.isHidden = true
  //      self.signInButton.isHidden = true
        //  self.emailBt.isHidden = true
   //     self.facebookBt.isHidden = true
        self.feedView.isHidden = false
        self.notiBt.isHidden = false
        self.backView.isHidden = true
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // ...
                return
            }
          //  self.facebookBt.isHidden = true
            self.feedView.isHidden = false
            self.homeBt.isHidden = false
            self.addBt.isHidden = false
            self.myBt.isHidden = false
            self.logoImg.isHidden = true
            self.titleLable.isHidden = true
            //  self.emailBt.isHidden = true
         //   self.facebookBt.isHidden = true
            self.feedView.isHidden = false
            self.notiBt.isHidden = false
            self.homeBt.setImage(UIImage(named: "home_on"), for: .normal)
           
            guard let firUser = Auth.auth().currentUser else { return }
            
            UserService.create(firUser) { (user) in
                guard let user = user else { return }
                print("Created new user: \(user.username)")
                JUser.setCurrent(user,writeToUserDefaults:true)
                let keychainResult = KeychainWrapper.standard.set((Auth.auth().currentUser?.uid)!, forKey: "uid")
                
                self.configureCell()
                self.bFaceBookLogInProcessing = false
                
            }
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func configureCell()
    {
         
        let defaults = UserDefaults.standard
        
      //   let _ = Auth.auth().currentUser
        
        let userData:Data = (defaults.object(forKey:Constants.UserDefaults.currentUser) as? Data)!
            
        let user = try?JSONDecoder().decode(JUser.self, from: userData)
            
        JUser.setCurrent(user!)
        /*
        UserService.posts(for: JUser.current) { (posts) in
            self.posts = posts
            self.feedView.isHidden = false
            
            self.feedView.reloadData()
           // self.tableView.reloadData()
        }
 
        UserService.timeline{ (posts) in
            self.posts = posts
            
            self.feedView.reloadData()
        }
        */
       /*
        
        _REF_POSTS.observe(.value, with: { (snapshot) in
                if var snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    snapshots = snapshots.reversed()
                    self.posts = [] // clear the old array
                    
                    for post in snapshots {
                        if let postDict = post.value as? Dictionary<String, Any> {
                            let key = post.key
                            let singlePost = Post(postKey: key, postData: postDict)
                            self.posts.append(singlePost)
                        }
                    }
                  //  self.tableView.reloadData()
                    self.feedView.isHidden = false
                    
                    self.feedView.reloadData()
                }
            })
 */
    }
    @IBAction func kakaoLogin(_ sender: UIButton) {
        guard let session = KOSession.shared() else { return }
        if session.isOpen() { session.close() }
        session.open { (error) in
            if session.isOpen() {
              //  KakaoTokenRequset().requestKakao(accessToken: session.accessToken)
                Auth.auth().signIn(withCustomToken: session.accessToken) { (user, error) in
                    if let error = error {
                        // ...
                        return
                    }
                  
                    let _DB_BASE = Database.database().reference()
                    let _STORAGE_BASE = Storage.storage().reference()
                    var _REF_BASE = _DB_BASE
                    var _REF_POSTS = _DB_BASE.child("posts")
                    var _REF_USERS = _DB_BASE.child("users")
                    
                    // Storage references
                    var _REF_POST_PICS = _STORAGE_BASE.child("post-pics")
                    var _REF_PROFILE_PICS = _STORAGE_BASE.child("profile-pics")
                    
                    let currentUserRef = _REF_USERS.child((Auth.auth().currentUser?.uid)!)
                    
                    currentUserRef.child("display_name").setValue(Auth.auth().currentUser?.displayName)
                    
                    
                    currentUserRef.child("image_url").setValue(Auth.auth().currentUser?.photoURL?.absoluteString)
                    
                    let keychainResult = KeychainWrapper.standard.set((Auth.auth().currentUser?.uid)!, forKey: "uid")
                    
                    self.configureCell()
                    self.bFaceBookLogInProcessing = false
                    
                    
                }
                
            } else {
              //  self.kakaoLoginFail(error: error!)
            }
        }
    }
    
    
   
    func processFaceBookLogin()
    {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
   
        bFaceBookLogInProcessing = true
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if (result?.isCancelled)!{
                    return
                }
                
                DispatchQueue.main.async { [unowned self] in
                   
           
                    self.feedView.isHidden = false
                    self.homeBt.isHidden = false
                    self.addBt.isHidden = false
                    self.myBt.isHidden = false
                    self.logoImg.isHidden = true
                    self.titleLable.isHidden = true
               
                    self.feedView.isHidden = false
                    self.notiBt.isHidden = false
                    self.backView.isHidden = true
                    
                    self.homeBt.setImage(UIImage(named: "home_on"), for: .normal)
                    
                    
                }
                
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        // ...
                        return
                    }
                    guard let firUser = Auth.auth().currentUser else { return }
                   
                    UserService.create(firUser) { (user) in
                        guard let user = user else { return }
                            print("Created new user: \(user.username)")
                        JUser.setCurrent(user,writeToUserDefaults:true)
                        let keychainResult = KeychainWrapper.standard.set((Auth.auth().currentUser?.uid)!, forKey: "uid")
                        
                        self.configureCell()
                        self.bFaceBookLogInProcessing = false
                        
                    }
                    
                
                    
                    
                    
                }
                
                
            }
        }
    }
    @IBAction func findFrinds()
    {
        performSegue(withIdentifier: "exec_friend", sender: self.selectedVideoURL)
        
    }
    
    @IBAction func googleSingIn()
    {
        GIDSignIn.sharedInstance().signIn()

    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
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
        // Do any additional setup after loading the view, typically from a nib.
        
      // self.feedView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: nil)
        self.feedView.contentInset = UIEdgeInsets(top: 260, left: 0, bottom: 0, right:0)
        
     //   addBt.addSubview(feedView)
        //85/201/248
        //237/246/250
       // initMatirial()
        feedView.backgroundColor = UIColor(displayP3Red: 237.0/255.0, green: 246.0/255.0, blue: 250.0/255.0, alpha: 1.0)
       
        backView.backgroundColor = UIColor(displayP3Red: 197.0/255.0, green: 233.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        
       // self.backView.layer.zPosition = 100
        self.logoImg.isHidden = true
        self.titleLable.isHidden = true
        
        facebookBt.layer.masksToBounds = true
        facebookBt.layer.cornerRadius = 10
        facebookBt.layer.borderWidth = 1
        facebookBt.layer.borderColor = UIColor(displayP3Red: 69.0/255.0, green: 194.0/255.0, blue: 245.0/255.0, alpha: 1.0).cgColor
        
        facebookBt.backgroundColor = UIColor.white
   
        emailBt.layer.masksToBounds = true
        emailBt.layer.cornerRadius = 10
        emailBt.layer.borderWidth = 1
        emailBt.layer.borderColor = UIColor(displayP3Red: 69.0/255.0, green: 194.0/255.0, blue: 245.0/255.0, alpha: 1.0).cgColor
        
        emailBt.backgroundColor = UIColor.white
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance().signInSilently()

        let mosaicLayout = TRMosaicLayout()
        feedView?.collectionViewLayout = mosaicLayout
        mosaicLayout.delegate = self
        
       

        if(Auth.auth().currentUser != nil)
        {
          //  self.emailBt.isHidden = true
           // self.facebookBt.isHidden = true
            
            feedView.isHidden = false
       
            self.homeBt.setImage(UIImage(named: "home_on"), for: .normal)
            
        }
        else
        {
            feedView.isHidden = true
            addBt.isHidden = true
            homeBt.isHidden = true
            myBt.isHidden = true
            notiBt.isHidden = true
            
            
            
        }
        bFaceBookLogInProcessing = false
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // NotificationCenter.default.removeObserver(self)
    }
    override func viewDidAppear(_ animated: Bool) {
       
        let user:UserDefaults = UserDefaults.standard
        
        let initSettings:Bool = user.bool(forKey: "INIT_SETTINGS")
        if(initSettings == false)
        {
            viewIntro()
            
        }
        else
        {
            if(Auth.auth().currentUser == nil && bFaceBookLogInProcessing == false)
            {
                print("logout")
                self.backView.isHidden = false
                
                feedView.isHidden = true
                addBt.isHidden = true
                homeBt.isHidden = true
                myBt.isHidden = true
                notiBt.isHidden = true
          //      self.signInButton.isHidden = false
                
            //    self.emailBt.isHidden = false
             //   self.facebookBt.isHidden = false
                
            }
            else
            {
                if(bFaceBookLogInProcessing == false)
                {
                    if((Auth.auth().currentUser?.displayName?.count)! > 0)
                    {
                    //    self.emailBt.isHidden = true
                    //    self.facebookBt.isHidden = true
                        
                        feedView.isHidden = false
                        
                        self.homeBt.setImage(UIImage(named: "home_on"), for: .normal)
                        
                        self.logoImg.isHidden = true
                        self.titleLable.isHidden = true
                      //  self.emailBt.isHidden = true
                      //  self.facebookBt.isHidden = true
                        self.backView.isHidden = true
                        self.addBt.isHidden = false
                        self.homeBt.isHidden = false
                        self.myBt.isHidden = false
                        self.notiBt.isHidden = false
                        
                        /////
                        // view feed
                        
                        configureCell()
                        
                        
                    }
                    else
                    {
                        self.logoImg.isHidden = false
                        self.titleLable.isHidden = false
                     //   self.emailBt.isHidden = false
                      //  self.facebookBt.isHidden = false
                        
                        self.addBt.isHidden = true
                        self.homeBt.isHidden = true
                        self.myBt.isHidden = true
                        self.notiBt.isHidden = true
                        
                    }
                }
             
            }
           
        }
        
   
    }
    /*
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            self.updateByContentOffset()
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(startLoading), with: nil, afterDelay: 0.3)
            
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
 */
    @IBAction func signInFB(){
        processFaceBookLogin()
    }
    func viewIntro()
    {
        self.pageTitles = NSArray(objects: "아름다운 필터로 찍으세요" , "공유 하세요","PetStarGram 사용권한")
        self.pageImages = NSArray(objects: "per_back" , "pet2" ,"")
        
        
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        
        let startVC = self.viewControllerAtIndex(index: 0) as IntroContentViewController
        startVC.parentCon = self
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController] , direction: .forward, animated: true, completion: nil)
        self.pageViewController.view.frame = CGRect(x:0,y:0,width:self.view.frame.width, height:self.view.frame.height )
        
        //self.pageViewController. = UIColor.blue
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        
        
        
        
    }
    
    func viewControllerAtIndex (index : Int) -> IntroContentViewController {
        
        let vc : IntroContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as! IntroContentViewController
        
        vc.pageIndex = index
        vc.imageFile = self.pageImages[index] as! String
        vc.titleText = self.pageTitles[index] as! String
        vc.parentCon = self
       //print(">>> : " ,vc.titleText)
        
        return vc
    }
    
    
    func viewPermissions()
    {
     //   SPRequestPermission.dialog.interactive.present(on: self, with: self.permissins)
        

    }
    func startService()
    {
        self.pageViewController.view.removeFromSuperview()
        
        homeBt.isHidden = true
        addBt.isHidden = true
        myBt.isHidden = true
        
        self.logoImg.isHidden = true
        self.titleLable.isHidden = true
      //  self.emailBt.isHidden = false
     //   self.facebookBt.isHidden = false
        
        
    }
    /**
     * 이전 ViewPageController 구성
     */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! IntroContentViewController
        vc.parentCon = self
        
        var index = vc.pageIndex as Int
        
        if( index == NSNotFound) {
            return nil
        }
        
        index = index + 1
        
        if (index == self.pageTitles.count) {
           // self.pageViewController.view.removeFromSuperview()
            return nil
        }
 
        
    
        return self.viewControllerAtIndex(index: index)
    }
    
    
   
    /**
     * 이후 ViewPageController 구성
     */
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
     {
      
        let vc = viewController as! IntroContentViewController
        var index = vc.pageIndex as Int
        vc.parentCon = self
        
        if( index == 0 || index == NSNotFound) {
            return nil
        }
        
        index = index - 1
        
        return self.viewControllerAtIndex(index: index)
    }
    
    
    /**
     * 인디케이터의 총 갯수
     */
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    
    /**
     * 인디케이터의 시작 포지션
     */
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    ////
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
       // return self.itemArray.count
        return self.posts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as! FeedCell;
        
        let post = posts[indexPath.row]
       
        let imageView = UIImageView()
        
        
        imageView.setImageWith(URL(string: post.thumbURL)! ,placeholderImage:UIImage(named: "cell_back"))
        imageView.frame = cell.frame
        
        cell.backgroundView?.layer.masksToBounds = true
        cell.backgroundView?.layer.cornerRadius = imageView.frame.size.width/5.0
        cell.backgroundView = imageView
        
        if( post.mediaType == 1)
        {
            let playIcon = UIImage(named: "play.png")
            let width = cell.frame.size.width/3
            let height = width
            let x =  (cell.frame.size.width - width)/2
            let y =  (cell.frame.size.height - height)/2
            
            cell.imgView.frame = CGRect(x:x,y:y,width:width,height:height)
            cell.imgView.image = playIcon
        }
        else
        {
            cell.imgView.image = nil
        }
        /*
        print(post.imageUrl)
      
        let imageView = UIImageView()
        
        
        imageView.setImageWith(URL(string: post.thumbUrl)! ,placeholderImage:UIImage(named: "cell_back"))
        imageView.frame = cell.frame
        
        cell.backgroundView?.layer.masksToBounds = true
        cell.backgroundView?.layer.cornerRadius = imageView.frame.size.width/5.0
        
        cell.backgroundView = imageView
        if( post.type == 1)
        {
            let playIcon = UIImage(named: "play.png")
            let width = cell.frame.size.width/3
            let height = width
            let x =  (cell.frame.size.width - width)/2
            let y =  (cell.frame.size.height - height)/2
            
            cell.imgView.frame = CGRect(x:x,y:y,width:width,height:height)
            cell.imgView.image = playIcon
        }
        else
        {
            cell.imgView.image = nil
        }
        */
        
        
        
        return cell
    }
  
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async { [unowned self] in
            let post = self.posts[indexPath.row]
            self.selectedPost = post
            self.selectedThumbURL = post.imageURL
            self.selectedVideoURL = post.imageURL
            self.selectedThumbURL = post.thumbURL
            self.selectedPost = post
            
            self.performSegue(withIdentifier: "exec_player", sender: self.selectedVideoURL)
            /*
          //  print(post.imageUrl)
            self.selectedVideoURL = post.imageUrl
            self.selectedThumbURL = post.thumbUrl
            self.selectedPost = post
            self.performSegue(withIdentifier: "exec_player", sender: self.selectedVideoURL)
            */
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "exec_player"{
            
            if let playerViewController = segue.destination as? PlayerViewController{
                
                playerViewController.strURL = selectedVideoURL
                playerViewController.thumbURL = self.selectedThumbURL
                playerViewController.post = self.selectedPost
            }
            
        }
        if segue.identifier == "exec_camera"{
            let cameraViewController = segue.destination as? CameraViewController
            cameraViewController?.transitioningDelegate = self.transitionManager
        }
        //
        
        
    }
    
  
}
extension ViewController: TRMosaicLayoutDelegate {
    
    func collectionView(_ collectionView:UICollectionView, mosaicCellSizeTypeAtIndexPath indexPath:IndexPath) -> TRMosaicCellType {
        // I recommend setting every third cell as .Big to get the best layout
        return indexPath.item % 3 == 0 ? TRMosaicCellType.big : TRMosaicCellType.small
    }
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: TRMosaicLayout, insetAtSection:Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    }
    
    func heightForSmallMosaicCell() -> CGFloat {
        return 120
    }
}




