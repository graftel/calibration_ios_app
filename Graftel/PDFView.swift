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
    
    let alert = UIAlertController(title:nil, message: "Downloading PDF..", preferredStyle: UIAlertController.Style.alert)
    
    func showDialog() {
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 20, y: 12, width: 37, height: 37))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        //alert.view.addSubview(loadingIndicator)
        //self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //showDialog()
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: identityPoolId)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        let transferUtility = AWSS3TransferUtility.default()
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(key)

        let downloadRequest = AWSS3TransferManagerDownloadRequest.init()
        downloadRequest?.bucket = bucket;
        downloadRequest?.key = key;
        downloadRequest?.downloadingFileURL = downloadingFileURL;
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in DispatchQueue.main.async(execute: {
            // Do something e.g. Update a progress bar.
        })
        }
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        completionHandler = { (task, URL, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Alert a user for transfer completion.
                // On failed downloads, `error` contains the error object.
                if((error) == nil) {
                    DispatchQueue.main.async {
                        //alert.dismiss(animated: false, completion:nil)
                        self.webView.loadRequest(URLRequest(url: downloadingFileURL))
                    }
                }
                else {
                    DispatchQueue.main.async {
                        let alert2 = UIAlertController(title: "", message: "File not Found", preferredStyle: UIAlertController.Style.alert)
                        alert2.addAction(UIAlertAction(title: "OK!", style: UIAlertAction.Style.default) {UIAlertAction in
                            self.navigationController!.popViewController(animated: true)
                        })
                        self.present(alert2, animated: true, completion: nil)
                    }
                }
            })
        }
        
        if isConnected() == true {
            // Download the file.
            
            
            transferUtility.download(to: downloadingFileURL, bucket: bucket, key: key, expression: expression, completionHandler: completionHandler
                ).continueWith {
                    (task) -> AnyObject? in if let error = task.error {
                        print("Error: \(error.localizedDescription)")
                    }
                    
                    if let _ = task.result {
                        // Do something with downloadTask.
                        
                    }
                    return nil;
            }
        }
        else {
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK!", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }	
    
    func wait()
    {
        RunLoop.current.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 1))
    }
}
