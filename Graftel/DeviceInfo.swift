//
//  DeviceInfo.swift
//  Shorabh
//
//  Created by Shorabh on 8/5/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit
import SendGrid

class DeviceInfo: UITableViewController {
    
    var toPass:String!
    var TableData:Array< Array < String >> = Array < Array < String >>()
    
    //MARK:Properties
    override func viewDidLoad() {
        super.viewDidLoad()
        let myUIViewController = self.navigationController!.viewControllers[(self.navigationController!.viewControllers.count)-2] as UIViewController
        if(myUIViewController.title! != "Quote Detail" && myUIViewController.title! != "Search Results") {
            let requoteAll = UIBarButtonItem(title: "Requote All", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DeviceInfo.requoteAll(_:)))
            self.navigationItem.rightBarButtonItem = requoteAll
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
    
    override func viewDidAppear(_ animated: Bool) {
        TableData.removeAll()
        showDialog()
        var locked:Bool = false
        DispatchQueue.global().async {
        //DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            locked = true
            // Define server side script URL
            let scriptUrl = "http://www.graftel.com/appport/webGetAllCalInfoProd.php"
            // Add one parameter
            let urlWithParams = scriptUrl + "?cal=\(self.toPass!)"
            // Create NSURL Ibject
            let myUrl = URL(string: urlWithParams);
            // Creaste URL Request
            var request = URLRequest(url:myUrl!);
            // Set request HTTP method to GET. It could be POST as well
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request as URLRequest){
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
                        if success == 1
                        {
                            let jsonArray = convertedJsonIntoDict["temp"] as? NSArray
                            for i in 0 ..< jsonArray!.count
                            {
                                let c = jsonArray?.object(at: i) as? NSDictionary
                                var Temp : Array <String> = Array<String>()
                                let line1 = c!["Calibration ID #"] as? Int ?? 0
                                let line2 = c!["MT&E #"] as? String ?? "NIL"
                                let line3 = c!["Customer PO #"] as? String ?? "NIL"
                                let line4 = c!["Calibration Status"] as? String ?? "No Status"
                                let line5 = c!["Calibration PDF Path"] as? String ?? "None"
                                Temp.append(String(line1))
                                Temp.append(line2)
                                Temp.append(line3)
                                Temp.append(line4)
                                Temp.append(line5)
                                self.TableData.append(Temp)
                                print(Temp)
                                //print(self.TableData[i][0])
                            }
                            //self.do_table_refresh();
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
                let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            DispatchQueue.main.async {
                while(locked) {
                    self.wait()
                }
                self.alert.dismiss(animated: false, completion:nil)
                self.tableView.reloadData()
            }
        }
    }
    
    func wait()
    {
        RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 1))
    }
    
    @IBAction func request(_ sender: AnyObject) {
        let oldReqouteTimestamp = defaults.object(forKey: "oldReqouteTimestamp") as? Double ?? 0.0
        if (NSDate().timeIntervalSince1970 - oldReqouteTimestamp) >= (24*60*60) {
            defaults.set(NSDate().timeIntervalSince1970, forKey: "oldReqouteTimestamp")
            defaults.synchronize()
            //Send Mail
            var yes:Bool = false
            let alert = UIAlertController(
                title: "",
                message: "Do you request a Re-quote?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Yes", style: .default) {UIAlertAction in
                let session = SendGrid.Session()
                session.authentication = Authentication.apiKey(SendGridKey)
                let personalization = Personalization(to: [Address(User.loginEmail)], bcc: [Address("scott@graftel.com"),Address("kangmin@graftel.com"),Address("esther@graftel.com"),Address("pdavis@graftel.com")])
                let body:String = "\nThis a confirmation that your quote request has been successfully sent to Graftel, we will respond to you within 24 hours.\n"+"\nThank you for contacting Graftel LLC. Below is the original message.\n"+"\n---------------------------------------------------------------------------------------------------------------------------------\n"+"\nQuote request from "+User.contactPersonName+" ( "+User.loginEmail+" ) \n"+"\nCustomer is requesting a quote for calibration ID: "+self.toPass
                let plainText = Content(contentType: ContentType.plainText, value: body)
                //let htmlText = Content(contentType: ContentType.HTMLText, value: "<h1>Hello World</h1>")
                let email = Email(
                    personalizations: [personalization],
                    from: Address(email: "scott@graftel.com", name: "Graftel APP"),
                    replyTo: Address(User.loginEmail),
                    content: [plainText],
                    subject: "[Graftel APP] Your quote request has been sent to Graftel"
                )
                do {
                    //try SendGrid.Session.sharedInstance.send(email)
                    try session.send(request: email)
                    yes=true
                }
                catch {
                    print(error)
                }
            })
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
        else {
            let alert = UIAlertController(
                title: "",
                message: "Cannot Send a Re-Quote request within 24 hours.",
                preferredStyle: .alert
            )
            self.present(alert, animated: true, completion: nil)
            let time = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        }

        
        
    }
    
