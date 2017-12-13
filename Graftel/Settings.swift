//
//  Settings.swift
//  Shorabh
//
//  Created by Shorabh on 9/2/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit

class Settings:UIViewController {
    
    let defaults = UserDefaults.standard
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var Scroller: UIScrollView!
    @IBOutlet weak var textField: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        Scroller.isScrollEnabled = true
        Scroller.contentSize = CGSize(width: 300, height: 580)
        textField?.text = (textField?.text)! + User.contactPersonName
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    @IBAction func signOut(_ sender: AnyObject) {
        defaults.removeObject(forKey: "user")
        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login") as! Login
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}
