//
//  QuoteDetailCell.swift
//  Shorabh
//
//  Created by Shorabh on 8/1/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit

class QuoteDetailCell: UITableViewCell {
    
    
    @IBOutlet var cali: UILabel!
    @IBOutlet var po: UILabel!
    @IBOutlet var status: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }


}
