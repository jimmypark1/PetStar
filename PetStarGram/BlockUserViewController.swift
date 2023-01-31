//
//  BlockUserViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 8. 30..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

class BlockUserViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var clostBt:UIButton!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var closeTop:NSLayoutConstraint!
    @IBOutlet weak var titleTop:NSLayoutConstraint!
    @IBOutlet weak var titleHeight:NSLayoutConstraint!
    @IBOutlet weak var titleView:UIView!
    
    var blockUsers = [JUser]()
    var backgroundView: UIView!
    
    func initTopView()
    {
        var offset:CGFloat = 0.0
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
            default:
                print("unknown")
            }
        }
        
        titleHeight.constant =  titleHeight.constant + offset
        closeTop.constant =  closeTop.constant + offset
        titleTop.constant =  titleTop.constant + offset
        
        titleView.layer.shadowColor = UIColor.lightGray.cgColor
        titleView.layer.shadowOpacity = 1
        titleView.layer.shadowOffset = CGSize.zero
        titleView.layer.shadowRadius = 2
        
        titleLabel.font = UIFont(name: "Amaranth", size: 18)
        titleLabel.textColor = UIColor.init(red: 27.0/256.0, green: 147.0/256.0, blue: 216.0/256.0, alpha: 1.0)
        titleLabel.text = "Blocked Users"
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initTopView()
        configure()
    
        // Do any additional setup after loading the view.
    }
    
    func processEmpty()
    {
        self.backgroundView = UIView(frame: (self.collectionView?.frame)!)
        
        
        let x = (self.view.frame.size.width - 2 * self.view.frame.size.width / 3.0) / 2.0
        
        let descView = UITextView(frame: CGRect(x:x,y:120,width:2*self.view.frame.size.width / 3.0,height:50))
        
        descView.backgroundColor = UIColor.clear
        descView.textAlignment = .center
        descView.text = "You have not blocked any users."
        
        self.backgroundView.addSubview(descView)
        
        self.collectionView?.backgroundView = self.backgroundView
    }
    
    func configure()
    {
        UserService.getBlockedUser(){(users) in
            self.blockUsers = users
            if(users.count == 0)
            {
                self.processEmpty()
            }
            self.collectionView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        // return self.itemArray.count
        //  return self.posts.count
      //  return self.users.count
        return self.blockUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlockCell", for: indexPath) as! BlockCell
        
        let user = self.blockUsers[indexPath.row]
        
        UIImage.circleImage(with: URL(string: user.profile_url)!, to: cell.imgView)
        cell.name.text = user.username
        cell.uid = user.uid
        cell.user = user
        cell.owner = self
       
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       
        let user = self.blockUsers[indexPath.row]
        UserService.deleteBlockedUser(user: user)
        
    }
    

}
