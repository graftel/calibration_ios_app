//
//  SearchResults.swift
//  Shorabh
//
//  Created by Shorabh on 9/27/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import Foundation
class SearchResults: UITableViewController {
    
    var from:String!
    var to:String!
    var PO:String!
    var Serial:String!
    var MTE:String!
    var TableData:Array< Array < String >> = Array < Array < String >>()
    
    //MARK:Properties
    override func viewDidLoad() {
        super.viewDidLoad()
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
            // Define server side script URL
            locked = true
            let scriptUrl = "http://www.graftel.com/appport/webSearchCalInfoProd.php"
            // Add one parameter
            var urlWithParams:String
            urlWithParams = scriptUrl + "?user=\(User.UID)"
            let dateformat = DateFormatter()
            dateformat.dateFormat = "MM-dd-yyyy"
            if self.from != self.to {
                urlWithParams.append("&start=\(self.from!)&end=\(self.to!)")
            }
            if self.PO.isEmpty != true {
                urlWithParams.append("&cpo=\(self.PO!)")
            }
            if self.Serial.isEmpty != true {
                urlWithParams.append("&serial=\(self.Serial!)")
            }
            if self.MTE.isEmpty != true {
                urlWithParams.append("&mte=\(self.MTE!)")
            }
            print(urlWithParams)
            // Create NSURL Ibject
            let myUrl = URL(string: urlWithParams)
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
                            let jsonArray = convertedJsonIntoDict["temp"] as? NSArray
                            for i in 0 ..< jsonArray!.count {
                                let c = jsonArray?.object(at: i) as? NSDictionary
                                var Temp : Array <String> = Array<String>()
                                let line1 = c!["Calibration ID #"] as? Int
                                let date = c!["Date"] as? NSDictionary
                                let line2 = date!["date"] as! String
                                let line3 = c!["Calibration Status"] as? String
                                Temp.append(String(describing: line1!))
                                Temp.append(line2.substring(to: line2.index(line2.startIndex,offsetBy:10)))
                                if line3 != nil {
                                    Temp.append(line3!)
                                }
                                else {
                                    Temp.append("No Status")
                                }
                                self.TableData.append(Temp)
                            }
                        }
                        if success == -1 {
                            let alert = UIAlertController(title: "", message: "Email Address already Exist!", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! QuoteDetailCell
        let arr:Array<String> = TableData[(indexPath as NSIndexPath).row]
        cell.cali?.text = "Calibration ID#: "+arr[0]
        cell.po?.text = "Date: "+arr[1]
        cell.status?.text = arr[2]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let calID = TableData[(indexPath as NSIndexPath).row][0]
        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "Device Info") as! DeviceInfo
        secondViewController.toPass = calID
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }

}
