//
//  TableCell.swift
//  Shorabh
//
//  Created by Shorabh on 7/29/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit

class OrdersCell: UITableViewCell {
    
    @IBOutlet var quote: UILabel!
    @IBOutlet var desc: UILabel!
    @IBOutlet var status: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
        //self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
}
