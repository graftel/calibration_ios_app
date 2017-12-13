//
//  PDFView.swift
//  Shorabh
//
//  Created by Shorabh on 10/4/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore

class PDFView : UIViewController {
    
    @IBOutlet var webView:UIWebView!
    var bucket:String!
    var key:String!
    
    let alert = UIAlertController(title:nil, message: "Downloading PDF..", preferredStyle: UIAlertControllerStyle.alert)
    
    func showDialog() {
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 20, y: 12, width: 37, height: 37))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        //alert.view.addSubview(loadingIndicator)
        //self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //showDialog()
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .usEast1, identityPoolId: identityPoolId)
        let configuration = AWSServiceConfiguration(region: .usEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        let transferManager = AWSS3TransferManager.default()
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(key)

        let downloadRequest = AWSS3TransferManagerDownloadRequest.init()
        downloadRequest?.bucket = bucket;
        downloadRequest?.key = key;
        downloadRequest?.downloadingFileURL = downloadingFileURL;
        
        if isConnected() == true {
            // Download the file.
            transferManager?.download(downloadRequest).continue({ (task) -> AnyObject! in
                if((task.error) == nil && (task.exception) == nil) {
                    DispatchQueue.main.async {
                        //alert.dismiss(animated: false, completion:nil)
                        self.webView.loadRequest(URLRequest(url: downloadingFileURL))
                    }
                }
                else {
                    DispatchQueue.main.async {
                        let alert2 = UIAlertController(title: "", message: "File not Found", preferredStyle: UIAlertControllerStyle.alert)
                        alert2.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.default) {UIAlertAction in
                            self.navigationController!.popViewController(animated: true)
                        })
                        self.present(alert2, animated: true, completion: nil)
                    }
                }
                return nil;
            })
        }
        else {
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func wait()
    {
        RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 1))
    }
}
