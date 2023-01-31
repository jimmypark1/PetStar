//
//  LikeListViewController.swift
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 9. 19..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import SDWebImage
import Hue

class LikeListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet var titleView:UIView!
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var titleHeight:NSLayoutConstraint!
    @IBOutlet var closeTop:NSLayoutConstraint!
    @IBOutlet var titleTop:NSLayoutConstraint!
    @IBOutlet var collectionView:UICollectionView!
    
    var cellUser: JUser!
    let dispatchGroup = DispatchGroup()
    
    var list:LikeList!
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
        
        titleLabel.font = UIFont(name: "NEOTERIC", size: 18)
        titleLabel.textColor = UIColor.black//UIColor.init(red: 27.0/256.0, green: 147.0/256.0, blue: 216.0/256.0, alpha: 1.0)
        titleLabel.text = "Likes"
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      //  AudioServicesPlaySystemSound(1521)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initTopView()
        /*
        for user in self.list.list{
            UserService.show(forUID: user.key,completion: { (user)in
                
            })
        }
        */
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        JunSoftUtil.shared.isDetail = true
  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        // return self.itemArray.count
        //  return self.posts.count
        return self.list.list.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListViewCell", for: indexPath) as! ListViewCell
        
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(hex: "d4d2d2").cgColor
        cell.imgView.layer.masksToBounds = true
        cell.imgView.layer.cornerRadius = cell.imgView.frame.size.width / 2.0
        cell.imgView.layer.borderWidth = 2
        cell.imgView.layer.borderColor = UIColor.lightGray.cgColor
        
       // list.list.keys.
        let key = Array(self.list.list.keys)[indexPath.row]
        print(key)
        
     //   dispatchGroup.enter()
        UserService.show(forUID: key,completion: { (user)in
            
            cell.imgView.sd_setImage(with:URL(string: (user?.profile_url)!)!, placeholderImage: UIImage(named: "cell_back"))
            cell.name.text = user?.username
            cell.user = user
         //   self.dispatchGroup.leave()
            
        })
 
        /*
        for user in self.list.list{
            print(user)
            dispatchGroup.enter()
            UserService.show(forUID: user.key,completion: { (user)in
                
                cell.imgView.sd_setImage(with:URL(string: (user?.profile_url)!)!, placeholderImage: UIImage(named: "cell_back"))
                cell.name.text = user?.username
                cell.user = user
                self.dispatchGroup.leave()

            })
        }
 */
        /*
        dispatchGroup.notify(queue: .main, execute: {
            completion(posts.reversed())
        })
        */
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //self.list[indexPath.row]
        AudioServicesPlaySystemSound(1521)
        
        let cell:ListViewCell = collectionView.cellForItem(at: indexPath) as! ListViewCell
        
      // let user =  self.list.list.object(at: indexPath.row) 
      
        performSegue(withIdentifier: "exec_list_profile", sender: cell.user)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "exec_list_profile"{
            
            if let chatViewController = segue.destination as? ProfileViewController{
                //chatViewController.byID =
                //chatViewController.byUser =
                let user = sender as! JUser
                chatViewController.byUser = user
                chatViewController.byID = user.uid
                
                
            }
            
        }
    }
}
