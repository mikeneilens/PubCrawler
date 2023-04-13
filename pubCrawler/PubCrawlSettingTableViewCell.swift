//
//  PubCrawlSettingTableViewCell.swift
//  pubCrawler
//
//  Created by Michael Neilens on 06/03/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit
protocol PubCrawlSettingTableViewCellDelegate{
    func pubCrawlSettingChanged(settingSwitch:UISwitch)
}

class PubCrawlSettingTableViewCell: UITableViewCell {

    var delegate:PubCrawlSettingTableViewCellDelegate?
    @IBOutlet weak var settingSwitch: UISwitch!
    
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        delegate?.pubCrawlSettingChanged(settingSwitch:sender)
    }
}
