//
//  ServiceInfoViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 8. 7..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import WebKit

class ServiceInfoViewController: UIViewController {

  //  @IBOutlet var webView:WKWebView!
    @IBOutlet var webView:UIWebView!
    
    @IBOutlet var titleView:UIView!
    @IBOutlet var titleLabel:UILabel!
    
    var index:Int!
    
    func initTopView()
    {
        
        titleView.layer.shadowColor = UIColor.lightGray.cgColor
        titleView.layer.shadowOpacity = 1
        titleView.layer.shadowOffset = CGSize.zero
        titleView.layer.shadowRadius = 2
        
        titleLabel.font = UIFont(name: "Amaranth", size: 18)
        titleLabel.textColor = UIColor.init(red: 27.0/256.0, green: 147.0/256.0, blue: 216.0/256.0, alpha: 1.0)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        initTopView()
        var urlStr :String!
        
        if( self.index == 0)
        {
            // Terms of Service
            titleLabel.text = "Terms of Service"
            urlStr = "http://www.junsoft.org/terms_e.html"
            
        }
        else if( self.index == 1)
        {
            // Privacy Policy
            titleLabel.text = "Privacy Policy"
            urlStr = "http://www.junsoft.org/privacy_e.html"
            
        }
        let request = URLRequest( url: URL(string: urlStr)!)
        webView.loadRequest(request)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCloseButton() {
        
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func close() {
        
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
