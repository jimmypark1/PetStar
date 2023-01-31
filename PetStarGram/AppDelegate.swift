//
//  AppDelegate.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 2..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
//import FBSDKCoreKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper
import GoogleMobileAds
//import FirebaseGoogleAuthUI
//import FirebaseFacebookAuthUI

import ESTabBarController_swift

import MaterialComponents
import UserNotifications

import SwiftyStoreKit
import Harpy
import Hue
import Pages

private let kFirebaseTermsOfService = URL(string: "https://firebase.google.com/terms/")!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UITabBarControllerDelegate, HarpyDelegate {
  
    struct Platform {
        
        static var isSimulator: Bool {
            return TARGET_OS_SIMULATOR != 0
        }
        
    }
    var window: UIWindow?
    var viewController: UIViewController?
    
    var coverImageNames: [String]?
    var backgroundImageNames: [String]?
    var coverTitles: [String]?
    var videoURL: URL?
    var fadeTransition: FadeTransition!
    
    let mdcMessage = MDCSnackbarMessage()
    let mdcAction = MDCSnackbarMessageAction()
    let gcmMessageIDKey = "gcm.message_id"
    
    var isServiceAD : Bool!
    var isSimulator : Bool!
    
    var introductionView: ZWIntroductionView!
    var pages : PagesController!
    
    var _leftButton0 : UIBarButtonItem!
    var _rightButton0 : UIBarButtonItem!
    
    var navigationController :UINavigationController!
    var shadowImage:UIImage!
    var backgroundImage:UIImage!
    var fcmToken:String!
   
    func setMessagegeBody(to:String, body:String, title:String) -> String
    {
        var text = """
                {
                  "notification":
                  {
                    "title": \"%@\",
                    "text": \"%@\",
                    "sound": "default",
                    "badge": "0",
                  },
                  "priority" : "high",
                  "to" : \"%@\"
                }
                """
        
       
        let convertStr = String(format: text, title ,body, to)
        
         print(convertStr)
     //   print(test)
        
        return convertStr
        
    }
    func SendMessagePush(msg: String!, sender:String, to:String)
    {
        let serverKey0:String = "key=AAAATH1mvLc:APA91bEN2NbOFRrBIgCr-uf_2gucApTsCJz6dSJ63pg-mvClejgn2UnlCRvcPEYwry4awAu5WUuWr6feCM-3S_qLt9YqQBXTErj1w-LQ-UfibY0q8tjf0n_0ByWE4CSkvPS2RvFlHqkHNtFfB9zF-Ve3vaRKT58HQw"
        
        
        let message =  String(format:"%@ : %@ ",sender, msg)
        let text = setMessagegeBody(to: to, body: message, title: "")
        print(text)
        let data = text.data(using: String.Encoding.utf8)
        let json  = try? JSONSerialization.jsonObject(with: data! , options:  JSONSerialization.ReadingOptions(rawValue:0))
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.setValue(serverKey0, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        
        task.resume()
    }
    func setLikeBody(to:String, body:String, title:String, postKey:String, uid:String) -> String
    {
        var text = """
                {
                  "notification":
                  {
                    "title": \"%@\",
                    "text": \"%@\",
                    "sound": "default",
                    "badge": "0",
                  
                  },
                  "content_available":true,
                  "priority" : "high",
                  "to" : \"%@\",
                  "data":
                   {
                       "postkey": \"%@\",
                       "uid": \"%@\",

                   }
                }
                """
        
        
        let convertStr = String(format: text, title ,body, to, postKey, uid)
        
        print(convertStr)
        //   print(test)
        
        return convertStr
        
    }
    func SendLikePush(msg: String!, sender:String, to:String, postKey:String, uid:String)
    {
        let serverKey0:String = "key=AAAATH1mvLc:APA91bEN2NbOFRrBIgCr-uf_2gucApTsCJz6dSJ63pg-mvClejgn2UnlCRvcPEYwry4awAu5WUuWr6feCM-3S_qLt9YqQBXTErj1w-LQ-UfibY0q8tjf0n_0ByWE4CSkvPS2RvFlHqkHNtFfB9zF-Ve3vaRKT58HQw"
        
        
        let message =  String(format:"%@ : %@ ",sender, msg)
        let text = setLikeBody(to: to, body: msg, title: "",postKey: postKey ,uid: uid )
        print(text)
        let data = text.data(using: String.Encoding.utf8)
        let json  = try? JSONSerialization.jsonObject(with: data! , options:  JSONSerialization.ReadingOptions(rawValue:0))
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.setValue(serverKey0, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        
        task.resume()
    }
    func setupIAP() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.flatMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
    func setUserNoti(application: UIApplication)
    {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { granted, _ in
                    /*
                    if granted {
                        if let uid = Auth.auth().currentUser?.uid {
                            self.database.reference(withPath: "people/\(uid)/notificationEnabled").setValue(true)
                        } else {
                            self.notificationGranted = true
                        }
                    }
                     */
                    application.beginBackgroundTask(withName: "showNotification", expirationHandler: nil)

            })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.beginBackgroundTask(withName: "showNotification", expirationHandler: nil)

        }
    }
    
    func processMessageObserver()
    {
        //https://fcm.googleapis.com/fcm/send
        UserService.observeReceive(for: (Auth.auth().currentUser?.uid)!, withCompletion:{ (dict,success) in
        
            if(success == true)
            {
                let key = dict.keys.first
                let mstatusData = dict[key!]  as? [String :Any]
                
              //  self.sendNotification(msg: mstatusData!["content"] as! String, sender: mstatusData!["sender"] as! String)
                
                 let _ref = Database.database().reference().child("mstatus").child((Auth.auth().currentUser?.uid)!).child(dict.keys.first!)
                
               // _ref.removeValue()
                _ref.updateChildValues(["content":"",
                                        "sender": "",
                                        "chat_key":""])
               // _ref.setValue(["content:",nil,
                              // "sender:",nil])
             //   print(ref)
              //  print(ref.keys.first)
            }
        })
    }
    
    func setMessageObserver(chatKey:String)
    {
        /*
        ChatService.observeMessages(forChatKey: chatKey, completion: { [weak self] (ref, message) in
            //self?.messagesRef = ref
            print(message)
            
        })
 */
        
        let _ref = Database.database().reference().child("chats").child((Auth.auth().currentUser?.uid)!)
        
      
        
      
    }
    
  
    func advanceIntroductionView() -> ZWIntroductionView {
        let loginButton = UIButton(frame: CGRect(x: 3, y: self.window!.frame.size.height - 60, width: self.window!.frame.size.width - 6, height: 50))
        loginButton.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
        loginButton.setTitle("Login", for: UIControlState())
  
        let vc = ZWIntroductionView(video: self.videoURL, volume: 0.7)!
        vc.coverImageNames = self.coverImageNames
        vc.autoScrolling = true
        vc.hiddenEnterButton = true
        vc.pageControlOffset = CGPoint(x: 0, y: -100)
        vc.labelAttributes = [kCTFontAttributeName: UIFont(name: "Arial-BoldMT", size: 28.0)!,
                              kCTForegroundColorAttributeName: UIColor.white]
        vc.coverView = loginButton
        
        vc.coverTitles = self.coverTitles
        
        return vc
    }
    
    func configureMainView()
    {
        let tabBarController = ESTabBarController()
     
        tabBarController.tabBar.shadowImage = UIImage(named: "transparent")
        tabBarController.tabBar.backgroundImage = UIImage(named: "background_dark")
        tabBarController.delegate = self as! UITabBarControllerDelegate
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
        
        processMessageObserver()
        // processMessageObserver()
        
        navigationController = MyNavigationController(rootViewController: tabBarController)
        window?.rootViewController = navigationController
    }
    private func pagesControllerInCode() -> PagesController {
        var viewControllers: [UIViewController] = []
        
        for i in 0..<5 {
            let viewController = IntroViewController()
            let strName:String = String(format:"pro%d",i+1)
            viewController.imageView.image = UIImage(named: strName)
            
            viewControllers.append(viewController)
        }
        
        let pages = PagesController(viewControllers)
        
        pages.enableSwipe = true
        pages.showBottomLine = false
        
        pages.pageControl?.backgroundColor = .white
        return pages
    }
    private func pagesControllerInStoryboard() -> PagesController {
        let storyboardIds = ["Login"]
        let storyboard0 = UIStoryboard(name: "Intro", bundle: .main)
        let storyboard = UIStoryboard(name: "Login", bundle: .main)
        
        var viewControllers: [UIViewController] = []
        
        let initialViewController0 = storyboard0.instantiateInitialViewController()
        let initialViewController1 = storyboard0.instantiateInitialViewController()
        
        let initialViewController2 = storyboard0.instantiateViewController(withIdentifier: "FilterSet")
        let initialViewController3 = storyboard.instantiateInitialViewController()
        
        viewControllers.append(initialViewController0!)
        viewControllers.append(initialViewController1!)
        viewControllers.append(initialViewController2)
        viewControllers.append(initialViewController3!)
        return PagesController(viewControllers)
    }
    
    func configureIntroductionView()
    {
        pages = pagesControllerInStoryboard()
        pages.pagesDelegate = self
        navigationController = UINavigationController(rootViewController: pages)
        
        _leftButton0 = UIBarButtonItem(image: UIImage(named: "prev_rev3"), style: .plain, target: pages, action: #selector(PagesController.moveBack))
        
        _rightButton0 = UIBarButtonItem(image: UIImage(named: "next_rev3"), style: .plain, target: pages, action: #selector(PagesController.moveForward))
        
        //
        pages.pageControl?.backgroundColor = .white//UIColor(hex: "8ecff9")
        
        pages.showPageControl = false
        pages.pageControl?.pageIndicatorTintColor =  UIColor(hex: "8ecff9")
        //UIPageControl *pageControl = [UIPageControl appearance];
        //pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        //pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        //pageControl.backgroundColor = [UIColor whiteColor];
        
        
        pages.navigationItem.leftBarButtonItem?.tintColor = UIColor(hex: "8ecff9")
        pages.navigationItem.rightBarButtonItem?.tintColor = UIColor(hex: "8ecff9")
        pages.navigationItem.leftBarButtonItem = _leftButton0
        
        pages.navigationItem.rightBarButtonItem = _rightButton0
        
        pages.navigationItem.leftBarButtonItem = nil
        pages.navigationItem.title = "Happy Share"
        
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.lightGray
        pageController.currentPageIndicatorTintColor = UIColor.black
        pageController.backgroundColor = UIColor.white
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        UITabBar.appearance().barTintColor = UIColor.white
        UITabBar.appearance().tintColor = UIColor(red: 124/255, green: 211/255, blue: 240/255, alpha: 1.0)
       // UITabBarItem.appearance().setTin.setTintColor(UIColor.greenColor())
   //     FirebaseApp.configure()
      
        UITabBar.appearance().backgroundColor = UIColor.white

      //  let test:String = "test.1234@gmail.com"
     //   var fullNameArr = test.characters.split {$0 == "@"}.map(String.init)
     //   print(fullNameArr[0])
       // FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        isServiceAD = true//Platform.isSimulator
        //Platform.is
        print( Platform.isSimulator )
        isSimulator = Platform.isSimulator
        setupIAP()
        setUserNoti(application: application)
        
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            
            //  let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            let authOptions: UNAuthorizationOptions = [.alert, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        
        application.registerForRemoteNotifications()
        
        let defaults = UserDefaults.standard
        
        let userData = defaults.object(forKey: Constants.UserDefaults.currentUser) as? Data
        
        if(Auth.auth().currentUser == nil && userData != nil)
        {
            configureIntroductionView()
 
        }
        else if(userData == nil && (Auth.auth().currentUser != nil))
        {
            try? Auth.auth().signOut()
            configureIntroductionView()
        }
        else if(userData == nil && (Auth.auth().currentUser == nil))
        {
            try? Auth.auth().signOut()
            configureIntroductionView()
        }
        else
        {
     
            configureMainView()
            
        }
        
        Harpy.sharedInstance().presentingViewController = self.window?.rootViewController
        Harpy.sharedInstance().delegate = self
        Harpy.sharedInstance().alertType = HarpyAlertType.option
        Harpy.sharedInstance().isDebugEnabled = true
        Harpy.sharedInstance().checkVersion()
        
        iRate.sharedInstance().applicationBundleID = "com.junsoft.petstar"
        iRate.sharedInstance().onlyPromptIfLatestVersion = false;
        
        iRate.sharedInstance().daysUntilPrompt = 5
        iRate.sharedInstance().usesUntilPrompt = 15
        ApplicationDelegate.shared.application(
                    application,
                    didFinishLaunchingWithOptions: launchOptions
                )
        

        return true
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
   {
    
        print("inside shouldSelect VC")
    
        if viewController is CameraViewController {
            print("    viewController is CameraViewController")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let actualController = storyboard.instantiateViewController(withIdentifier: "Camera") as! CameraViewController
            
            tabBarController.present(actualController, animated: true, completion: nil)
        
            JunSoftUtil.shared.isDetail = true
            return false
           
        }
       else
       {
        }
        print("skipped everything, returning true")
 
        return true
    }
    func applicationDidBecomeActive(application: UIApplication!) {
       // FBSDKAppEvents.activateApp()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        /*
        if KOSession.isKakaoAccountLoginCallback(url) {
            
            return KOSession.handleOpen(url)
            
        }
        
  
        
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: [:])
        
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
         */
        if(url.scheme!.hasPrefix("fb"))
        {
            return ApplicationDelegate.shared.application(
                     app,
                     open: url,
                     sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                     annotation: options[UIApplication.OpenURLOptionsKey.annotation]
                 )
        }
        else
        {
            return GIDSignIn.sharedInstance.handle(url)
       
         }
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
      //  showAlert(userInfo)
         }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
       // showAlert(userInfo)
        //completionHandler(.newData)
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func showContent(_ content: UNNotificationContent) {
        mdcMessage.text = content.body
        mdcAction.title = content.title
      //  mdcMessage.duration = 10000
        mdcAction.handler = {
            /*
            guard let feed = self.window?.rootViewController?.childViewControllers[0] as? FPFeedViewController else { return }
            let userId = content.categoryIdentifier.components(separatedBy: "/user/")[1]
            feed.showProfile(FPUser(dictionary: ["uid": userId]))
             */
        }
        mdcMessage.action = mdcAction
      //  MDCSnackbarManager.show(mdcMessage)
    }
    
    func sendNoti()
    {
        
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = "Hey this is Simplified iOS"
        content.subtitle = "iOS Development is fun"
        content.body = "We are learning about iOS Local Notification"
        content.badge = 1
        
        //getting the notification trigger
        //it will be called after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().delegate = self
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    func sendNotification(msg: String!, sender:String)
    {
        let con =  window?.rootViewController as! MyNavigationController
        //  con?.childViewControllers
      //  let tabCon = con?.childViewControllers[0] as! ESTabBarController
        //con.viewControllers[
        print(con.visibleViewController!)
        print(con)
        if( con.visibleViewController!.isKind(of: ChatViewController.classForCoder()))
        {
            print("ChatView")
            return
            
        }
        
        /*
        if((con?.title?.compare("Message"))!.rawValue == 0)
        {
            
        }
        */
        let content = UNMutableNotificationContent()
        
   
        content.body = String(format:"%@ : %@ ",sender, msg)//String(format:"%@",content)
        content.badge = 0
        
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: "showNotification", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().delegate = self
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    
    
    }
}


@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
       // showContent(notification.request.content)
        //completionHandler([])
        /*
        let con =  window?.rootViewController
        //  con?.childViewControllers
        let tabCon = con?.childViewControllers[0] as! ESTabBarController
        tabCon.selectedIndex = 3
        */
        let con =  window?.rootViewController as! MyNavigationController
        //  con?.childViewControllers
        //  let tabCon = con?.childViewControllers[0] as! ESTabBarController
        //con.viewControllers[
        if( con.visibleViewController!.isKind(of: ChatViewController.classForCoder()) == false)
        {
            let tabCon = con.childViewControllers[0] as! ESTabBarController
            tabCon.selectedIndex = 3
            
            completionHandler([.alert, .sound])
            
            
        }
        
        
    }
    /*
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
      //  showContent(response.notification.request.content)
       // completionHandler()
        completionHandler([.alert, .badge, .sound])
        
    }
 */
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print( response.actionIdentifier)
        let con =  window?.rootViewController
      //  con?.childViewControllers
        let tabCon = con?.childViewControllers[0] as! ESTabBarController
        tabCon.selectedIndex = 3
        print(con?.childViewControllers[0])
        completionHandler()
    }
    
}


