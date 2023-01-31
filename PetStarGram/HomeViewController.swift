//
//  HomeViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 13..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import AFNetworking
import TRMosaicLayout
import MaterialComponents
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

import ESTabBarController_swift
import RSLoadingView

import Segmentio
import SDWebImage
import GoogleMobileAds

class HomeViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,GADFullScreenContentDelegate{
    
    var paginationHelper = MGPaginationHelper<JPost>(pageSize:10, serviceMethod: UserService.timeline)
    var paginationHelper2 = MGPaginationHelper<JPost>(pageSize:100, serviceMethod: UserService.postsAll)
    var paginationHelper3 = MGPaginationHelper<JPost>(pageSize:100, serviceMethod: UserService.recent)
    var paginationHelper4 = MGPaginationHelper<JPost>(pageSize:100, serviceMethod: UserService.popular)

    @IBOutlet  var feedView: UICollectionView!
    
    @IBOutlet  var collectionView: UICollectionView!
    
    var fadeTransition: FadeTransition!
    
    var posts = [JPost]()
    
    var selectedVideoURL: String!
    var selectedThumbURL: String!
    var selectedPost: JPost!
    var sizingCell: FeedCollectionViewCell!
    //var bannerView: GADBannerView!
    @IBOutlet weak var  bannerView: GADBannerView!

    @IBOutlet weak var   segmentioView: Segmentio!
    @IBOutlet weak var   bannerHeight: NSLayoutConstraint!

    let bottomBarView = MDCBottomAppBarView()

    let refresher = UIRefreshControl()
    var backgroundView:UIView!
  //  var backgroundView:UIImageView!
    private var interstitial: GADInterstitialAd?

    let homeButton = { () -> UIBarButtonItem in
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_home"), style: .plain, target: self, action: #selector(homeAction))
        button.accessibilityLabel = "Home"
        return button
    }()
    
    let myButton = { () -> UIBarButtonItem in
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_home"), style: .plain, target: self, action: #selector(homeAction))
        button.accessibilityLabel = "My"
        return button
    }()
    let blue = MDCPalette.blue.tint600
    
