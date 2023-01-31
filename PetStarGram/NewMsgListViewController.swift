//
//  NewMsgListViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 8. 21..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import RSLoadingView

class NewMsgListViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource{

    let paginationHelper = MGPaginationHelper<JUser>(pageSize:50, serviceMethod: UserService.usersExcludingCurrentUser)

    @IBOutlet var titleView:UIView!
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var titleHeight:NSLayoutConstraint!
    @IBOutlet var closeTop:NSLayoutConstraint!
    @IBOutlet var titleTop:NSLayoutConstraint!
    
    @IBOutlet var collectionView:UICollectionView!
    
    var users = [JUser]()
    var selectedUser:JUser!
    
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
        titleLabel.text = "New Message"
        
    }
    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
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
          
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                RSLoadingView.hide(from: self.view)
                
            }
        })
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        initTopView()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadUsers()
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
        return self.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewMsgCell", for: indexPath) as! NewMsgCell
        
        
        let user = users[indexPath.row]
        
        cell.delegate = self
        cell.selectedUser = user
       // cell.delegate = self
       // cell.index = indexPath.row
        //  cell.followButton.isSelected = user.isFollowed
        cell.name.text = user.username
        
        
        
        UIImage.circleImage(with: URL(string: user.profile_url)!, to: cell.imgView)
        
        
        return cell
    }
    /*
    override func collectionView(_ collectionView: UICollectionView, cellHeightAt indexPath: IndexPath) -> CGFloat {
      
        return sizingCell.cellHeight
    }
 */
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell:NewMsgCell = collectionView.cellForItem(at: indexPath) as! NewMsgCell
        
        cell.delegate = self
        self.selectedUser = cell.selectedUser
     
        performSegue(withIdentifier: "exec_m_chat", sender: nil)
        
       
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
    func processNewMsg(user:JUser)
    {
        self.selectedUser = user
        
        performSegue(withIdentifier: "exec_m_chat", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
      
        if segue.identifier == "exec_m_chat"{
            
            if let chatViewController = segue.destination as? ChatViewController{
                
                chatViewController.selectedUser = self.selectedUser
            }
            
        }
        
    }
}

extension NewMsgListViewController: NewMsgCellDelegate {
    func didTabNewMsg(_ user:JUser)
    {
        self.selectedUser = user
        
        performSegue(withIdentifier: "exec_m_chat", sender: nil)
        
    }
}
