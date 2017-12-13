//
//  Search.swift
//  Shorabh
//
//  Created by Shorabh on 8/26/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import Foundation

class Search:UIViewController {
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var PO: UITextField!
    @IBOutlet weak var Serial: UITextField!
    @IBOutlet weak var Scroller: UIScrollView!
    @IBOutlet weak var MTE: UITextField!
    @IBOutlet weak var from: UIDatePicker!
    @IBOutlet weak var to: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        Scroller.isScrollEnabled = true
        Scroller.contentSize = CGSize(width: 300, height: 580)
    }
    @IBAction func search(_ sender: AnyObject) {
        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "Search Results") as! SearchResults
        let dateformat = DateFormatter()
        dateformat.dateFormat = "MM-dd-yyyy"
        if(PO?.text?.isEmpty==true && Serial?.text?.isEmpty==true && MTE?.text?.isEmpty==true) {
            if(dateformat.string(from:self.from.date) == dateformat.string(from:self.to.date)) {
                let alert = UIAlertController(title: "Error", message: "Please enter atleast one Search Criteria!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Try Again!", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                secondViewController.from = dateformat.string(from:self.from.date)
                secondViewController.to = dateformat.string(from:self.to.date)
                secondViewController.PO = ""
                secondViewController.Serial = ""
                secondViewController.MTE = ""
            }
        }
        else {
            if(dateformat.string(from:self.from.date) == dateformat.string(from:self.to.date)){
                secondViewController.from = ""
                secondViewController.to = ""
            }
            else {
                secondViewController.from = dateformat.string(from:self.from.date)
                secondViewController.to = dateformat.string(from:self.to.date)
            }
            secondViewController.PO = PO.text
            secondViewController.Serial = Serial.text
            secondViewController.MTE = MTE.text
        }
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}
