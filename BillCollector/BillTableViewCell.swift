//
//  BillTableViewCell.swift
//  BillCollector
//
//  Created by Christopher Garcia on 5/6/16.
//  Copyright © 2016 Christopher Garcia. All rights reserved.
//

import UIKit

class BillTableViewCell: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet weak var billNameLabel: UILabel!
    @IBOutlet weak var amountDueLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var isEstimateIndicator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
