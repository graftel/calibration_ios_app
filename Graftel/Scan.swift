//
//  Scan.swift
//  Shorabh
//
//  Created by Shorabh on 8/19/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit
import AVFoundation
//import QRCodeReader

class Scan: UIViewController {
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var Scroller: UIScrollView!
    //@IBOutlet weak var showCancelButtonSwitch: UISwitch!
    var final:String = ""
    
    override func viewDidLoad() {
//        if self.revealViewController() != nil {
//            menuButton.target = self.revealViewController()
//            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
//            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
//        }
//        Scroller.isScrollEnabled = true
//        Scroller.contentSize = CGSize(width: 300, height: 580)
    }
    
    @IBAction func scanAction(_ sender: AnyObject) {
//        if QRCodeReader.supportsMetadataObjectTypes() {
//            let reader = createReader()
//            reader.modalPresentationStyle = .formSheet
//            reader.delegate               = self
//            reader.completionBlock        = { (result: QRCodeReaderResult?) in
//                if let result = result {
//                    print("Completion with result: \(result.value) of type \(result.metadataType)")
//                }
//            }
//            present(reader, animated: true, completion: nil)
//        }
//        else {
//            let alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//            present(alert, animated: true, completion: nil)
//        }
    }
//
//    // MARK: - QRCodeReader Delegate Methods
//
//    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
//        if(result.value.hasPrefix("GT:")) {
//        final += result.value.substring(with: result.value.index(result.value.startIndex, offsetBy: 3)..<result.value.index(result.value.startIndex, offsetBy: 8))+","
//        }
//        if(result.value.hasPrefix("GTPACK:")) {
//            let qid = result.value.substring(with: result.value.index(result.value.startIndex, offsetBy: 11)..<result.value.index(result.value.startIndex, offsetBy: 15))
//            var line:String = ""
//            let scriptUrl = "http://www.graftel.com/appport/webGetCalInfoProd.php"
//            let urlWithParams = scriptUrl + "?quoteId=\(qid)"
//            let myUrl = URL(string: urlWithParams);
//            var request = URLRequest(url:myUrl!);
//            request.httpMethod = "GET"
//            let task = URLSession.shared.dataTask(with: request as URLRequest) {
//                data, response, error in
//                if error != nil
//                {
//                    print("error=\(error)")
//                    return
//                }
//                do {
//                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
//                        let success  = convertedJsonIntoDict["success"] as? Int
//                        if success == 1
//                        {
//                            let jsonArray = convertedJsonIntoDict["temp"] as? NSArray
//                            for i in 0 ..< jsonArray!.count
//                            {
//                                let c = jsonArray?.object(at: i) as? NSDictionary
//                                //print(c!["Calibration ID #"] as? Int)
//                                line += String(c!["Calibration ID #"] as! Int)
//                                //line += ","
//                            }
//                        }
//                    }
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//            }
//            task.resume()
//            sleep(2)
//            var temp = line.components(separatedBy: ",")
//            for i in 0 ..< temp.count
//            {
//                if(!final.contains(temp[i])) {
//                    final += temp[i]+","
//                }
//            }
//        }
//        self.dismiss(animated: true) { [weak self] in
//            let alert = UIAlertController(
//                title: "",
//                message: self!.final,
//                preferredStyle: .alert
//            )
//            alert.addAction(UIAlertAction(title: "OK", style: .default) {UIAlertAction in
//
//                let secondViewController = self!.storyboard!.instantiateViewController(withIdentifier: "Device Info") as! DeviceInfo
//                secondViewController.toPass = self!.final
//                self!.navigationController?.pushViewController(secondViewController, animated: true)
//                })
//            alert.addAction(UIAlertAction(title: "Continue", style: .default){ UIAlertAction in
//                if QRCodeReader.supportsMetadataObjectTypes() {
//                    let reader = self!.createReader()
//                    reader.modalPresentationStyle = .formSheet
//                    reader.delegate               = self
//                    reader.completionBlock        = { (result: QRCodeReaderResult?) in
//                        if let result = result {
//                            print("Completion with result: \(result.value) of type \(result.metadataType)")
//                        }
//                    }
//                    self!.present(reader, animated: true, completion: nil)
//                }
//                else {
//                    let alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
//                    //alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
//                    self!.present(alert, animated: true, completion: nil)
//                }
//                })
//            self!.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func readerDidCancel(_ reader: QRCodeReaderViewController) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    fileprivate func createReader() -> QRCodeReaderViewController {
//        let builder = QRCodeViewControllerBuilder { builder in
//            builder.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
//            builder.showTorchButton = true
//            builder.showCancelButton = true
//        }
//        return QRCodeReaderViewController(builder: builder)
//    }
}

