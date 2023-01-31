//
//  IntroServiceInfoViewController.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 8. 21..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit
import WebKit

class IntroServiceInfoViewController: UIViewController {

  //  @IBOutlet var webView:WKWebView!
    @IBOutlet var webView:UIWebView!
    @IBOutlet var selIndex:UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var urlStr :String!
        selIndex.addTarget(self, action: #selector(tapPrivacy), for: UIControlEvents.valueChanged)
        
        if( selIndex.selectedSegmentIndex == 0)
        {
            // Terms of Service
         //   titleLabel.text = "Terms of Service"
            urlStr = "http://www.junsoft.org/terms_e.html"
            
        }
        else 
        {
            // Privacy Policy
          //  titleLabel.text = "Privacy Policy"
            urlStr = "http://www.junsoft.org/privacy_e.html"
            
        }
        let request = URLRequest( url: URL(string: urlStr)!)
        webView.loadRequest(request)
        
    }
    @objc func tapPrivacy() {
        var urlStr :String!
        
        if( selIndex.selectedSegmentIndex == 0)
        {
            // Terms of Service
            //   titleLabel.text = "Terms of Service"
            urlStr = "http://www.junsoft.org/terms_e.html"
            
        }
        else
        {
            // Privacy Policy
            //  titleLabel.text = "Privacy Policy"
            urlStr = "http://www.junsoft.org/privacy_e.html"
            
        }
        let request = URLRequest( url: URL(string: urlStr)!)
        webView.loadRequest(request)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
    }
}
