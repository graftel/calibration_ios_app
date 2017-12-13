//
//  ForgotPassword.swift
//  Shorabh
//
//  Created by Shorabh on 9/2/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit

class ForgotPassword : UIViewController {
    
    @IBOutlet var webView:UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        let URL = Foundation.URL(string: "http://www.graftel.com/portal/forgot-password/")
        webView.loadRequest(URLRequest(url: URL!))
    }
}
