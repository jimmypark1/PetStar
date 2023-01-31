//
//  LoginViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 17..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import GoogleSignIn
import ESTabBarController_swift
import MPSkewed

import RSLoadingView
import Hue
import CommonCrypto
import AuthenticationServices


class LoginViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {
    
    var fadeTransition: FadeTransition!
    var arrays:NSMutableArray!
    var imagesArraySlideshow : [UIImage] = []
    var slideShowIndex:NSInteger = 0
    var slideShowMax:NSInteger = 0
    
    
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var descView:UITextView!
    @IBOutlet weak var ivSlideshow:UIImageView!
    @IBOutlet weak var top:NSLayoutConstraint!
   
    @IBOutlet weak var email:UITextField!
    @IBOutlet weak var password:UITextField!
    @IBOutlet weak var dummyView:UIView!
    @IBOutlet weak var emailTop:NSLayoutConstraint!
    @IBOutlet weak var loginProviderStackView: UIView!
    
    var end:Bool!
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.end = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        email.backgroundColor = UIColor.clear
        password.backgroundColor = UIColor.clear
        
        email.attributedPlaceholder = NSAttributedString(string:"Email", attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.white])
   
        password.attributedPlaceholder = NSAttributedString(string:"Password", attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.white])
        
        self.end = false
        self.slideShowMax = self.imagesArraySlideshow.count
        DispatchQueue.global(qos: .userInteractive).async (
            execute: {() -> Void in
                while self.end == false {
                    print ("MAX:"+String(self.slideShowMax))
                    
                    DispatchQueue.main.async(execute: {() -> Void in
                        let toImage = self.imagesArraySlideshow[self.slideShowIndex]
                        print ("index:"+String(self.slideShowIndex))
                        UIView.transition(
                            with: self.ivSlideshow,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: {self.ivSlideshow.image = toImage},
                            completion: nil
                        )
                    })
                    self.slideShowIndex += 1
                    if self.slideShowIndex == self.slideShowMax {
                        self.slideShowIndex = 0
                    }
                    sleep(2)
                }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.end = false
        dummyView.backgroundColor = UIColor.clear
        /*
        arrays = NSMutableArray()
        
        arrays.add("pro1")
        arrays.add("pro2")
        arrays.add("pro3")
        arrays.add("pro4")
        arrays.add("pro5")
        arrays.add("pro6")
        
        let layout =  collectionView.collectionViewLayout as! MPSkewedParallaxLayout
        layout.itemSize = CGSize(width: self.view.bounds.width, height: 350)
        
        
        collectionView.backgroundColor = UIColor.white
        collectionView.register(MPSkewedCell.classForCoder(), forCellWithReuseIdentifier: "MPSkewedCell")
        
        collectionView.reloadData()
        

        collectionView.isHidden = true
        */
    //    top.constant = ( self.view.frame.size.height - 620 ) / 2.0
        buildImagesArraySlideshow()
        descView.backgroundColor = UIColor.clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPrivacy))
        descView.addGestureRecognizer(tapGesture)
        
        /*
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
       // GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        if(Auth.auth().currentUser != nil)
        {
            GIDSignIn.sharedInstance()?.signIn()

        }
         */
        self.view.backgroundColor = UIColor(hex: "c1e6f5")
        
      
        

    }
   
    func buildImagesArraySlideshow(){
        // example: localImageFilePath:URL = *URLs FOR SOME LOCAL IMAGE FILES*
        
        for i in 0 ... 5
        {
            let name = String(format: "anim%d", i+1)
            imagesArraySlideshow.append(UIImage(named: name)!)
            
        }
    }
    @objc func tapPrivacy() {
        
        //
        print("Please Help!")
        performSegue(withIdentifier: "exec_privacy", sender: nil)
        
        
    }
    func setBackColor()
    {
        self.view.backgroundColor = UIColor.white

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    func goService()
    {
        
        let tabBarController = ESTabBarController()
        tabBarController.tabBar.shadowImage = UIImage(named: "transparent")
        tabBarController.tabBar.backgroundImage = UIImage(named: "background_dark")
        tabBarController.delegate =  UIApplication.shared.delegate as! AppDelegate
        
        let st = UIStoryboard(name: "Main", bundle: nil)
        let v1 = st.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        let v2 = st.instantiateViewController(withIdentifier: "Find") as! FindFriendViewController
        let v3 = st.instantiateViewController(withIdentifier: "Camera") as! CameraViewController
        let v4 = st.instantiateViewController(withIdentifier: "ChatList") as! ChatListViewController
        let v5 = st.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        
        v3.modalPresentationStyle = UIModalPresentationStyle.custom
        
        // Create a new instance of your fadeTransition.
        fadeTransition = FadeTransition()
        
        // Tell the destinationViewController's  transitioning delegate to look in fadeTransition for transition instructions.
        v3.transitioningDelegate = fadeTransition as! UIViewControllerTransitioningDelegate
        
        // Adjust the transition duration. (seconds)
        fadeTransition.duration = 0.25
        
        v1.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: nil, image: UIImage(named: "home"), selectedImage: UIImage(named: "home_1"))
        v2.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: nil, image: UIImage(named: "find"), selectedImage: UIImage(named: "find_1"))
        
        v3.tabBarItem = ESTabBarItem.init(ExampleIrregularityContentView(), title: nil, image: UIImage(named: "photo_verybig"), selectedImage: UIImage(named: "photo_verybig"))
        v4.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: nil, image: UIImage(named: "alarm"), selectedImage: UIImage(named: "alarm_1"))
        
        
        v5.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: nil, image: UIImage(named: "my"), selectedImage: UIImage(named: "my"))
        
        //ExampleIrregularityContentView
        tabBarController.viewControllers = [v1, v2,v3,v4,v5]
        
        let navigationController = MyNavigationController(rootViewController: tabBarController)
       // navigationController.b
       // navigationController.navigationBar.barTintColor = UIColor.white
        //UINavigationBar.appearance().barTintColor = UIColor.white
        
        
        
        self.view.window?.rootViewController = navigationController
    }
    @IBAction func loginEmail()
    {
        let loadingView = RSLoadingView()
        loadingView.show(on: self.view)
        
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
            // ...
            if (error == nil){
             
                Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
                    // ...
                    if let error = error {
                        // ...
                        RSLoadingView.hide(from: self.view)
                        
                        return
                    }
                    guard let firUser = Auth.auth().currentUser else { return }
                    
                    UserService.create(firUser) { (user) in
                        guard let user = user else { return }
                        print("Created new user: \(user.username)")
                        JUser.setCurrent(user,writeToUserDefaults:true)
                        
                        RSLoadingView.hide(from: self.view)
                        
                        self.goService()
                    }
                }
               
                
            }
            else
            {
               // RSLoadingView.hide(from: self.view)
                Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
                    // ...
                    if let error = error {
                        // ...
                        RSLoadingView.hide(from: self.view)
                        
                        return
                    }
                    guard let firUser = Auth.auth().currentUser else { return }
                    
                    UserService.emailLogin(firUser) { (user) in
                        guard let user = user else { return }
                        print("Created new user: \(user.username)")
                        JUser.setCurrent(user,writeToUserDefaults:true)
                        
                        RSLoadingView.hide(from: self.view)
                        
                        self.goService()
                    }
                     
                    
                    
                }
            }
        }
 
     
    }
    func setupProviderLoginView() {
         if #available(iOS 13.0, *)
         {
             let authorizationButton = ASAuthorizationAppleIDButton()
           authorizationButton.cornerRadius = 6
         //  authorizationButton.ti
           authorizationButton.frame = CGRect(x: 0, y: 0, width: 248, height: 40)
             authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
         
           self.loginProviderStackView.addSubview(authorizationButton)
           
           }
       }
       @objc func handleAuthorizationAppleIDButtonPress() {
            
           
              loginApple()
          }
          func loginApple()
          {
              
              if #available(iOS 13.0, *) {
                  FirebaseAuthentication.shared.parentCon = self
                  FirebaseAuthentication.shared.signInWithApple(window: self.view.window!)
              } else {
                  // Fallback on earlier versions
               //   appleBt.isHidden = true
              }
       
          }
    func appleLoginDelegate()
       {
           guard let firUser = Auth.auth().currentUser else { return }
                             
           let loadingView = RSLoadingView()
                                   
           /*
           loadingView.show(on: self.view)
                  
           UserService.create(firUser) { (user) in
           
               guard let user = user else { return }
               
               print("Created new user: \(user.username)")
               
               JUser.setCurrent(user,writeToUserDefaults:true)
                                 
               RSLoadingView.hide(from: self.view)
               
                      
            self.goService()
                 */
           loadingView.show(on: self.view)
       
           guard let firUser = Auth.auth().currentUser else { return }
           
           UserService.create(firUser) { (user) in
               guard let user = user else { return }
               print("Created new user: \(user.username)")
               JUser.setCurrent(user,writeToUserDefaults:true)
               
               RSLoadingView.hide(from: self.view)
               
               self.goService()
           }
           
               
          // }
       }
    
    @IBAction func register()
    {
        performSegue(withIdentifier: "exec_register", sender: nil)
    }
    
    @IBAction func loginFaceBook()
    {
     
        let fbLoginManager : LoginManager = LoginManager()
        
        let loadingView = RSLoadingView()
        loadingView.show(on: self.view)
        
        fbLoginManager.logIn(permissions: ["public_profile","email"], from: self) { (result, error) -> Void in
            //self.view.isOpaque = true
            //self.view?.backgroundColor = UIColor(white: 1, alpha: 0.5)
            

            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                if (result?.isCancelled)!{
                    RSLoadingView.hide(from: self.view)
                    
                    return
                }
                
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        // ...
                        RSLoadingView.hide(from: self.view)
                        
                        return
                    }
                    guard let firUser = Auth.auth().currentUser else { return }
                    
                    UserService.create(firUser) { (user) in
                        guard let user = user else { return }
                        print("Created new user: \(user.username)")
                        JUser.setCurrent(user,writeToUserDefaults:true)
                        
                        RSLoadingView.hide(from: self.view)
                        
                        self.goService()
                    }
                    
                }
                
            }
        }
    }
    @IBAction func loginGoogle()
    {
      //  GIDSignIn.sharedInstance().signIn()
        
        let clientId = "328521399479-ci15q9mr9768v6sn2krpf099aoou78f6.apps.googleusercontent.com"
        let signInConfig = GIDConfiguration.init(clientID: clientId)
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
           guard error == nil else { return }

            guard let authentication = user?.authentication else { return }
      
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!,
                                                           accessToken: authentication.accessToken)
      
            let loadingView = RSLoadingView()
            loadingView.show(on: self.view)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                
                if let error = error {
                    // ...
                    RSLoadingView.hide(from: self.view)
                    
                    return
                }
            
                
                guard let firUser = Auth.auth().currentUser else { return }
                
                UserService.create(firUser) { (user) in
                    guard let user = user else { return }
                    print("Created new user: \(user.username)")
                    JUser.setCurrent(user,writeToUserDefaults:true)
                    
                    RSLoadingView.hide(from: self.view)
                    self.goService()
                    
                    
                }
                
            
                
            }
        }

    }
    @IBAction func viewPrivacy()
    {

    }
    /*
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        
        if let error = error {
            // ...
            return
        }
        //  self.facebookBt.isHidden = true
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        let loadingView = RSLoadingView()
        loadingView.show(on: self.view)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if let error = error {
                // ...
                RSLoadingView.hide(from: self.view)
                
                return
            }
        
            
            guard let firUser = Auth.auth().currentUser else { return }
            
            UserService.create(firUser) { (user) in
                guard let user = user else { return }
                print("Created new user: \(user.username)")
                JUser.setCurrent(user,writeToUserDefaults:true)
                
                RSLoadingView.hide(from: self.view)
                self.goService()
                
                
            }
            
        }
    }
     */
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /*
        let layout =  collectionView.collectionViewLayout as! MPSkewedParallaxLayout
        layout.itemSize = CGSize(width: self.view.bounds.width, height: 250)
        */
        var offset:CGFloat = 430.0
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
                offset = 500
                descView.font = UIFont(name: "Helvetica", size: 11)
            case 1334:
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X")
             default:
                print("unknown")
               // emailTop.constant = 50
            }
        }
        
        top.constant =  ( self.view.frame.size.height - offset ) / 6.0
        
        
        
        var subViews: NSArray = view.subviews as NSArray
        var scrollView: UIScrollView? = nil
        var pageControl: UIPageControl? = nil
        
        for view in subViews {
            if (view as AnyObject).isKind(of:UIScrollView.classForCoder()) {
                scrollView = view as? UIScrollView
            }
            else if (view as AnyObject).isKind(of:UIPageControl.classForCoder()) {
                pageControl = view as? UIPageControl
            }
        }
        
        if (scrollView != nil && pageControl != nil) {
            scrollView?.frame = view.bounds
            view.bringSubview(toFront: pageControl!)
        }
        
        setupProviderLoginView()
          
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: self.view.bounds.width, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrays.count
        // return (filters?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MPSkewedCell", for: indexPath) as! MPSkewedCell;
        
        let imageName = arrays[indexPath.row] as! String
        
        cell.image = UIImage(named: imageName)
        if(indexPath.row == 0)
        {
            cell.text = "Lovely Pet"
        }
        else if(indexPath.row == 1)
        {
            cell.text = "Happy Life"
        }
        /*
        let dict:FilterData =  filterSet.filters[indexPath.row] as! FilterData
        
        let thumbStr:String = String(format: "http://www.junsoft.org/pthumb/%@", dict.name as! CVarArg)
        let thumbURL:NSURL = NSURL(string: thumbStr)!
        
        cell.imageView.setImageWith(thumbURL as URL ,placeholderImage:UIImage(named: "sample"))
        cell.text = dict.filterName as NSString
        
        */
        return cell
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        email.resignFirstResponder()
        password.resignFirstResponder()
    }
}

