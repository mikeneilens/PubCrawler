//
//  OptionsTableViewCell.swift
//  pubCrawler
//
//  Created by Michael Neilens on 02/03/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit

protocol SettingsSwitchDelegate {
    func settingsSwitchChanged(optionSwitch:UISwitch, label:String)
}

class SettingsTableViewCell: UITableViewCell {

    var delegate:SettingsSwitchDelegate?
    var label=""
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var optionSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        delegate?.settingsSwitchChanged(optionSwitch:sender, label:self.label)
    }
}
