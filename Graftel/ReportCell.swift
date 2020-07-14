//
//  ReportCell.swift
//  Shorabh
//
//  Created by Shorabh on 9/29/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit

class ReportCell: UITableViewCell {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var button: UIButton!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    
}
