//
//  ViewController.swift
//  Shorabh
//
//  Created by Shorabh on 7/27/16.
//  Copyright © 2016 Graftel. All rights reserved.
//
import UIKit


class Login: UIViewController {
    
    //MARK:Properties
    @IBOutlet var username: UITextField!
    @IBOutlet weak var Scroller: UIScrollView!
    @IBOutlet var password: UITextField!
    @IBOutlet weak var register: UILabel!
    @IBOutlet weak var clickHere: UIButton!
    @IBOutlet var signin: AnyObject!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var email:Bool = false
    var flag:Bool = false
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        self.navigationController?.isNavigationBarHidden = true
        Scroller.isScrollEnabled = true
        Scroller.contentSize = CGSize(width: 300, height: 580)
        //defaults.synchronize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.activityIndicatorView?.isHidden = true
        if defaults.object(forKey: "user") != nil {
            flag = defaults.object(forKey: "user") as! Bool
        }
        if flag==true {
            let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "Reveal View Controller") as! SWRevealViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    let alert = UIAlertController(title:nil, message: "Loading.. Please wait", preferredStyle: UIAlertController.Style.alert)

    //MARK:Actions
    @IBAction func signin(_ sender: AnyObject) {
        email=false
        var valid:Bool = false
        var locked:Bool = true
        self.activityIndicatorView.isHidden = false
        self.activityIndicatorView.startAnimating()
        //username.text = "shor@graftel.com"
        //password.text = "qweasd123"
        //showDialog()
        //username.text = "WEB2688"
        //password.text = "pKyEt8"
        if(!self.isStringEmpty(self.username.text!) && !self.isStringEmpty(self.password.text!)) {
            DispatchQueue.global().async {
                locked = true
                if(self.isValidEmail(self.username.text!)) {
                    self.email=true
                }
                // Define server side script URL
                let scriptUrl = "http://www.graftel.com/appport/webGetUserInfoProd.php"
                // Add one parameter
                let urlWithParams:String
                if(self.email) {
                    urlWithParams = scriptUrl + "?email=\(self.username.text!)"
                }
                else {
                    urlWithParams = scriptUrl + "?user=\(self.username.text!)"
                }
                //print(urlWithParams)
                // Create NSURL Ibject
                let myUrl = URL(string: urlWithParams);
                // Creaste URL Request
                var request = URLRequest(url:myUrl!);
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
                                let jsonArray = convertedJsonIntoDict["temp"] as? NSArray
                                if (jsonArray?.count)! > 0 {
                                    for i in 0 ..< jsonArray!.count {
                                        let c = jsonArray?.object(at: i) as? NSDictionary
                                        self.addUser(c: c!)
                                        var pass = c!["Password"] as? String
                                        User.isTempUser = c!["IsTempUser"] as! Int
                                        User.companyName = c!["CompanyName"] as! String
                                        if(self.email) {
                                            pass! = pass!.replacingOccurrences(of: "\n", with: "")
                                            pass! = (pass?.removingPercentEncoding)!
                                            valid = Password().verifyHashedValue(hashedValue: (pass)!,providedValue: self.password.text!)
                                        }
                                        else {
                                            valid = self.password.text!.isEqual(pass)
                                        }
                                    }
                                }
                                else {
                                    DispatchQueue.main.async {
                                        let alert = UIAlertController(title: "Failure", message: "Username not found!", preferredStyle: UIAlertController.Style.alert)
                                        alert.addAction(UIAlertAction(title: "Try Again!", style: UIAlertAction.Style.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                                
                            }
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    locked = false
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
                self.activityIndicatorView.stopAnimating()
                //print(valid)
                if(valid) {
                    if(self.email) {
                        self.defaults.set(true, forKey: "user")
                        self.defaults.set(0, forKey: "IsTempUser")
                        self.defaults.synchronize()
                        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "Reveal View Controller") as! SWRevealViewController
                        self.navigationController?.pushViewController(secondViewController, animated: true)
                    }
                    else {
                        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "Profile") as! Profile
                        self.navigationController?.pushViewController(secondViewController, animated: true)
                    }
                }
                else
                {
                    let alert = UIAlertController(title: "Failure", message: "Wrong Username/Password!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Try Again!", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                }
            }
        else {
            self.activityIndicatorView.isHidden = true
            self.activityIndicatorView.stopAnimating()
            let alert = UIAlertController(title: "", message: "Enter Username/Password!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Try Again!", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func addUser(c:NSDictionary)
    {
        let pass = c["Password"] as! String
        if(self.email){
            defaults.set(c["UID"], forKey: "UID")
            defaults.set(c["LoginEmail"], forKey: "LoginEmail")
            defaults.set(pass.replacingOccurrences(of: "\n", with: ""), forKey: "Password")
            defaults.set(c["CompanyName"], forKey: "CompanyName")
            defaults.set(c["ContactPersonName"], forKey: "ContactPersonName")
            defaults.set(c["ShippingAddress"], forKey: "ShippingAddress")
            defaults.set(c["Phone"], forKey: "Phone")
            defaults.set(c["Fax"], forKey: "Fax")
            defaults.set(c["AdditionalEmail1"], forKey: "AdditionalEmail1")
            defaults.set(c["AdditionalEmail2"], forKey: "AdditionalEmail2")
            defaults.set(c["AdditionalEmail3"], forKey: "AdditionalEmail3")
            defaults.set(c["AdditionalEmail4"], forKey: "AdditionalEmail4")
            defaults.synchronize()
        }
        else {
            User.UID = c["UID"] as! Int
            User.companyName = c["CompanyName"] as! String
        }
        
    }
    
    func wait()
    {
        RunLoop.current.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 1))
    }
    
    func showDialog() {
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 15, y: 12, width: 37, height: 37))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
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
    
    @IBAction func forgotPassword(_ sender: AnyObject) {
        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "Forgot Password") as! ForgotPassword
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @IBAction func sendMessage(_ sender: AnyObject) {
        //self.navigationController?.navigationBarHidden = false
        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "Send Message") as! SendMessage
        self.navigationController?.pushViewController(secondViewController, animated: true)
        
    }
}

