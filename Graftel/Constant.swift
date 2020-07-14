//
//  Constant.swift
//  Shorabh
//
//  Created by Shorabh on 10/4/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import Foundation

let identityPoolId = "us-east-1:d4f153ee-c628-4497-974b-af7d5be33054"

let SendGridKey = "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"

let defaults = UserDefaults.standard

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

func isConnected() -> Bool {
    let r = Reachability.forInternetConnection()
    let networkStatus = r?.currentReachabilityStatus()
    if networkStatus != NotReachable {
        return true
    }
    else {
        return false
    }
}