    let appBar = MDCAppBar()
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
      print("Ad did fail to present full screen content.")
    }

    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad will present full screen content.")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad did dismiss full screen content.")
       // showStore()
        let user:UserDefaults = UserDefaults.standard
        
        var bAD:Bool = user.bool(forKey: "isADPurchased")
      
        if(bAD == false)
        {
            showStore()
        }
    }
    @objc private func homeAction() {
        /*
        bottomBarView.subviews[2].subviews[1].subviews[0].tintColor = blue
        bottomBarView.subviews[2].subviews[1].subviews[0].accessibilityTraits = UIAccessibilityTraitSelected
        bottomBarView.subviews[2].subviews[1].subviews[1].tintColor = .gray
        bottomBarView.subviews[2].subviews[1].subviews[1].accessibilityTraits = UIAccessibilityTraitNone
        showFeed = false
        reloadFeed()
 */
    }
    func showFullAd()
    {
        //
  
        
        if interstitial != nil {
            interstitial!.present(fromRootViewController: (self.tabBarController?.navigationController)!)
          } else {
            print("Ad wasn't ready")
          }
    }
    func showAd()
    {
        let request = GADRequest()
      
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-7915959670508279/4947788511",
                                       request: request,
                             completionHandler: { [self] ad, error in
                               if let error = error {
                                 print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                 return
                               }
           interstitial = ad
            interstitial?.fullScreenContentDelegate = self
            showFullAd()
                            
          
        }
           
       )
    }
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Bottom App Bar (Swift)"
      //  self.addChildViewController(appBar.headerViewController)
        
        let color = UIColor(white: 0.2, alpha:1)
        /*
        appBar.headerViewController.headerView.backgroundColor = color
        appBar.navigationBar.tintColor = .white
        appBar.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
 */
        initTabBar()
       // self.initTabBar()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     //   commonInitBottomAppBarTypicalUseSwiftExample()
        //Auth.auth()
       // self.initTabBar()
      //  initTab()
        
    }
    
    override func viewWillLayoutSubviews() {
        
        UINavigationBar.appearance().barTintColor = UIColor.white
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
      //  self.view.backgroundColor = UIColor.white
        
    //    UINavigationBar.appearance().shadowImage = appDelegate.shadowImage
        
    //    appDelegate.navigationController.navigationBar.barTintColor = UIColor.white
    }
 
    @objc func didTapFloatingButton() {
        
 //       let cameraViewController = CameraViewController()
 //       present(cameraViewController, animated: true, completion: nil)
        performSegue(withIdentifier: "exec_camera", sender: nil)
        
    }

    func initTabBar()
    {
    //    return
        let titleLabel = UILabel()
        titleLabel.text = "Pet Star"
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "Amaranth", size: 24)
        titleLabel.sizeToFit()
        let attrs = [
            NSAttributedStringKey.foregroundColor: UIColor.red,
            NSAttributedStringKey.font: titleLabel.font
            ] as [NSAttributedStringKey : Any]
        
      //  UINavigationBar.appearance().titleTextAttributes = attrs
        
        navigationItem.leftBarButtonItems = [UIBarButtonItem.init(customView: UIImageView.init(image: UIImage(named: "logo_36")))]
 
        
        if let item = navigationItem.rightBarButtonItems?[0] {
            item.accessibilityLabel = ""
            item.accessibilityHint = "Double-tap to open your profile."
            if let photoURL = Auth.auth().currentUser?.photoURL {
                UIImage.circleButton(with: photoURL, to: item)
            }
        }
        
        self.title = "Pet Star"
        print(self.navigationController?.navigationBar.titleTextAttributes?.count)
      //  self.navigationController?.navigationBar.titleTextAttributes![.font] = UIFont.preferredFont(forTextStyle: .title3)
        
        bottomBarView.autoresizingMask = [ .flexibleWidth, .flexibleTopMargin ]
        
        view.addSubview(bottomBarView)
        
        bottomBarView.floatingButton.addTarget(self,
                                               action: #selector(didTapFloatingButton),
                                               for: .touchUpInside)
        
        // Set the image on the floating button.
        
        bottomBarView.floatingButton.setImage(#imageLiteral(resourceName: "ic_photo_camera_white"), for: .normal)
        bottomBarView.floatingButton.setImage(#imageLiteral(resourceName: "ic_photo_camera"), for: .highlighted)
        bottomBarView.floatingButton.accessibilityLabel = "Open camera"

        bottomBarView.floatingButtonPosition = .center
        
        //167/223/246
        // Theme the floating button.
        let colorScheme = MDCBasicColorScheme(primaryColor: UIColor(red: 167.0/255.0, green: 223.0/255.0, blue: 246.0/255.0, alpha: 1.0))
        
        //167/223/246
        MDCButtonColorThemer.apply(colorScheme, to: bottomBarView.floatingButton)
        
        navigationController?.setToolbarHidden(true, animated: false)
        homeButton.tintColor = blue
        myButton.tintColor = .gray
        UINavigationBar.appearance().tintColor = UIColor.white
       //ß MDCButtonColorThemer.apply(colorScheme, to: homeButton)
        
        bottomBarView.leadingBarButtonItems = [ homeButton, myButton ]

        bottomBarView.subviews[2].subviews[1].subviews[0].accessibilityTraits = UIAccessibilityTraitSelected
        bottomBarView.subviews[2].subviews[1].accessibilityTraits = UIAccessibilityTraitTabBar
        let inviteButton = UIBarButtonItem.init(image:UIImage(named: "my_24"), style: .plain, target: self, action: #selector(inviteTapped))
        inviteButton.tintColor = .gray
        inviteButton.accessibilityLabel = "invite friends"
        bottomBarView.trailingBarButtonItems = [ inviteButton ]
    }
    @objc func inviteTapped() {
        /*
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/userinfo.email",
                                             "https://www.googleapis.com/auth/userinfo.profile"]
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()
 */
    }
    
  
   
    
    func initCollectionView()
    {
        var offset:CGFloat = 0.0
        var dummy:CGFloat = 0.0
        
        let height = UIScreen.main.nativeBounds.height
        if UIDevice().userInterfaceIdiom == .phone {
            switch height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
            case 1334:
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436, 1792:
                print("iPhone X")
                offset = 40.0
                dummy = 25
            case 2437...:
                offset = 40.0
                dummy = 25
      
            default:
                print("unknown")
            }
        }
       // offset = 40.0
       // dummy = 25
/*
        let nib = UINib(nibName: "FeedCollectionViewCell", bundle: nil)
        
        guard let collectionView = collectionView else {
            return
        }
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        sizingCell = Bundle.main.loadNibNamed("FeedCollectionViewCell", owner: self, options: nil)?[0]
            as? FeedCollectionViewCell
        
        self.styler.cellStyle = .card
        self.styler.cellLayoutType = .grid
        self.styler.gridColumnCount = 1
        let insets = self.collectionView(collectionView,
                                         layout: collectionViewLayout,
                                         insetForSectionAt: 0)
        //self.collectionView?.collectionViewLayout.sectionInset = UIEdgeInsets(top: 66, left: 10, bottom: 0, right: 10)
        */
     //   let cellFrame = CGRect(x: 0, y: 110, width: collectionView.bounds.width - insets.left - insets.right,
     //                          height: collectionView.bounds.height)
        
        if #available(iOS 11.0, *) {
            print("ios 11")
        }
        else
        {
          //  collectionView.contentInset.top = -66
            
        }
      //  collectionView.contentInset.bottom = 44
        let user:UserDefaults = UserDefaults.standard
        
        var bAD:Bool = user.bool(forKey: "isADPurchased")
        /*
        bAD = true
        
        if( bAD == false)
        {
            var rect = collectionView.frame
            rect.origin.y = rect.origin.y + 60 + 60 + offset
            rect.size.height = rect.size.height - 110 - 66 - 66 - offset - dummy
            collectionView.frame = rect
            
        }
        else
        {
            var rect = collectionView.frame
            rect.origin.y = rect.origin.y + 60 + offset
            rect.size.height = rect.size.height - 110 - 66 - offset - dummy
            collectionView.frame = rect
            
        }
         */
        /*
        
        refresher.tintColor = UIColor.init(red: 27.0/256.0, green: 147.0/256.0, blue: 216.0/256.0, alpha: 1.0)
        refresher.addTarget(self, action:  #selector(loadData), for: .valueChanged)
        
       // refreshControl = refresher
        collectionView.addSubview(refresher)
        */
       // sizingCell.frame = cellFrame
        
    //    let segmentioViewRect = CGRect(x: 0, y: 66 + offset, width: UIScreen.main.bounds.width, height: 50)
      //  segmentioView = Segmentio(frame: segmentioViewRect)
        refresher.tintColor = UIColor.init(red: 27.0/256.0, green: 147.0/256.0, blue: 216.0/256.0, alpha: 1.0)
        refresher.addTarget(self, action:  #selector(loadData), for: .valueChanged)
        
       // refreshControl = refresher
        collectionView.addSubview(refresher)
        var content = [SegmentioItem]()
        
        let follower = SegmentioItem(title: "Timeline",
            image: nil )
        let foryou = SegmentioItem(title: "For you",
                                        image: nil )
        
        let recent = SegmentioItem(title: "Recently",
                                   image: nil )
        
        let popular = SegmentioItem(title: "TOP",
                                    image: nil )
        
        content.append(follower)
       // content.append(foryou)
        content.append(popular)
        content.append(recent)
        //  let position = SegmentioIndicatorOptions
       
       
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
        segmentioView.selectedSegmentioIndex = 2
        //segmentioView.backgroundColor = UIColor.white
        
        view.addSubview(segmentioView)
        
        
        segmentioView.valueDidChange = { segmentio, segmentIndex in
            print("Selected item: ", segmentIndex)
            self.posts.removeAll()
            let loadingView = RSLoadingView()
            loadingView.show(on: self.view)
            
            self.configure()
        }
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.minimumLineSpacing = 22
  
        let width = (UIScreen.main.bounds.size.width )
        layout.itemSize = CGSize(width: width,height: width + 120)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        
    }
    @objc func loadData() {
        
       
        configure()
        self.refresher.endRefreshing()
        
    }
    func setBackgroundView()
    {
        self.backgroundView = UIView(frame: (self.collectionView?.frame)!)
        
        var offset:CGFloat! = 0
        var offset2:CGFloat! = 0
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
                offset = 80
                offset2 = 30
            case 1334:
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X")
            default:
                print("unknown")
                offset = 80
                offset2 = 30
            }
        }
        let x = (self.view.frame.size.width - self.view.frame.size.width / 3.0) / 2.0
        let imgView = UIImageView(frame: CGRect(x:x,y:100 - offset,width:self.view.frame.size.width / 3.0,height:self.view.frame.size.width / 3.0))
        //backgroundView.image
        let x2 = (self.view.frame.size.width - 2*self.view.frame.size.width / 3.0 ) / 2.0
        
        
        
        let descView = UITextView(frame: CGRect(x:x2,y:120 - offset - offset2 + imgView.frame.size.height+20,width:2*self.view.frame.size.width / 3.0,height:50))
        
        descView.backgroundColor = UIColor.clear
        descView.textAlignment = .center
        //친구를 추가하시면 친구들의 타임라인의 포스트를 볼수 있습니다
        descView.text = "Add friends to see posts from your friends' timelines"
        imgView.image  = UIImage(named: "a_f_icon")
        
        
        let x3 = (self.view.frame.size.width - 200 ) / 2.0
        let y3 = (descView.frame.origin.y + 70)
        
        let button   = UIButton(type: UIButtonType.custom) as UIButton
        
        button.backgroundColor = UIColor.init(red: 27.0/255.0, green: 147.0/255.0, blue: 216.0/255.0, alpha: 1.0)
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font =  UIFont(name: "Amaranth", size: 16)
        button.frame = CGRect(x: x3, y: y3 , width: 200, height: 40)
        button.setTitle("Find Friends", for: UIControlState.normal)
        button.addTarget(self, action: #selector(self.didTapFindFriendsButton), for: UIControlEvents.touchUpInside)
        
        
        
        self.backgroundView.addSubview(imgView)
        self.backgroundView.addSubview(descView)
        self.backgroundView.addSubview(button)
        
        //  self.backgroundView.contentMode = UIViewContentMode.center
        //  self.backgroundView.image = UIImage(named: "pro1")
        self.collectionView?.backgroundView = self.backgroundView
    }
    
    func reloadTimeline() {
        self.paginationHelper.reloadData(completion: { [unowned self] (posts) in
            self.posts = posts
         
            
            self.collectionView?.reloadData()
            RSLoadingView.hide(from: self.view)
            if(posts.count > 0)
            {
                if(self.backgroundView != nil)
                {
                   // self.backgroundView.image = nil
                    self.backgroundView.removeFromSuperview()
                    
                }
                self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                  at: .top,
                                                  animated: true)
                
            }
            else
            {
                // 초기 화면
           
                self.setBackgroundView()
            }
            
        })
    }

    func reloadRecently() {
        self.paginationHelper3.reloadData(completion: { [unowned self] (posts) in
            self.posts = posts
            
            
            RSLoadingView.hide(from: self.view)
            if(posts.count > 0)
            {
                self.collectionView?.reloadData()
                
                if(self.backgroundView != nil)
                {
                    // self.backgroundView.image = nil
                    self.backgroundView.removeFromSuperview()
                    
                }
                self.collectionView?.backgroundView = UIImageView()
                /*
                 self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                 at: .top,
                 animated: true)
                 */
            }
            else
            {
                // 초기 화면
                
                self.setBackgroundView()
            }
            
        })
    }
    func reloadPopular() {
        self.paginationHelper4.reloadData(completion: { [unowned self] (posts) in
            self.posts = posts
            
            
            RSLoadingView.hide(from: self.view)
            if(posts.count > 0)
            {
                self.collectionView?.reloadData()
                
                if(self.backgroundView != nil)
                {
                    // self.backgroundView.image = nil
                    self.backgroundView.removeFromSuperview()
                    
                }
                self.collectionView?.backgroundView = UIImageView()
                /*
                 self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                 at: .top,
                 animated: true)
                 */
            }
            else
            {
                // 초기 화면
                
                self.setBackgroundView()
                
            }
            
        })
    }
    @objc func didTapFindFriendsButton() {
        
        //dismiss(animated: true, completion: nil)
        self.tabBarController?.selectedIndex = 1
        
    }
    func reloadPostAll() {
        self.paginationHelper2.reloadData(completion: { [unowned self] (posts) in
            self.posts = posts
            
            
            self.collectionView?.reloadData()
            RSLoadingView.hide(from: self.view)
            if(posts.count > 0)
            {
                if(self.backgroundView != nil)
                {
               //     self.backgroundView.image = nil
                    self.backgroundView.removeFromSuperview()
                    
                }
                
                self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                  at: .top,
                                                  animated: true)
                
            }
            else
            {
                // 초기 화면
                //collectionView?.backgroundView
                self.backgroundView = UIImageView(frame: CGRect(x:0,y:0,width:self.view.frame.size.width,height:self.view.frame.size.height))
                
                
                //backgroundView.image
                
             //   self.backgroundView.image = UIImage(named: "pro1")
                self.collectionView?.backgroundView = self.backgroundView
            }
            
        })
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
    @IBAction func didTapSetting(_ sender: UIBarButtonItem) {
        // self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        // self.navigationController?.popViewController(animated: true)
        
        performSegue(withIdentifier: "exec_info", sender: nil)

       
    }
    @IBAction func didTapStore(_ sender: UIBarButtonItem) {
        // self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        // self.navigationController?.popViewController(animated: true)
        performSegue(withIdentifier: "exec_store", sender: nil)

    }

    func initSettings()
    {
        let user:UserDefaults = UserDefaults.standard
        let initSetting:Bool = user.bool(forKey: "INIT_SETTINGS")
        
        if( initSetting == false)
        {
            user.set(true, forKey: "SILENCE")
            user.set(true, forKey: "MIRRORING")
            user.set(true, forKey: "INIT_SETTINGS")
            
        }
        
        user.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
      //  appDelegate.processMessageObserver()
        
        
        
        
        initSettings()
        
      
     
     
        
        view.backgroundColor = .white
        
        
        self.view.backgroundColor = UIColor(displayP3Red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0)
   
        self.tabBarController?.navigationItem.title  = "Pet Star"
    
        let rightButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(didTapSetting(_:)))
        
        self.tabBarController?.navigationItem.rightBarButtonItem = rightButton
        self.tabBarController?.navigationItem.rightBarButtonItem?.tintColor = UIColor(displayP3Red: 237.0/255.0, green: 246.0/255.0, blue: 250.0/255.0, alpha: 1.0)

        let leftButton = UIBarButtonItem(image: UIImage(named: "store"), style: .plain, target: self, action: #selector(didTapStore(_:)))
        
        self.tabBarController?.navigationItem.leftBarButtonItem = leftButton
        self.tabBarController?.navigationItem.leftBarButtonItem?.tintColor = UIColor(displayP3Red: 237.0/255.0, green: 246.0/255.0, blue: 250.0/255.0, alpha: 1.0)

        let loadingView = RSLoadingView()
        loadingView.show(on: self.view)
        configure()
        
    }
    func showStore()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "StoreViewController") as! StoreViewController
      
      
      
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType(string: "fade") as String
        //transition.subtype = .fromRight
       // self.navigationController?.view.layer.add(transition, forKey: kCATransition)
       // self.navigationController?.pushViewController(vc, animated: false)
        self.present(vc, animated: true, completion: nil)
  
    }
    override func viewWillAppear(_ animated: Bool) {
        initCollectionView()
        let user:UserDefaults = UserDefaults.standard
        
        var bAD:Bool = user.bool(forKey: "isADPurchased")
        
       // bAD = true
        if( bAD == true )
        {
            bannerHeight.constant = 0
            /*
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            
            addBannerViewToView(bannerView)
             */
            
        }
        if(JunSoftUtil.shared.isUpdate == true)
        {
            JunSoftUtil.shared.isUpdate = false
            
             if(Auth.auth().currentUser != nil)
            {
                 self.segmentioView.selectedSegmentioIndex = 2
              
                 self.posts.removeAll()
                reloadRecently()
     
            }
        }
        if(JunSoftUtil.shared.isDetail == true)
        {
            JunSoftUtil.shared.isDetail = false
            if(bAD == false)
            {
                showAd()
            }
            
        }
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UINavigationBar.appearance().barTintColor = UIColor.white
    
        self.tabBarController?.navigationItem.title  = "Pet Star"
        let rightButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(didTapSetting(_:)))
        
        self.tabBarController?.navigationItem.rightBarButtonItem = rightButton
        self.tabBarController?.navigationItem.rightBarButtonItem?.tintColor = UIColor(displayP3Red: 237.0/255.0, green: 246.0/255.0, blue: 250.0/255.0, alpha: 1.0)

        let leftButton = UIBarButtonItem(image: UIImage(named: "store"), style: .plain, target: self, action: #selector(didTapStore(_:)))
        
        self.tabBarController?.navigationItem.leftBarButtonItem = leftButton
        self.tabBarController?.navigationItem.leftBarButtonItem?.tintColor = UIColor(displayP3Red: 237.0/255.0, green: 246.0/255.0, blue: 250.0/255.0, alpha: 1.0)

        
   //     let loadingView = RSLoadingView()
   //     loadingView.show(on: self.view)
    //    configure()
    
        let user:UserDefaults = UserDefaults.standard
        let bAD:Bool = user.bool(forKey: "isADPurchased")
        var _rect:CGRect! = collectionView?.frame
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if( bAD == false && appDelegate.isSimulator == false )
        {
            
            let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            if(appDelegate.isServiceAD == false)
            {
                bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            }
            else
            {
                bannerView.adUnitID = "ca-app-pub-7915959670508279/9678938261"
            }
            bannerView.rootViewController = self
            let request = GADRequest()
            //  request.testDevices = @[ @"e65885a6f48dfc84c9ae2de2872759fd" ];
            bannerView.load(request)

        }
        else
        {
            /*
            if(bannerView != nil)
            {
                bannerView.removeFromSuperview()
                bannerView = nil
                
            }
            let user:UserDefaults = UserDefaults.standard
            
            let bAD:Bool = user.bool(forKey: "isADPurchased")
            _rect.size.height = (_rect.size.height) + 66
            collectionView?.frame = _rect!
             */
            bannerHeight.constant = 0
        }
 
        
       // appDelegate.simulatePush()
        
    }
   
    func configure()
    {
   
        if(Auth.auth().currentUser != nil)
         {
            
            let defaults = UserDefaults.standard
            
            let userData = defaults.object(forKey: Constants.UserDefaults.currentUser) as? Data
            let user = try? JSONDecoder().decode(JUser.self, from: userData!)
            
            
            JUser.setCurrent(user!)
            
            
            if(self.segmentioView.selectedSegmentioIndex == 1)
            {
                reloadPopular()
            }
            else if(self.segmentioView.selectedSegmentioIndex == 0)
            {
                reloadTimeline()
            }
            else
            {
                reloadRecently()
            }
           
        }
        else{
            // Login
       //     performSegue(withIdentifier: "exec_login", sender: nil)

        }
       
    }
    func configureAll()
    {
        if(Auth.auth().currentUser != nil)
        {
            let user = JUser(uid: (Auth.auth().currentUser?.uid)!, username: (Auth.auth().currentUser?.displayName)!, profile: (Auth.auth().currentUser?.photoURL?.absoluteString)!)
            JUser.setCurrent(user)
   
            reloadTimeline()
        }
        else{
            // Login
            performSegue(withIdentifier: "exec_login", sender: nil)
            
        }
        
    }
    func reloadCollectionView()
    {
        self.collectionView?.reloadData()
        
    }
    @IBAction func didTapProfile(_ sender: Any) {
       // showProfile(FPUser.currentUser())
        performSegue(withIdentifier: "exec_profile", sender: nil)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

      func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        // return self.itemArray.count
        return self.posts.count
    }
    
    
     func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FeedCollectionViewCell;
        
        cell.owner = self
        cell.hero.modifiers = [.fade, .scale(0.5)]
        
        let post = posts[indexPath.row]
        
       
        cell.post = post
        cell.populateContent(post:post, index:indexPath.row,isDryRun: false)
        UserService.show(forUID: post.poster.uid, completion: { (user) in
            
            // imgView.image = self.image
            cell.profile.sd_setImage(with:URL(string:(user?.profile_url)!)! ,placeholderImage:nil)
            // self.selectedUser = user
            cell.name.text = user?.username
        })
        
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
  //      cell.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        
        return cell
    }
     func collectionView(_ collectionView: UICollectionView, cellHeightAt indexPath: IndexPath) -> CGFloat {
        let post = self.posts[indexPath.item]
       // sizingCell.populateContent(post: post, index: indexPath.item, isDryRun: true)
        let height = sizingCell.populateContent(post:post, index:indexPath.item,isDryRun: true)
        
        sizingCell.setNeedsUpdateConstraints()
        sizingCell.updateConstraintsIfNeeded()
        sizingCell.contentView.setNeedsLayout()
        sizingCell.contentView.layoutIfNeeded()
        
        var fittingSize = UILayoutFittingCompressedSize
        fittingSize.width = sizingCell.frame.width
        
        let size = sizingCell.contentView.systemLayoutSizeFitting(fittingSize)
        return sizingCell.cellHeight
    }
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async { [unowned self] in
            let post = self.posts[indexPath.row]
            self.selectedPost = post
            self.selectedThumbURL = post.imageURL
            self.selectedVideoURL = post.imageURL
            self.selectedThumbURL = post.thumbURL
            self.selectedPost = post
            
            self.performSegue(withIdentifier: "exec_player0", sender: self.selectedVideoURL)
          // self.transition((to: PlayerViewController(post: post))
          // self.toolbarController?.transition(to: PlayerViewController(post: post))
            
            /*
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "player") as? PlayerViewController
            vc?.post = post
            vc?.thumbURL = post.imageURL
            
            self.navigationController?.pushViewController(vc!, animated: true)
 */
        }
    }
     func collectionView(_ collectionView: UICollectionView,willDisplay cell: UICollectionViewCell,forItemAt indexPath: IndexPath) {
       
        if indexPath.row >= posts.count - 1 {
            if(segmentioView.selectedSegmentioIndex == 0)
            {
                paginationHelper.paginate(completion: { [unowned self] (posts) in
                    self.posts.append(contentsOf: posts)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        print("reloadData")
                    }
                })
            }
            else
            {
                paginationHelper2.paginate(completion: { [unowned self] (posts) in
                    self.posts.append(contentsOf: posts)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        print("reloadData")
                    }
                })
            }
         
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "exec_player0"{
            
            if let playerViewController = segue.destination as? PlayerViewController{
                
                var destinationViewController = segue.destination
                
                // Set the modal presentation style of your destinationViewController to be custom.
                playerViewController.parentCon = self
                /*
                destinationViewController.modalPresentationStyle = UIModalPresentationStyle.custom
                
                // Create a new instance of your fadeTransition.
                fadeTransition = FadeTransition()
                
                // Tell the destinationViewController's  transitioning delegate to look in fadeTransition for transition instructions.
                destinationViewController.transitioningDelegate = fadeTransition as! UIViewControllerTransitioningDelegate
                
                // Adjust the transition duration. (seconds)
                fadeTransition.duration = 0.25
 */
                playerViewController.strURL = selectedVideoURL
                playerViewController.thumbURL = self.selectedThumbURL
                playerViewController.post = self.selectedPost
            }
           
        }
        
        //
        
        
    }
}

