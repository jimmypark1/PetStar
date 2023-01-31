//
//  FeedCollectionViewCell.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 18..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import MaterialComponents
import AFNetworking
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SDWebImage

class FeedCollectionViewCell: MDCCollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var play: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var likeCnt: UILabel!
    @IBOutlet weak var viewCnt: UILabel!
    @IBOutlet weak var imgWidth: NSLayoutConstraint!
    @IBOutlet weak var imgHeight: NSLayoutConstraint!
    @IBOutlet weak var likeBt: UIButton!
    
    var cellHeight:CGFloat!
    var post:JPost!
    
    var owner:HomeViewController!
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgView.isHidden = false
        //   data = nil
    }
    func populateContent(post: JPost, index: Int, isDryRun: Bool)->CGFloat {
        
        if(isDryRun == false)
        {
            //self.imgView.setImageWith(URL(string: post.thumbURL)! ,placeholderImage:UIImage(named: "cell_back"))
            
               
            self.imgView.sd_setImage(with:URL(string: (post.thumbURL))!, placeholderImage: UIImage(named: "cell_back"))
            
            
        }
       //  imageView.frame = cell.frame
        
     //   self.imgWidth.constant = self.frame.size.width
      //  self.imgHeight.constant = self.frame.size.width
        
        print(self.imgView.frame.origin.y)
        self.profile.layer.masksToBounds = true
        self.profile.layer.cornerRadius = self.profile.frame.size.width/2
        self.profile.layer.borderWidth = 1
        self.profile.layer.borderColor = UIColor.blue.cgColor
        
       // self.profile.setImageWith(URL(string: post.poster.profile_url)! ,placeholderImage:UIImage(named: "cell_back"))
        
       // self.name.text = post.poster.username
        /*
        UserService.show(forUID: self.post.poster.uid, completion: { (user) in
            
            // imgView.image = self.image
            self.profile.sd_setImage(with:URL(string:(user?.profile_url)!)! ,placeholderImage:nil)
           // self.selectedUser = user
            self.name.text = user?.username
        })
 */
        
        self.likeCnt.text = String(format: "%d", post.likeCount)
        self.viewCnt.text = String(format: "%d", post.viewsCount)
        //cell.date.text = post.creationDate
        
        let time = post.creationDate.timeAgo()
        // print(time)
        self.date.text = time
        
        if(post.likeCount == 0)
        {
            self.likeBt.setImage(UIImage(named: "empty-heart"), for: .normal)
            
        }
        else
        {
            self.likeBt.setImage(UIImage(named: "filled-heart"), for: .normal)
            
        }
        
        if( post.mediaType == 1)
        {
            
            self.play.isHidden = false
            
        }
        else
        {
            self.play.isHidden = true
            
        }
        return ( self.viewCnt.frame.origin.y + 2 * self.viewCnt.frame.size.height + 30)
        
    }
    override func updateConstraints() {
        super.updateConstraints()
        
        self.cellHeight = self.viewCnt.frame.origin.y +  self.viewCnt.frame.size.height + self.profile.frame.origin.y
       
    }
    
    @IBAction func likeTapped()
    {
        
        LikeService.setIsLiked(!self.post.isLiked, for: post) { (success) in
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
                let  appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                
                let message :String = String(format: "%@ likes your post", JUser.current.username)
                UserService.getUserToken(uid: self.post.poster.uid, completion: {  (token) in
                    
                    //   UserService.setLikeList(for:(Auth.auth().currentUser?.uid)!, posterID: self.post.poster.uid, postKey: self.post.key!)
                    
                    if(self.post.poster.uid != Auth.auth().currentUser?.uid)
                    {
                        appDelegate.SendLikePush(msg: message, sender: (Auth.auth().currentUser?.displayName)!,to:token!,postKey:self.post.key!, uid:JUser.current.uid )
                        
                    }
                    
                    
                    
                })
            }
            
            self.post.likeCount += !self.post.isLiked ? 1 : -1
            self.post.isLiked = !self.post.isLiked
            self.likeCnt.text = String(format: "%d", self.post.likeCount)
            // 8
            
        }
 
    }
    
    @IBAction func report()
    {
      //  let post = posts[indexPath.section]
        let poster = post.poster
        // 3
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // 4
        if poster.uid != JUser.current.uid {
            let flagAction = UIAlertAction(title: "Report this", style: .default) { _ in
               
                print("report post")
                PostService.flag(self.post)
             //   PostService.blockUser(poster)
                let okAlert = UIAlertController(title: nil, message: "The post has been flagged.", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.owner.present(okAlert, animated: true)
                
            }
            
            let blockAction = UIAlertAction(title: "Block a User", style: .default) { _ in
                let blockAlert = UIAlertController(title: nil, message: "Are you sure you want to block this user?", preferredStyle: .alert)
                
                ////
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                   
                     PostService.blockUser(poster)
                    self.owner.configure()
                }
                blockAlert.addAction(okAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                blockAlert.addAction(cancelAction)
                
                ////
                self.owner.present(blockAlert, animated: true)
                
            }
            alertController.addAction(flagAction)
            alertController.addAction(blockAction)
            
            
        }
        
       // 5
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
             // 6
        
        owner.present(alertController, animated: true, completion: nil)
 
    }
}
