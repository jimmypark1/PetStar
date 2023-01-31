//
//  FindFriendViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 12..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import AFNetworking
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MaterialComponents
import RSLoadingView
import GoogleMobileAds

class FindFriendViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource {

    let paginationHelper = MGPaginationHelper<JUser>(pageSize:50, serviceMethod: UserService.usersExcludingCurrentUser)

    
    var users = [JUser]()
    var sizingCell: FindFriendsCell!
    @IBOutlet weak var  bannerView: GADBannerView!
    @IBOutlet weak var  collectionView: UICollectionView!

    @IBOutlet weak var bannerHeight:NSLayoutConstraint!

    @IBOutlet weak var tableView:UITableView!
   // @IBOutlet weak var collectionView:UICollectionView!
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
        
        let user:UserDefaults = UserDefaults.standard
        
        let bAD:Bool = user.bool(forKey: "isADPurchased")
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if( bAD == false && appDelegate.isSimulator == false)
        {
        //    bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        //    addBannerViewToView(bannerView)
        }
        JunSoftUtil.shared.isDetail = true
  
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.minimumLineSpacing = 10
  
        let width = (UIScreen.main.bounds.size.width )
        layout.itemSize = CGSize(width: width,height: 50)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        initCollectionView()
        let loadingView = RSLoadingView()
        loadingView.show(on: self.view)
        
        // Do any additional setup after loading the view.
     
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title  = "Find Friends"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
      //  self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        let user:UserDefaults = UserDefaults.standard
        let bAD:Bool = user.bool(forKey: "isADPurchased")
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        JunSoftUtil.shared.isDetail = true
  
        if( bAD == false && appDelegate.isSimulator == false)
        {
          
            if(appDelegate.isServiceAD == false)
            {
                bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            }
            else
            {
                bannerView.adUnitID = "ca-app-pub-7915959670508279/7299093024"
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
      
        reloadUsers()
        /*
        let loadingView = RSLoadingView()
        loadingView.show(on: self.view)
        UserService.usersExcludingCurrentUser { [unowned self] (users) in
            self.users = users
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                RSLoadingView.hide(from: self.view)
                
            }
        }
 */
        
    }
    
    func reloadUsers() {
        let loadingView = RSLoadingView()
        loadingView.show(on: self.view)
        
        users.removeAll()
        self.paginationHelper.reloadData(completion: { [unowned self] (users) in
           
            for user in users
            {
                if(user.uid != JUser.current.uid)
                {
                    self.users.append(user)
                    
                    
                }
             }
           // self.users = users
           
            //self.users = users
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                RSLoadingView.hide(from: self.view)
                
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func initCollectionView()
    {
        let nib = UINib(nibName: "FindFriendsCell", bundle: nil)
        
        guard let collectionView = collectionView else {
            return
        }
        collectionView.register(nib, forCellWithReuseIdentifier: "FindFriendsCell")
        sizingCell = Bundle.main.loadNibNamed("FindFriendsCell", owner: self, options: nil)?[0]
            as? FindFriendsCell
        /*
        self.styler.cellStyle = .card
        self.styler.cellLayoutType = .grid
        self.styler.gridColumnCount = 1
        let insets = self.collectionView(collectionView,
                                         layout: collectionViewLayout,
                                         insetForSectionAt: 0)
        
        
        let cellFrame = CGRect(x: 0, y: 0, width: collectionView.bounds.width - insets.left - insets.right,
                               height: collectionView.bounds.height)
      */
        let user:UserDefaults = UserDefaults.standard
        
        let bAD:Bool = user.bool(forKey: "isADPurchased")
        let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if( bAD == false && appDelegate.isSimulator == false)
        {
           /*
            var rect = collectionView.frame
            rect.size.height = rect.size.height - 66
            collectionView.frame = rect
            */
            
        }
        
     //   sizingCell.frame = cellFrame
    }
    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
        
    }
   
    
     func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        // return self.itemArray.count
        return users.count
    }
    
    
     func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FindFriendsCell", for: indexPath) as! FindFriendsCell;
        
        configure(cell: cell, atIndexPath: indexPath)
        
        
        return cell
    }
     func collectionView(_ collectionView: UICollectionView, cellHeightAt indexPath: IndexPath) -> CGFloat {
       
       // return 500
        return 50
    }
 
    func configure(cell: FindFriendsCell, atIndexPath indexPath: IndexPath) {
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
        
        //   cell.profile.setImageWith(URL(string: user.profile_url)! ,placeholderImage:UIImage(named: "cell_back"))
        
    }
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let loadingView = RSLoadingView()
        loadingView.show(on: self.view)
        let cell:FindFriendsCell = collectionView.cellForItem(at: indexPath) as! FindFriendsCell
        
       // followButton.isUserInteractionEnabled = false
        let followee = users[cell.index]
        
        
        if(followee.isFollowing == true)
        {
            cell.followButton.setImage(UIImage(named: "add_user"), for: .normal)
            
        }
        else
        {
            cell.followButton.setImage(UIImage(named: "remove_user"), for: .normal)
            
        }
        FollowService.setIsFollowing(!followee.isFollowing, fromCurrentUserTo: followee) { (success) in
           
            
            guard success else { return }
            followee.isFollowed = !followee.isFollowed
            self.users[cell.index].isFollowing = followee.isFollowed
            
            
            RSLoadingView.hide(from: self.view)
            
            
        }
        
    }
     func collectionView(_ collectionView: UICollectionView,willDisplay cell: UICollectionViewCell,forItemAt indexPath: IndexPath) {
        
        if indexPath.row >= users.count - 1 {
            print(indexPath.row)
            paginationHelper.paginate(completion: { [unowned self] (users) in
                
                for user in users
                {
                    if(user.uid != JUser.current.uid)
                    {
                        self.users.append(user)
                        
                    }
                }
            //    self.users.append(contentsOf: users)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    print("reloadData")
                }
            })
        }
    }
  
}




extension FindFriendViewController: FindFriendsCellDelegate {
    func didTapFollowButton(_ followButton: UIButton, on cell: FindFriendsCell) {
     //   guard let indexPath = tableView.indexPath(for: cell) else { return }
        let loadingView = RSLoadingView()
        loadingView.show(on: self.view)
        
            followButton.isUserInteractionEnabled = false
        let followee = users[cell.index]
        
        
        if(followee.isFollowing == true)
        {
             cell.followButton.setImage(UIImage(named: "add_user"), for: .normal)
            
        }
        else
        {
            cell.followButton.setImage(UIImage(named: "remove_user"), for: .normal)
            
        }
        FollowService.setIsFollowing(!followee.isFollowing, fromCurrentUserTo: followee) { (success) in
            defer {
                followButton.isUserInteractionEnabled = true
            }
            guard success else { return }
            followee.isFollowed = !followee.isFollowed
            self.users[cell.index].isFollowing = followee.isFollowed
            
            
            RSLoadingView.hide(from: self.view)
            
            
        }
       
    }
}


