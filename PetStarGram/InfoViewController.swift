//
//  InfoViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 8. 7..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper
import GoogleSignIn

class InfoViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView?

    @IBOutlet var titleView:UIView!
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var titleHeight:NSLayoutConstraint!
    @IBOutlet var closeTop:NSLayoutConstraint!
    @IBOutlet var titleTop:NSLayoutConstraint!
    
    var settings:NSArray?
    var versionString:String!
    
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
        titleLabel.text = "Settings"
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initTopView()
      //     NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let cameraSettings:NSArray = ["Silence Mode","Mirroring Mode"]
        let maskSettings:NSArray = ["Open Eyes"]
        let aboutSettings:NSArray = ["Terms of Service","Privacy Policy","Rate Pet Star","Version"]
        let serviceSettings:NSArray = ["Log out","Blocked Users","Withdrawal of Members"]
        
        
        
        let cameraSettingsDict:Dictionary = ["Camera Settings":cameraSettings]
        let aboutSettingsDict:Dictionary = ["About":aboutSettings]
        let serviceSettingsDict:Dictionary = ["Pet Star":serviceSettings]
        
        
        settings = [cameraSettingsDict,aboutSettingsDict, serviceSettingsDict]

        self.tableView?.reloadData()
       

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "exec_service_info"{
            
            if let serviceViewController = segue.destination as? ServiceInfoViewController{
                
                var destinationViewController = segue.destination
                let index : Int = sender as! Int
                serviceViewController.index = index
                
                // Set the modal presentation style of your destinationViewController to be custom.
             
            }
            
        }
        
        //
        
        
    }
    @IBAction func didTapCloseButton() {
        
        dismiss(animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func onSwitchBtn(sender:UISwitch)
    {
        let state:Bool = sender.isOn //[sender isOn];
        let user:UserDefaults = UserDefaults.standard
        
        print("state:", state)
        print("index:" , sender.tag)
        
        if(sender.tag == 0)
        {
            user.set(state, forKey: "SILENCE")
        }
        if(sender.tag == 1)
        {
            user.set(state, forKey: "MIRRORING")
        }
      
        user.synchronize()
    }
    func logout()
    {
        let title =  "Warning"
        let message =  "Are you sure you want to log out?"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //  alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) in
            
            //Implement action
            
            do {
                try Auth.auth().signOut()
               
                //
            } catch {
            }
           // GIDSignIn.sharedInstance().disconnect()
            //  dismiss(animated: true, completion: nil)
            let storyboard = UIStoryboard(name: "Login", bundle: .main)
            
            if let initialViewController = storyboard.instantiateInitialViewController() {
                // 3
                self.view.window?.rootViewController = initialViewController
                // 4
                self.view.window?.makeKeyAndVisible()
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            
            //Implement action
            
        }
        
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        
        
        
        present(alert, animated: true, completion: nil)
    }
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //return 0
        return (settings?.count)!
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if(section == 0)
        {
            return "Camera Settings"
            
        }
        
        else if(section == 1)
        {
            return "About"
            
        }
        else
        {
            return "Pet Star"
            
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return swiftBlogs.count
        
        if(section == 0)
        {
            return 2
            
        }
        else if(section == 1)
        {
            return 4
            
        }
       
        else
        {
            return 3
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let dict:NSDictionary = settings![indexPath.section] as! NSDictionary
        
        
        
        for (_, value) in dict {
            // print("Value: \(value) for key: \(key)")
            let array =  value as! NSArray
            let tempString = array[indexPath.row] as? String
            if(tempString == "Version")
            {
                let label:UILabel = UILabel()
                label.frame = CGRect(x:0,y:0,width:100,height:20)
                label.text = versionString
                label.textAlignment = .right
                label.textColor = UIColor.gray
                label.font = UIFont(name: "Helvetica", size: 16)
                print(versionString)
                cell.accessoryView = label
                
            }
            else if(tempString == "Terms of Service" ||
                tempString == "Privacy Policy" ||
                tempString == "Rate Pet Star" ||
                tempString == "Blocked Users" )
            {
                cell.accessoryType = .disclosureIndicator
            }
                
            else  if(tempString == "Silence Mode" ||
                tempString == "Mirroring Mode")
            {
                let switchBtn:UISwitch = UISwitch()
                switchBtn.onTintColor = UIColor(red: 98.0/255.0, green: 200.0/255.0, blue: 243.0/255.0, alpha: 1.0)
                
                switchBtn.addTarget(self, action:#selector(self.onSwitchBtn(sender:)) ,for: UIControlEvents.valueChanged)
      
                let tag:Int = indexPath.section + indexPath.row
                switchBtn.tag = tag
                
                let user:UserDefaults = UserDefaults.standard
                
                let silence:Bool = user.bool(forKey: "SILENCE")
                let mirroring:Bool = user.bool(forKey: "MIRRORING")
                if(tag == 0)
                {
                    switchBtn.isOn = silence
                    
                }
                else
                {
                    switchBtn.isOn = mirroring
                    
                }
                
                cell.accessoryView = switchBtn
                
            }
            
            
            
            cell.textLabel?.text = tempString
            
            
        }
        return cell
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
                              
                              if let initialViewController = storyboard.instantiateInitialViewController() {
                                  // 3
                                  self.view.window?.rootViewController = initialViewController
                                  // 4
                                  self.view.window?.makeKeyAndVisible()
                              }
                            
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
                          let storyboard = UIStoryboard(name: "Login", bundle: .main)
                          
                          if let initialViewController = storyboard.instantiateInitialViewController() {
                              // 3
                              self.view.window?.rootViewController = initialViewController
                              // 4
                              self.view.window?.makeKeyAndVisible()
                          }
                        
                      }
                    }
                    
                }
              
                
             
            }
       
           
            //
        } catch {
        }
       
      
        
      
        
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
     //   self.chat = chats[indexPath.row]
        
       // performSegue(withIdentifier: "exec_chat", sender: nil)
        self.tableView?.deselectRow(at: indexPath, animated: true)
      

        if( indexPath.section == 2)
        {
            if(indexPath.row == 0)
            {
                logout()
                
            }
            else if(indexPath.row == 1)
            {
                performSegue(withIdentifier: "exec_block", sender: nil)
                
            }
            else
            {
                //탈퇴
                showAlert(msg: "If you cancel withdrawal members, uploaded content, and other activity data will all be deleted. Are you sure you want to withdrawal members?", title: "Withdrawal of Members")
            }
        }
        else if( indexPath.section == 1)
        {
            // About
           // exec_service_info
            if (indexPath.row == 0 ||
            indexPath.row == 1)
            {
                performSegue(withIdentifier: "exec_service_info", sender: indexPath.row)
                
            }
            else if(indexPath.row == 2)
            {
                iRate.sharedInstance().promptForRating()
            }
          //  self.present(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        }
        //promptForRating
        
       
        
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
