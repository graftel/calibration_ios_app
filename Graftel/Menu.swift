//
//  Menu.swift
//  Shorabh
//
//  Created by Shorabh on 10/4/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import Foundation

class Menu: UITableViewController {
    
    @IBOutlet var Header: UILabel!
    
    //MARK:Properties
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Header?.text = "    Welcome " + User.contactPersonName + "!"
        
    }
}
