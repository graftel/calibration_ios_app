//
//  Services.swift
//  Shorabh
//
//  Created by Shorabh on 8/4/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit

class Services : UIViewController {
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet var webView:UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let URL = Foundation.URL(string: "http://www.graftel.com/services/")
        webView.loadRequest(URLRequest(url: URL!))
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}
