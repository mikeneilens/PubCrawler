//
//  TextTableViewCell.swift
//  pubCrawler
//
//  Created by Michael Neilens on 19/10/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit
class LongAboutTableViewCell: UITableViewCell {
    
    @IBOutlet weak var variableSizeTextLabel: UILabel!
    @IBOutlet weak var showMoreLabel: UILabel!

    func setLabelType(isMultirow:Bool) {
        if isMultirow {
            self.variableSizeTextLabel.numberOfLines = 0
            self.showMoreLabel.text = "show less"
        } else {
            self.variableSizeTextLabel.numberOfLines = 1
            self.showMoreLabel.text = "show more"
        }
    }
}
