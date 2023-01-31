//
//  IntroViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 8. 20..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    lazy var imageView = UIImageView()
    
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var descView:UITextView!
  
    @IBOutlet weak var imgTop:NSLayoutConstraint!
    @IBOutlet weak var bottom:NSLayoutConstraint!
    @IBOutlet weak var imgWidth:NSLayoutConstraint!
    @IBOutlet weak var imgHeight:NSLayoutConstraint!
    
    var page:Int!
    
    override func awakeFromNib() {
        if(page == 0)
        {
            imgView.image = UIImage(named: "fig1")
            descView.text = "Take and share your lovely pet\nFriends wait"
        }
        else if(page == 1)
        {
            imgView.image = UIImage(named: "fig2")
            descView.text = "Make your lovely pet stand out with\nbeautiful filters and overlay effects"
            
        }
        else if(page == 2)
        {
            //   self.navigationController?.navigationBar.ti = ""
            self.navigationController?.navigationItem.title  = ""
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descView.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.init(red: 27.0/255.0, green: 147.0/255.0, blue: 216.0/255.0, alpha: 1.0), NSAttributedStringKey.font:  UIFont(name: "Amaranth", size: 20)]
        if(page == 0)
        {
            imgView.image = UIImage(named: "fig1")
            descView.text = "Take and share your lovely pet\nFriends wait"
        }
        else if(page == 1)
        {
            imgView.image = UIImage(named: "fig2")
            descView.text = "Make your lovely pet stand out with\nbeautiful filters and overlay effects"
            
        }
        else if(page == 2)
        {
            //   self.navigationController?.navigationBar.ti = ""
            self.navigationController?.navigationItem.title  = ""
            
        }
     
    }
    override func viewWillAppear(_ animated: Bool) {
    
        super.viewWillAppear(animated)
        
        let height:CGFloat =  0.7*( self.view.frame.size.height  )
        let width:CGFloat =  ( self.view.frame.size.width )
        imgHeight.constant = height
        imgWidth.constant = width
        
        let top:CGFloat =  ( self.view.frame.size.height  - height - 66 - (self.navigationController?.navigationBar.frame.size.height)! - 50) / 2.0
        imgTop.constant = top
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.init(red: 27.0/255.0, green: 147.0/255.0, blue: 216.0/255.0, alpha: 1.0), NSAttributedStringKey.font:  UIFont(name: "Amaranth", size: 20)]
        if(page == 0)
        {
            imgView.image = UIImage(named: "fig1")
            descView.text = "Take and share your lovely pet\nFriends wait"
        }
        else if(page == 1)
        {
            imgView.image = UIImage(named: "fig2")
            descView.text = "Make your lovely pet stand out with\nbeautiful filters and overlay effects"
            
        }
        else if(page == 2)
        {
            //   self.navigationController?.navigationBar.ti = ""
            self.navigationController?.navigationItem.title  = ""
            
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.init(red: 27.0/255.0, green: 147.0/255.0, blue: 216.0/255.0, alpha: 1.0), NSAttributedStringKey.font:  UIFont(name: "Amaranth", size: 20)]
        
        let height:CGFloat =  0.7*( self.view.frame.size.height  )
        let width:CGFloat =  ( self.view.frame.size.width )
        imgHeight.constant = height
        imgWidth.constant = width
        
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        
        let top:CGFloat =  (self.view.frame.size.height  - height - 66 - navBarHeight! ) / 2.0
       
        imgTop.constant = top
        
        if(page == 0)
        {
            imgView.image = UIImage(named: "fig1")
            descView.text = "Take and share your lovely pet\nFriends wait"
        }
        else if(page == 1)
        {
            imgView.image = UIImage(named: "fig2")
            descView.text = "Make your lovely pet stand out with\nbeautiful filters and overlay effects"
            
        }
        else if(page == 2)
        {
         //   self.navigationController?.navigationBar.ti = ""
            self.navigationController?.navigationItem.title  = ""
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
