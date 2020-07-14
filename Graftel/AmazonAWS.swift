//
//  AmazonAWS.swift
//  Graftel
//
//  Created by Graftel on 10/4/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import Foundation
import AWSCore
import AWSS3

class AmazonAWS:UIViewController {
    
    override func viewDidLoad() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .usEast1, identityPoolId: "us-east-1_pr6sKGgh4")
        let configuration = AWSServiceConfiguration(region: .usEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        let transferManager = AWSS3TransferManager.default()
        
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("download")
        //let downloadingFilePath = downloadingFileURL.path
        
        let downloadRequest = AWSS3TransferManagerDownloadRequest.init()
        downloadRequest?.bucket = "grafteldoc";
        downloadRequest?.key = "57542_Alicat_Yucson_AZ.pdf";
        downloadRequest?.downloadingFileURL = downloadingFileURL;
        
        // Download the file.
        transferManager?.download(downloadRequest).continue({ (task) -> AnyObject! in
            if ((task.error) != nil){
                
            }
            if ((task.result) != nil) {
                //let downloadOutput = task.result;
                //File downloaded successfully.
            }
            return nil;
        })
    }
}