fileprivate extension HomeViewController{

    func prepareToolbar() {
        /*
        guard let toolbar = toolbarController?.toolbar else {
            return
        }
 */
       // toolbar.leftViews
       /*
        toolbar.titleLabel.text = "PetStar"
        toolbar.detailLabel.text = "Happy Share"
        
        let menuButton:IconButton = IconButton(image: UIImage(named: "logo_36"), tintColor: .white)
        toolbar.leftViews = [menuButton]
 */
            
       /*
        toolbar.backgroundColor = nil
        
        toolbar.title = "Material"
        toolbar.titleLabel.textColor = .white
        toolbar.titleLabel.textAlignment = .center
        
        toolbar.detail = "Build Beautiful Software"
        toolbar.detailLabel.textColor = .white
        toolbar.detailLabel.textAlignment = .center
 */
    }
    func prepareButtons() {
      
    }
    
    func prepareTabBar() {
       
        
    }
    
  
}


extension HomeViewController: TRMosaicLayoutDelegate {
    
    func collectionView(_ collectionView:UICollectionView, mosaicCellSizeTypeAtIndexPath indexPath:IndexPath) -> TRMosaicCellType {
        // I recommend setting every third cell as .Big to get the best layout
        return indexPath.item % 3 == 0 ? TRMosaicCellType.big : TRMosaicCellType.small
    }
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: TRMosaicLayout, insetAtSection:Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 3, bottom: 50, right: 3)
    }
    
    func heightForSmallMosaicCell() -> CGFloat {
        return 120
    }
}

/*
extension HomeViewController: UICollectionViewDataSource {
    @objc
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @objc
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // return images.count
        return self.posts.count
    }
    
    @objc
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCell
       
        let post = posts[indexPath.row]
        
        cell.imageView.setImageWith(URL(string: post.thumbURL)! ,placeholderImage:UIImage(named: "cell_back"))
        cell.transition(.fadeOut, .scale(0.75))
        
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    @objc
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      //  toolbarController?.transition(to: PhotoViewController(index: indexPath.item))
    }
}
 */
