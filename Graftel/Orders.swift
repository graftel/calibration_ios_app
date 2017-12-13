//
//  Orders.swift
//  Shorabh
//
//  Created by Shorabh on 7/29/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import Foundation
import UIKit

class Orders: UITableViewController,SWRevealViewControllerDelegate {
    
    var TableData:Array< Array < String >> = Array < Array < String >>()
    var quoteID:String!
    @IBOutlet weak var menuButton:UIBarButtonItem!
    var sidebarMenuOpen:Bool!
    let defaults = UserDefaults.standard
    var from_Profile:Bool!
    
    //MARK:Properties
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationItem.hidesBackButton = true
        sidebarMenuOpen = false
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().delegate = self
        }
    }
    
    
    let alert = UIAlertController(title:nil, message: "Loading.. Please wait", preferredStyle: UIAlertControllerStyle.alert)
    
    func showDialog() {
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 15, y: 12, width: 37, height: 37))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            //self.view.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            //self.view.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            //self.view.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            //self.view.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
         if(sidebarMenuOpen == true){
            return nil
        } else {
            return indexPath
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.navigationItem.hidesBackButton = true
        getUser()
        //sidebarMenuOpen = false
        TableData.removeAll()
        showDialog()
        var locked:Bool = false
        DispatchQueue.global().async {
        //DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            locked = true
            // Define server side script URL
            let scriptUrl = "http://www.graftel.com/appport/webGetOrderInfoProd.php"
            // Add one parameter
            let urlWithParams = scriptUrl + "?user=\(User.UID)"
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
                //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                //print("responseString = \(responseString)")
                // Convert server json response to NSDictionary
                do {
                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        //print(convertedJsonIntoDict)
                        let success  = convertedJsonIntoDict["success"] as? Int
                        if success == 1 {
                            let jsonArray = convertedJsonIntoDict["temp"] as? NSArray
                            for i in 0 ..< jsonArray!.count {
                                let c = jsonArray?.object(at: i) as? NSDictionary
                                var Temp : Array <String> = Array<String>()
                                let line1 = c!["QuoteID"] as? String
                                let tem = c!["Description"] as? String
                                let line = tem?.characters.split{$0 == ","}.map(String.init)
                                var line2 = ""
                                for j in 0..<line!.count {
                                    line2 += line![j]
                                    if j != (line!.count)-1 {
                                        line2 += "\n"
                                    }
                                }
                                let line3 = c!["Status"] as? String
                                Temp.append(line1!)
                                Temp.append(line2)
                                Temp.append(line3!)
                                self.TableData.append(Temp)
                                //print(self.TableData[i][0])
                            }
                            //self.do_table_refresh();
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
                let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        DispatchQueue.main.async {
            while(locked) {
                self.wait()
            }
            self.alert.dismiss(animated: false, completion:nil)
            self.tableView.reloadData()
        }
    }
    
    func wait()
    {
        RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 1))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableData.count
    }
    
    /*func do_table_refresh()
    {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            return
        })
    }*/
    
    func getUser() {
        print(defaults.object(forKey: "IsTempUser")!)
        User.isTempUser = defaults.object(forKey: "IsTempUser") as! Int
        User.UID = defaults.object(forKey: "UID") as! Int
        User.loginEmail = defaults.object(forKey: "LoginEmail") as! String
        User.password = defaults.object(forKey: "Password") as! String
        User.companyName = defaults.object(forKey: "CompanyName") as! String
        User.contactPersonName = defaults.object(forKey: "ContactPersonName") as! String
        User.shippingAddress = defaults.object(forKey: "ShippingAddress") as! String
        User.phone = defaults.object(forKey: "Phone") as! String
        User.fax = defaults.object(forKey: "Fax") as! String
        User.addEmail1 = defaults.object(forKey: "AdditionalEmail1") as! String
        User.addEmail2 = defaults.object(forKey: "AdditionalEmail2") as! String
        User.addEmail3 = defaults.object(forKey: "AdditionalEmail3") as! String
        User.addEmail4 = defaults.object(forKey: "AdditionalEmail4") as! String
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OrdersCell
        let arr:Array<String> = TableData[(indexPath as NSIndexPath).row]
        cell.quote?.text = "Quote ID: "+arr[0]
        cell.desc?.text = arr[1]
        cell.status?.text = arr[2]
        //cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        quoteID = TableData[(indexPath as NSIndexPath).row][0]
        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "Quote Detail") as! QuoteDetail
        secondViewController.toPass = quoteID
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}