    var body:String = ""
    
    func requoteAll(_ sender: UIBarButtonItem) {
        let oldReqouteAllTimestamp = defaults.object(forKey: "oldReqouteAllTimestamp") as? Double ?? 0.0
        if (NSDate().timeIntervalSince1970 - oldReqouteAllTimestamp) >= (24*60*60) {
            defaults.set(NSDate().timeIntervalSince1970, forKey: "oldReqouteAllTimestamp")
            defaults.synchronize()
            var yes:Bool = false
            let alert = UIAlertController(
                title: "",
                message: "Do you want a Re-quote for all Calibration IDs?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Yes", style: .default) {UIAlertAction in
                let session = SendGrid.Session()
                session.authentication = Authentication.apiKey(SendGridKey)
                let personalization = Personalization(to: [Address(User.loginEmail)], bcc: [Address("scott@graftel.com"),Address("kangmin@graftel.com"),Address("esther@graftel.com"),Address("pdavis@graftel.com")])
                let body:String = "\nThis a confirmation that your quote request has been successfully sent to Graftel, we will respond to you within 24 hours.\n"+"\nThank you for contacting Graftel LLC. Below is the original message.\n"+"\n---------------------------------------------------------------------------------------------------------------------------------\n"+"\nQuote request from "+User.contactPersonName+" ( "+User.loginEmail+" ) \n"+"\nCustomer is requesting a quote for calibration ID: "+self.toPass
                let plainText = Content(contentType: ContentType.plainText, value: body)
                let email = Email(
                    personalizations: [personalization],
                    from: Address(email: "scott@graftel.com", name: "Graftel APP"),
                    replyTo: Address(User.loginEmail),
                    content: [plainText],
                    subject: "[Graftel APP] Your quote request has been sent to Graftel"
                )
                do {
                    try session.send(request: email)
                    yes = true
                }
                catch {
                    print(error)
                }
            })
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
        else {
            let alert = UIAlertController(
                title: "",
                message: "Cannot Send a Re-Quote request within 24 hours.",
                preferredStyle: .alert
            )
            self.present(alert, animated: true, completion: nil)
            let time = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableData.count
    }
    
    func do_table_refresh()
    {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            return
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DeviceInfoCell
        let arr:Array<String> = TableData[(indexPath as NSIndexPath).row]
        cell.cali?.text = arr[0]
        cell.mte?.text = arr[1]
        cell.po?.text = arr[2]
        cell.status?.text = arr[3]
        cell.pdf?.addTarget(self, action: #selector(DeviceInfo.View_Report(_:)), for: UIControlEvents.touchUpInside)
        cell.pdf?.tag =  indexPath.row
        return cell
    }
    
    func View_Report(_ sender: UIButton) {
        let pdfviewer = self.storyboard!.instantiateViewController(withIdentifier: "PDF View") as! PDFView
        print(self.TableData[sender.tag][4])
        if self.TableData[sender.tag][4] != "None" {
            print(self.TableData[sender.tag][4])
            let substring1 = self.TableData[sender.tag][4].substring(from: self.TableData[sender.tag][4].index(self.TableData[sender.tag][4].startIndex, offsetBy: 15))
            //print(substring1)
            pdfviewer.bucket = "graftelcalcerts"
            pdfviewer.key = substring1
            print(substring1)
            self.navigationController?.pushViewController(pdfviewer, animated: true)
        }
        else {
            let alert = UIAlertController(title: "Sorry!", message: "The file you are looking is not Available.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
