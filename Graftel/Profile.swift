//
//  Profile.swift
//  Shorabh
//
//  Created by Shorabh on 8/4/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit
import SendGrid

class Profile : UIViewController {
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var contactPersonNam: UITextField!
    @IBOutlet weak var shippingAddress: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var fax: UITextField!
    @IBOutlet weak var addEmail1: UITextField!
    @IBOutlet weak var addEmail2: UITextField!
    @IBOutlet weak var addEmail3: UITextField!
    @IBOutlet weak var addEmail4: UITextField!
    @IBOutlet weak var Back: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var rePassText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var rePassLabel: UILabel!
    @IBOutlet weak var passLabel: UILabel!
    
    let defaults = UserDefaults.standard
    
    @IBAction func changePassword(_ sender: AnyObject) {
        passLabel.isEnabled = true
        passText.isEnabled = true
        rePassLabel.isEnabled = true
        rePassText.isEnabled = true
    }
    
    @IBAction func backToLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        scroller.isScrollEnabled = true
        print(view.heightAnchor)
        scroller.contentSize = CGSize(width: 300, height: 1230)
        scroller.alwaysBounceHorizontal = false
        if(User.isTempUser == 0) {
            if self.revealViewController() != nil {
                menuButton.target = self.revealViewController()
                menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
                self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
            loginEmail?.text = User.loginEmail
            loginEmail.isEnabled = false
            contactPersonNam?.text = User.contactPersonName
            shippingAddress?.text = User.shippingAddress
            phone?.text = User.phone
            fax?.text = User.fax
            addEmail1?.text = User.addEmail1
            addEmail2?.text = User.addEmail2
            addEmail3?.text = User.addEmail3
            addEmail4?.text = User.addEmail4
            changeButton.isHidden = false
        }
        else {
            //self.navigationItem.leftBarButtonItem = nil
            //self.navigationController?.isNavigationBarHidden = false
            Back.isHidden = false
            companyName?.text = User.companyName
            passLabel.isEnabled = true
            passText.isEnabled = true
            rePassLabel.isEnabled = true
            rePassText.isEnabled = true
        }
        companyName?.text = User.companyName
        
    }
    
    var pwd:String!
    
