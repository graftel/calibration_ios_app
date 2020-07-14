//
//  QuoteDetail.swift
//  Shorabh
//
//  Created by Shorabh on 8/1/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3

class QuoteDetail: UITableViewController {
    
    var calID:String!
    var toPass:String!
    var cal_TableData:Array< Array < String >> = Array < Array < String >>()
    var report_TableData:Array< Array < String >> = Array < Array < String >>()
    let alert = UIAlertController(title:nil, message: "Loading.. Please wait", preferredStyle: UIAlertController.Style.alert)
    
    func showDialog() {
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 15, y: 12, width: 37, height: 37))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:Properties
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        cal_TableData.removeAll()
        report_TableData.removeAll()
        showDialog()
        var cal_locked:Bool = false
        var report_locked:Bool = false
        DispatchQueue.global().async {
        //DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            cal_locked = true
            // Define server side script URL
            let cal_Url = "http://www.graftel.com/appport/webGetCalInfoProd.php"
            // Add one parameter
            let cal_urlWithParams = cal_Url + "?quoteId=\(self.toPass!)"
            // Create NSURL Ibject
            let cal_myUrl = URL(string: cal_urlWithParams)
            // Creaste URL Request
            var cal_request = URLRequest(url:cal_myUrl!)
            // Set request HTTP method to GET. It could be POST as well
            cal_request.httpMethod = "GET"
            let cal_task = URLSession.shared.dataTask(with: cal_request as URLRequest) {
                data, response, error in
                // Check for error
                if error != nil
                {
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
                                let line1 = c!["Calibration ID #"] as? Int
                                let line2 = c!["Customer PO #"] as? String
                                let line3 = c!["Calibration Status"] as? String
                                Temp.append(String(line1!))
                                Temp.append(line2!)
                                Temp.append(line3!)
                                self.cal_TableData.append(Temp)
                            }
                            //self.do_table_refresh();
                        }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                cal_locked = false
            }
            
            report_locked = true
            // Define server side script URL
            let report_scriptUrl = "http://www.graftel.com/appport/webGetDocPathProd.php"
            // Add one parameter
            let report_urlWithParams = report_scriptUrl + "?quoteId=\(self.toPass!)"
            // Create NSURL Ibject
            let report_myUrl = URL(string: report_urlWithParams)
            // Creaste URL Request
            var report_request = URLRequest(url:report_myUrl!)
            // Set request HTTP method to GET. It could be POST as well
            report_request.httpMethod = "GET"
            let report_task = URLSession.shared.dataTask(with: report_request as URLRequest) {
                data, response, error in
                // Check for error
                if error != nil
                {
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
                                let line1 = c!["Document Name"] as? String
                                let line2 = c!["Document Path"] as? String
                                Temp.append(line1!)
                                Temp.append(line2!)
                                self.report_TableData.append(Temp)
                            }
                            //self.do_table_refresh();
                        }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                report_locked = false
            }
            if isConnected() == true {
                cal_task.resume()
                report_task.resume()
            }
            else {
                let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK!", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        DispatchQueue.main.async {
            while(cal_locked || report_locked) {
                self.wait()
            }
            self.alert.dismiss(animated: false, completion:nil)
            self.tableView.reloadData()
            //print(self.report_TableData)
        }
    }
    
    func wait()
    {
        RunLoop.current.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 1))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return cal_TableData.count
        }
        else {
            return report_TableData.count
        }
    }
    
    /*func do_table_refresh()
    {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            return
        })
    }*/
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Calibrations"
        }
        else {
            return "Reports"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! QuoteDetailCell
            let arr:Array<String> = cal_TableData[(indexPath as NSIndexPath).row]
            cell.cali?.text = "Calibration ID: "+arr[0]
            cell.po?.text = "Customer PO: "+arr[1]
            cell.status?.text = arr[2]
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellR", for: indexPath) as! ReportCell
            let arr:Array<String> = report_TableData[(indexPath as NSIndexPath).row]
            cell.label?.text = arr[0]
            cell.button?.addTarget(self, action: #selector(QuoteDetail.View_Report(_:)), for: UIControl.Event.touchUpInside)
            cell.button?.tag =  indexPath.row
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
        calID = cal_TableData[(indexPath as NSIndexPath).row][0]
        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "Device Info") as! DeviceInfo
        secondViewController.toPass = calID
        self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
    
    @objc func View_Report(_ sender: UIButton) {
        let pdfviewer = self.storyboard!.instantiateViewController(withIdentifier: "PDF View") as! PDFView
        if sender.tag == 0 {
            //let index1 = self.report_TableData[0][1].index(self.report_TableData[0][1].startIndex, offsetBy: 20)
            let substring1 = self.report_TableData[0][1].substring(from: self.report_TableData[0][1].index(self.report_TableData[0][1].startIndex, offsetBy: 20))
            pdfviewer.bucket = "graftelinspectionreports"
            pdfviewer.key = substring1
        }
        else {
            //let index2 = self.report_TableData[1][1].index(self.report_TableData[1][1].startIndex, offsetBy: 17)
            let substring2 = self.report_TableData[1][1].substring(from: self.report_TableData[1][1].index(self.report_TableData[1][1].startIndex, offsetBy: 18))
            pdfviewer.bucket = "graftelshippingreport"
            pdfviewer.key = substring2
        }
        self.navigationController?.pushViewController(pdfviewer, animated: true)

    }
}