extension AppDelegate : MessagingDelegate {
  // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken)")
        self.fcmToken = fcmToken!
    }


    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingDelegate) {
        print("Received data message: \(remoteMessage.description)")
    }
 
  // [END refresh_token]
}
extension AppDelegate: PagesControllerDelegate {
    
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
        self.window?.rootViewController = navigationController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            setViewController viewController: UIViewController,
                            atPage page: Int)
    {
        print("delegate")
        if(page == 0 || page == 1  )
        {
            let intro = viewController as! IntroViewController
            intro.page = page
            viewController.view.setNeedsLayout()
            
            if(page >= 1)
            {
                pages.navigationItem.leftBarButtonItem = _leftButton0
                pages.navigationItem.rightBarButtonItem = _rightButton0
                pages.navigationItem.title = "Lovely Camera"
            }
            else
            {
                pages.navigationItem.leftBarButtonItem = nil
                pages.navigationItem.rightBarButtonItem = _rightButton0
                pages.navigationItem.title = "Happy Share"
                
            }
            
            //viewController.dismiss(animated: true, completion: nil)
            // goService()
        }
        else if(page == 2 )
        {
            let intro = viewController as! FilterShowViewController
            //  intro.page = page
            viewController.view.setNeedsLayout()
            
            pages.navigationItem.leftBarButtonItem = _leftButton0
            pages.navigationItem.rightBarButtonItem = _rightButton0
            pages.navigationItem.title = "Beautiful Filter"
            
            
            //viewController.dismiss(animated: true, completion: nil)
            // goService()
        }
        else
        {
            //   let _leftButton1 = UIBarButtonItem(image: UIImage(named: "prev_rev2"), style: .plain, target: pages, action: #selector(PagesController.moveBack))
            
            let login = viewController as! LoginViewController
            
            pages.navigationItem.title = "Sign In"
            login.setBackColor()
            pages.navigationItem.leftBarButtonItem = _leftButton0
            pages.navigationItem.rightBarButtonItem = nil
            
        }
        
    }
}

