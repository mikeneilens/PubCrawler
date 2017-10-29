//
//  AddressTableViewCell.swift
//  pubCrawler
//
//  Created by Michael Neilens on 21/10/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit
class AddressTableViewCell: UITableViewCell {
    
    @IBOutlet weak var variableSizeTextLabel: UILabel!
    
    func setLabelType(isMultirow:Bool) {
        if isMultirow {
            self.variableSizeTextLabel.numberOfLines = 0
        } else {
            self.variableSizeTextLabel.numberOfLines = 1
        }
    }
}