    @IBAction func update(_ sender: AnyObject) {
        
        if((loginEmail?.text?.isEmpty) == true || companyName?.text?.isEmpty == true || contactPersonNam?.text?.isEmpty == true || phone?.text?.isEmpty == true) {
            let alert = UIAlertController(title: "Error", message: "Please enter all the required fields!", preferredStyle: .alert)
            //alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            let time = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        }
        else {
            if(isValidEmail(loginEmail.text!)) {
                if(passText.isEnabled == false && rePassText.isEnabled == false) {
                    //print("DD",User.password)
                    pwd = User.password
                    Load()
                }
                else {
                    if(passText?.text == rePassText?.text) {
                        pwd = Password().hashValue(passText.text!)
                        pwd! = pwd!.replacingOccurrences(of: "\n", with: "")
                        pwd! = pwd!.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!
                        Load()
                    }
                    else {
                        let alert = UIAlertController(title: "Error", message: "Password doesn't match!", preferredStyle: .alert)
                        //alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        let time = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: time, execute: {
                            alert.dismiss(animated: true, completion: nil)
                        })
                    }
                }
            }
            else {
                let alert = UIAlertController(title: "Error", message: "Email Address is invalid!", preferredStyle: .alert)
                //alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                let time = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    alert.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    let alert = UIAlertController(title:nil, message: "Loading.. Please wait", preferredStyle: UIAlertController.Style.alert)
    func showDialog() {
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 15, y: 12, width: 37, height: 37))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
        
    }
    func Load() {
        var flag:Bool = false
        var locked:Bool = false
        //showDialog()
        DispatchQueue.global().async {
            // Define server side script URL
            locked = true
            let scriptUrl = "http://www.graftel.com/appport/webUpdateCustomerInfo.php"
            // Add one parameter
            let urlWithParams:String
            urlWithParams = scriptUrl + "?user=\(User.UID)&temp=0&email=\(self.loginEmail.text!)&pwd=\(self.pwd!)&name=\(self.companyName.text!)&contact=\(self.contactPersonNam.text!)&phone=\(self.phone.text!)&ship=\(self.shippingAddress.text!)&fax=\(self.fax.text!)&email1=\(self.addEmail1.text!)&email2=\(self.addEmail2.text!)&email3=\(self.addEmail3!.text!)&email4=\(self.addEmail4!.text!)"
            // Create NSURL Ibject
            let myUrl = URL(string: urlWithParams.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            // Creaste URL Request
            var request = URLRequest(url:myUrl!)
            // Set request HTTP method to GET. It could be POST as well
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                // Check for error
                if error != nil {
                    print("error=\(error)")
                    return
                }
                // Print out response string
                //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                //print("responseString = \(responseString)")
                do {
                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        //print(convertedJsonIntoDict)
                        let success  = convertedJsonIntoDict["success"] as? Int
                        if success == 1 {
                             flag=true
                        }
                        if success == -1 {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "", message: "Email Address already Exist!", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Try Again!", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        if success == 0 {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "", message: "Email Address doesn't Exist!", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Try Again!", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                locked=false
            }
            if isConnected() == true {
                  task.resume()
            }
            else {
                let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK!", style: UIAlertAction.Style.default, handler: nil))
                  self.present(alert, animated: true, completion: nil)
            }
        }
        DispatchQueue.main.async {
            while(locked) {
                self.wait()
            }
            //self.alert.dismiss(animated: false, completion:nil)
            if flag == true {
                if User.isTempUser != 0 {
                    if isConnected() == true {
//                        let session = SendGrid.Session()
//                        session.authentication = Authentication.apiKey(SendGridKey)
//                        let personalization = Personalization(to: [Address(stringLiteral: self.loginEmail!.text!)], bcc: [Address("scott@graftel.com"),Address("kangmin@graftel.com"),Address("esther@graftel.com"),Address("pdavis@graftel.com")])
//                        let body:String = "\nUID: \(User.UID) \n"+"\n Login Email: \(self.loginEmail!.text!) \n"+"\n Company: \(self.companyName!.text!) \n"+"\n Contact Person Name: \(self.contactPersonNam!.text!) \n"+"\n Phone: \(self.phone!.text!) \n"
//                        let plainText = Content(contentType: ContentType.plainText, value: body)
//                        //let htmlText = Content(contentType: ContentType.HTMLText, value: "<h1>Hello World</h1>")
//                        let email = Email(
//                            personalizations: [personalization],
//                            from: Address(email: "scott@graftel.com", name: "Graftel APP"),
//                            replyTo: Address(stringLiteral: self.loginEmail!.text!),
//                            content: [plainText],
//                            subject: "[Graftel APP] New Customer Creation Notification"
//                        )
//                        do {
//                            try session.send(request: email)
//                        }
//                        catch {
//                            print(error)
//                        }
                    }
                    else {
                        let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK!", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                self.defaults.set(true, forKey: "user")
                //self.defaults.synchronize()
                self.defaults.set(User.UID, forKey: "UID")
                self.defaults.set(0, forKey: "IsTempUser")
                self.defaults.set(self.loginEmail!.text, forKey: "LoginEmail")
                //self.defaults.set(self.passText!.text, forKey: "Password")
                self.defaults.set(self.pwd!, forKey: "Password")
                self.defaults.set(self.companyName!.text, forKey: "CompanyName")
                self.defaults.set(self.contactPersonNam!.text, forKey: "ContactPersonName")
                self.defaults.set(self.shippingAddress!.text, forKey: "ShippingAddress")
                self.defaults.set(self.phone!.text, forKey: "Phone")
                self.defaults.set(self.fax!.text, forKey: "Fax")
                self.defaults.set(self.addEmail1!.text, forKey: "AdditionalEmail1")
                self.defaults.set(self.addEmail2!.text, forKey: "AdditionalEmail2")
                self.defaults.set(self.addEmail3!.text, forKey: "AdditionalEmail3")
                self.defaults.set(self.addEmail4!.text, forKey: "AdditionalEmail4")
                self.defaults.synchronize()
                let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "Reveal View Controller") as! SWRevealViewController
                
                //secondViewController.navigationItem.hidesBackButton = true
                secondViewController.navigationItem.title = "Orders"
                secondViewController.navigationItem.leftBarButtonItem = self.menuButton
                self.navigationController?.pushViewController(secondViewController, animated: true)
            }
        }
    }
    
    func wait()
    {
        RunLoop.current.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 1))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isStringEmpty(_ stringValue:String) -> Bool
    {
        var stringValue = stringValue
        var returnValue = false
        if stringValue.isEmpty  == true
        {
            returnValue = true
            return returnValue
        }
        // Make sure user did not submit number of empty spaces
        stringValue = stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if(stringValue.isEmpty == true)
        {
            returnValue = true
            return returnValue
        }
        return returnValue
    }
}
