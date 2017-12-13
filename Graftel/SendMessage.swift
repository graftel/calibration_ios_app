//
//  SendMessage.swift
//  Shorabh
//
//  Created by Shorabh on 7/27/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit
import SendGrid

class SendMessage : UIViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var company: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var Scroller: UIScrollView!
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        Scroller.isScrollEnabled = true
        Scroller.contentSize = CGSize(width: 300, height: 580)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.revealViewController() != nil && defaults.object(forKey: "user") != nil {
            self.navigationItem.leftBarButtonItem = menuButton
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        else {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    @IBAction func send(_ sender: AnyObject) {
        if name?.text?.isEmpty == true || company?.text?.isEmpty==true || email?.text?.isEmpty==true || message?.text?.isEmpty==true {
            let alert = UIAlertController(title: "Error", message: "Please enter required fields!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            //Send Mail
            var yes:Bool = false
            let session = SendGrid.Session()
            session.authentication = Authentication.apiKey(SendGridKey)
            let personalization = Personalization(to: [Address((self.email?.text)!)], bcc: [Address("scott@graftel.com"),Address("kangmin@graftel.com"),Address("esther@graftel.com"),Address("pdavis@graftel.com")])
            let body:String = "\nThis a confirmation that your quote request has been successfully sent to Graftel, we will respond to you within 24 hours.\n"+"\nThank you for contacting Graftel LLC. Below is the original message.\n"+"\n---------------------------------------------------------------------------------------------------------------------------------\n"+"\nMessage from "+name!.text!+" ( "+self.email!.text!+" ) \n"+"\n"+message!.text!
            let plainText = Content(contentType: ContentType.plainText, value: body)
            let email = Email(
                personalizations: [personalization],
                from: Address(email: "scott@graftel.com", name: "Graftel APP"),
                replyTo: Address((self.email?.text)!),
                content: [plainText],
                subject: "[Graftel APP] Your message has been sent to Graftel"
            )
            do {
                //try SendGrid.Session.sharedInstance.send(email)
                try session.send(request: email)
                yes=true
            }
            catch {
                print(error)
            }
            if(yes == true) {
                let alert = UIAlertController(
                    title: "",
                    message: "Mail Sent, Thank you!",
                    preferredStyle: .alert
                )
                self.present(alert, animated: true, completion: nil)
                let time = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    alert.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
}

