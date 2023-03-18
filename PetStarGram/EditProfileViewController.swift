//
//  EditProfileViewController.swift
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 9. 11..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import FirebaseAuth.FIRUser
import FirebaseDatabase
import Firebase
import FirebaseAuth
import RSLoadingView

class EditProfileViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var titleView:UIView!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var closeTop:NSLayoutConstraint!
    @IBOutlet weak var titleTop:NSLayoutConstraint!
    @IBOutlet weak var saveTop:NSLayoutConstraint!
    @IBOutlet weak var titleHeight:NSLayoutConstraint!
    @IBOutlet weak var username:UILabel!
    @IBOutlet weak var name:UITextField!
    
    var image:UIImage!
    var post:JPost!
    var imagePicker = UIImagePickerController()
    
    
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
        
//        titleHeight.constant =  titleHeight.constant + offset
//        closeTop.constant =  closeTop.constant + offset
//        titleTop.constant =  titleTop.constant + offset
//        saveTop.constant =  saveTop.constant + offset
//
        
        titleView.layer.shadowColor = UIColor.lightGray.cgColor
        titleView.layer.shadowOpacity = 1
        titleView.layer.shadowOffset = CGSize.zero
        titleView.layer.shadowRadius = 2
        
        titleLabel.font = UIFont(name: "Amaranth", size: 18)
        titleLabel.textColor = UIColor.black//UIColor.init(red: 27.0/256.0, green: 147.0/256.0, blue: 216.0/256.0, alpha: 1.0)
        titleLabel.text = "EDIT PROFILE"
        
    }
    func showAlert(msg:String, title:String)  {
             
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertController.Style.alert)


        let okAction = UIAlertAction(title: "OK", style: .default, handler: { [ self] (action) -> Void in
            

        deleteAccount()

         self.navigationController?.popViewController(animated: true)

              })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { [ self] (action) -> Void in
               
                 })

        //okAction.isEnabled = false

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
         
     }
    func deleteAccount()
    {
        let user = Auth.auth().currentUser
      
    
        do {
            UserService.posts(for: JUser.current) { (posts) in
                
                if(posts.count > 0)
                {
                    let dispatchGroup = DispatchGroup()
               
                   
                    
                    for post in posts
                    {
                        dispatchGroup.enter()
                     
                        PostService.delete(post, completion:
                            { (success) in
                                
                            
                            dispatchGroup.leave()
                       
                                
                        })
                    }
                    dispatchGroup.notify(queue: .main, execute: {
                        try? Auth.auth().signOut()
                        user?.delete { error in
                          if let error = error {
                            // An error happened.
                              
                          } else {
                            // Account deleted.
                              let storyboard = UIStoryboard(name: "Login", bundle: .main)
                              let vc = storyboard.instantiateViewController(withIdentifier: "Login") as! LoginViewController
                           
                              let transition = CATransition()
                              transition.duration = 0.3
                              transition.type = CATransitionType(string: "fade") as String
                              self.present(vc, animated: true, completion: nil)
                            
                          }
                        }
                    })
                }
                else
                {
                    try? Auth.auth().signOut()
                    user?.delete { error in
                      if let error = error {
                        // An error happened.
                          
                      } else {
                        // Account deleted.
                          // Account deleted.
                            let storyboard = UIStoryboard(name: "Login", bundle: .main)
                            let vc = storyboard.instantiateViewController(withIdentifier: "Login") as! LoginViewController
                         
                            let transition = CATransition()
                            transition.duration = 0.3
                            transition.type = CATransitionType(string: "fade") as String
                            self.present(vc, animated: true, completion: nil)
                          

                      }
                    }
                    
                }
              
                
             
            }
       
           
            //
        } catch {
        }
       
      
        
      
        
    }
    @IBAction func Save()
    {
        saveProfile()
    }
    @IBAction func Deletion()
    {
        showAlert(msg: "If you cancel withdrawal members, uploaded content, and other activity data will all be deleted. Are you sure you want to withdrawal members?", title: "Withdrawal of Members")

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        initTopView()
        
        username.font = UIFont(name: "Amaranth", size: 14)
        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = imgView.frame.size.width/2.0
        imgView.layer.borderColor = UIColor.white.cgColor
        imgView.layer.borderWidth = 2
       
        UserService.show(forUID: (Auth.auth().currentUser?.uid)!, completion: { (user) in
           
           // imgView.image = self.image
            self.imgView.setImageWith(URL(string: (user?.profile_url)!)! ,placeholderImage:UIImage(named: "cell_back"))
            self.name.text = user?.username
        })
        
     
        
    }
    override func viewWillAppear(_ animated: Bool) {
        JunSoftUtil.shared.isDetail = true
  
    }
    @IBAction func editProfilePhoto()
    {
       // imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
      //  imagePicker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
      //  self.present(imagePicker, animated: true, completion: nil)
       // self.presentModalViewController(imagePicker, animated: true)
  //      AudioServicesPlaySystemSound(1521)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            //println("Button capture")
            var imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            //imag.mediaTypes = [kUTTypeImage];
            imag.allowsEditing = true
            self.present(imag, animated: true, completion: nil)
        }
        
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imageName = "img_\(Date().timeIntervalSince1970)"
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
         
            self.imgView.image = image
            //delegate?.imagePickerDelegate(didSelect: image, imageName: imageName,  delegatedForm: self)
        }
        else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
           // delegate?.imagePickerDelegate(didSelect: image, imageName: imageName, delegatedForm: self)
            self.imgView.image = image
        } else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        
      //  self.dismissModalViewControllerAnimated(true)
    }
    
    @IBAction func saveProfile()
    {
        AudioServicesPlaySystemSound(1521)
        
        let loadingView = RSLoadingView()
        loadingView.show(on: self.view)
        
        UserService.saveProfile(image: self.imgView.image!, username: self.name.text!, completion: { (success) in
            
            print(success)
            RSLoadingView.hide(from: self.view)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        let touch = touches.first
        let position = touch?.location(in: self.view)
        var rect:CGRect = name.frame;
        
        if(rect.contains(position!) == false)
        {
            name.resignFirstResponder()
        }
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close()
    {
        AudioServicesPlaySystemSound(1521)
        
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
