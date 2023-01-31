//
//  RegisterViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 8. 28..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import RSLoadingView
import FirebaseAuth
import ESTabBarController_swift

class RegisterViewController: UIViewController {

    var fadeTransition: FadeTransition!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var cpassword: UITextField!
    @IBOutlet weak var name : UITextField!
    @IBOutlet weak var descView : UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPrivacy))
        descView.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func tapPrivacy() {
        
        //
        print("Please Help!")
        performSegue(withIdentifier: "exec_r_privacy", sender: nil)
        
        
    }
    @IBAction func register()
    {
        email.resignFirstResponder()
        password.resignFirstResponder()
       // cpassword.resignFirstResponder()
        name.resignFirstResponder()
        
        let loadingView = RSLoadingView()
        loadingView.show(on: self.view)
        
        if(self.name.text != nil)
        {
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
                        
                        UserService.create2(firUser,name:self.name.text!) { (user) in
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
                    RSLoadingView.hide(from: self.view)
                    
                }
            }
        }
        else
        {
            RSLoadingView.hide(from: self.view)
            
        }
      
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

    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        email.resignFirstResponder()
        password.resignFirstResponder()
    //    cpassword.resignFirstResponder()
        name.resignFirstResponder()
    }
}
