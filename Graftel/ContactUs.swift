//
//  ContactUs.swift
//  Shorabh
//
//  Created by Shorabh on 8/5/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit

class ContactUS : UITableViewController {
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}
