//
//  ProfileViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 3..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import AFNetworking
import TRMosaicLayout
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper
import GoogleSignIn


class ProfileViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
   
    
    var fadeTransition: FadeTransition!
    
    @IBOutlet var profileImg: UIImageView!
    @IBOutlet var feedView:UICollectionView!
    @IBOutlet var name:UILabel!
    @IBOutlet var likes:UILabel!
    @IBOutlet var followBt:UIButton!
    @IBOutlet var myBt:UIButton!
    @IBOutlet var addBt:UIButton!
    @IBOutlet var homeBt:UIButton!
    @IBOutlet var notiBt:UIButton!
    @IBOutlet var bottomConstraint:NSLayoutConstraint!
    @IBOutlet var logOutBt:UIButton!
    @IBOutlet var prevBt:UIButton!
    @IBOutlet var msgBt:UIButton!
    
    @IBOutlet var followingsCnt:UILabel!
    @IBOutlet var followersCnt:UILabel!
    @IBOutlet var closeBt: UIButton!
    @IBOutlet var topConstraint:NSLayoutConstraint!
    
    var posts = [JPost]()
    var likeCnt:Int!
    
    var byID:String!
    var byUser:JUser!
    var uploaderRef: DatabaseReference!
    var followingRef: DatabaseReference!
    var followerRef: DatabaseReference!
    //
    var selectedVideoURL: String!
    var selectedThumbURL: String!
    var selectedPost: JPost!
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // NotificationCenter.default.removeObserver(self)
      //  self.dismiss(animated: true, completion: nil)
  }
    override func viewDidAppear(_ animated: Bool) {
       
      //  initUI()
       
        loadData()
        self.tabBarController?.navigationItem.title  = ""
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
    }
    
    func loadData()
    {
        if(self.byID != nil && self.byID.count > 0)
        {
            if(Auth.auth().currentUser?.uid != self.byID)
            {
                msgBt.isHidden = false
                if(byUser.isFollowing == true)
                {
                    followBt.isHidden = false
                    
                }
                else
                {
                    followBt.isHidden = true
                    
                }
                
                
            }
            else
            {
                msgBt.isHidden = true
                followBt.isHidden = true
                
            }
            
            FollowService.followingsCount(self.byUser){ (followindCnt) in
                
                self.followingsCnt.text = String(format: "%d",followindCnt )
                
            }
            FollowService.followersCount(self.byUser){ (followersCnt) in
                
                self.followersCnt.text = String(format: "%d",followersCnt )
                
            }
            UserService.likeTotalCount(for: self.byUser) { (likeTotalCount) in
                
                self.likes.text = String(format: "%d",likeTotalCount )
            }
            
            
            profileImg.setImageWith(URL(string:self.byUser.profile_url) as! URL ,placeholderImage:nil)
            
            self.tabBarController?.navigationItem.title  = ""
            
            self.name.font = UIFont(name: "Amaranth", size: 16)
            self.name.text = self.byUser.username
        }
        else
        {
            FollowService.followingsCount(JUser.current){ (followindCnt) in
                
                self.followingsCnt.text = String(format: "%d",followindCnt )
                
            }
            FollowService.followersCount(JUser.current){ (followersCnt) in
                
                self.followersCnt.text = String(format: "%d",followersCnt )
                
            }
            UserService.likeTotalCount(for: JUser.current) { (likeTotalCount) in
                
                self.likes.text = String(format: "%d",likeTotalCount )
            }
            
            
            profileImg.setImageWith(URL(string: JUser.current.profile_url)! ,placeholderImage:nil)
            
            self.tabBarController?.navigationItem.title  = ""
            
            self.name.font = UIFont(name: "Amaranth", size: 16)
            self.name.text = JUser.current.username
            
        }
        configureCell()
        
    }
    func initUI()
    {
        
        if(self.byID != nil && self.byID.count > 0)
        {
            self.topConstraint.constant = 54
            closeBt.isHidden = false
            closeBt.layer.zPosition = 100
            msgBt.layer.zPosition = 100
            
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
            let selectableView = UIView(frame: CGRect(x: 0, y: 0, width: Int( UIScreen.main.bounds.width), height: 76 + offset ))
            selectableView.backgroundColor = UIColor.white
            selectableView.layer.shadowColor = UIColor.lightGray.cgColor
            selectableView.layer.shadowOpacity = 1
            selectableView.layer.shadowOffset = CGSize.zero
            selectableView.layer.shadowRadius = 2
            
            selectableView.layer.zPosition = 1
            view.addSubview(selectableView)
            view.addSubview(closeBt)
            view.addSubview(msgBt)
            
          
           
        }
        else
        {
            self.topConstraint.constant = 0
            closeBt.isHidden = true
            followBt.isHidden = true
            msgBt.isHidden = true
        
  
          
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       // closeBt.isHidden = true
        
        initUI()

 
        likeCnt = 0
        
        followBt.layer.masksToBounds = true
        followBt.layer.cornerRadius = 5
        followBt.layer.borderWidth = 1
        //82/215/243
        followBt.layer.borderColor = UIColor(red: 82.0/255.0, green: 215.0/255.0, blue: 243.0/255.0, alpha: 1.0).cgColor
        profileImg.layer.masksToBounds = true
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        
        profileImg.layer.borderWidth = 1
        profileImg.layer.borderColor = UIColor.black.cgColor
        
        feedView.backgroundColor = UIColor(displayP3Red: 237.0/255.0, green: 246.0/255.0, blue: 250.0/255.0, alpha: 1.0)
       
        
    }
    func prepareToolbar() {
           
    }
    func prepareTabBar() {
     
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didTapClose(_ sender: UIBarButtonItem) {
       // self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
     //   self.navigationController?.popViewController(animated: true)
        dismiss(animated: false, completion: nil)
        
    }
    
    
    @IBAction func didTapLogout(_ sender: UIBarButtonItem) {
        // self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
       // self.navigationController?.popViewController(animated: true)
        do {
            try Auth.auth().signOut()
            //
        } catch {
        }
        GIDSignIn.sharedInstance().disconnect()
       // self.navigationController?.popViewController(animated: true)
        
        
        let storyboard = UIStoryboard(name: "Login", bundle: .main)
        
        if let initialViewController = storyboard.instantiateInitialViewController() {
            // 3
            self.view.window?.rootViewController = initialViewController
            // 4
            self.view.window?.makeKeyAndVisible()
        }
    }

    @IBAction func followerProcess()
    {
        let my = KeychainWrapper.standard.string(forKey: "uid")!
        followingRef = DataService.ds.REF_USERS.child(my).child("following")
        followerRef = DataService.ds.REF_BASE.child("follower").child(self.byID)
        
        let updatesFollwing = [self.byID: true]
        let updatesFollwer = [my:true]
        
        followingRef.updateChildValues(updatesFollwing)
        followerRef.updateChildValues(updatesFollwer)
 
    }
    
    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
  //      self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        
    }
    
    @IBAction func prev()
    {
        dismiss(animated: true, completion: nil)
        
    }

    @IBAction func logout()
    {
        //Auth.auth().currentUser?
        do {
            try Auth.auth().signOut()
          //
        } catch {
        }
         GIDSignIn.sharedInstance().disconnect()
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        
        
    }
    
    @IBAction func goCamera()
    {
        performSegue(withIdentifier: "exec_r_camera", sender: nil)
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "exec_profile_player"{
            
            if let playerViewController = segue.destination as? PlayerViewController{
                
                var destinationViewController = segue.destination
                
                // Set the modal presentation style of your destinationViewController to be custom.
             //   playerViewController.parentCon = self
                destinationViewController.modalPresentationStyle = UIModalPresentationStyle.custom
                
                // Create a new instance of your fadeTransition.
                fadeTransition = FadeTransition()
                
                // Tell the destinationViewController's  transitioning delegate to look in fadeTransition for transition instructions.
                destinationViewController.transitioningDelegate = fadeTransition as! UIViewControllerTransitioningDelegate
                
                // Adjust the transition duration. (seconds)
                fadeTransition.duration = 0.25
                playerViewController.strURL = selectedVideoURL
                playerViewController.thumbURL = self.selectedThumbURL
                playerViewController.post = self.selectedPost
                playerViewController.owner = self
            }
            
        }
    }
    func configureCell()
    {
        if(self.byID != nil && self.byID.count > 0)
        {
            UserService.posts(for: byUser) { (posts) in
                self.posts = posts
                self.feedView.isHidden = false
                
                self.feedView.reloadData()
            }
        }
        else
        {
            UserService.posts(for: JUser.current) { (posts) in
                self.posts = posts
                self.feedView.isHidden = false
                
                self.feedView.reloadData()
            }
        }
     
    }
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as! FeedCell;
        
        let post = posts[indexPath.row]
      //  print(post.imageUrl)
        
        let imageView = UIImageView()
        
        
        imageView.setImageWith(URL(string: post.thumbURL)! ,placeholderImage:UIImage(named: "cell_back"))
        imageView.frame = cell.frame
        
        cell.backgroundView?.layer.masksToBounds = true
        cell.backgroundView?.layer.cornerRadius = imageView.frame.size.width/5.0
        
        cell.backgroundView = imageView
        
        if(post.mediaType == 1)
        {
            let playIcon = UIImage(named: "play.png")
            let width = (cell.backgroundView?.frame.size.width)!/3.0
            let height = width
            let x =  ((cell.backgroundView?.frame.size.width)! - width)/2.0
            let y =  ((cell.backgroundView?.frame.size.height)! - height)/2.0
            
            cell.imgView.frame = CGRect(x:x,y:y,width:width,height:height)
            cell.imgView.image = playIcon
            
        }
        else
        {
            cell.imgView.image = nil
            
        }
       
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let post = self.posts[indexPath.row]
        self.selectedPost = post
        self.selectedThumbURL = post.imageURL
        self.selectedVideoURL = post.imageURL
        self.selectedThumbURL = post.thumbURL
        self.selectedPost = post
        
        self.performSegue(withIdentifier: "exec_profile_player", sender: self.selectedVideoURL)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = feedView!.bounds.size.width / 3.0
        return CGSize(width: width-2, height: width-2)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
}
/*
extension ProfileViewController: TRMosaicLayoutDelegate {
    
    func collectionView(_ collectionView:UICollectionView, mosaicCellSizeTypeAtIndexPath indexPath:IndexPath) -> TRMosaicCellType {
        // I recommend setting every third cell as .Big to get the best layout
     //   return indexPath.item % 4 == 0 ? TRMosaicCellType.big : TRMosaicCellType.small
    //    return  TRMosaicCellType.small
        return TRMosaicCellType.small
        
    }
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: TRMosaicLayout, insetAtSection:Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
    
    func heightForSmallMosaicCell() -> CGFloat {
        let width = feedView!.bounds.size.width / 3.0
        return width
    }
}
 */

