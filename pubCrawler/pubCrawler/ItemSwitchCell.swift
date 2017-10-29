//
//  PubItemSwitchCell.swift
//  pubCrawler
//
//  Created by Michael Neilens on 13/07/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit

protocol ItemSwitchCellDelegate{
    func buttonPressed(ndx:Int, switchOn:Bool)
}

class ItemSwitchCell: UITableViewCell {

    var delegate:ItemSwitchCellDelegate?
    var switchOn=false
    var ndx=0
    var trueText = "Yes"
    var falseText = "No"
    
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var switchLabel: UILabel!
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        self.switchOn = !self.switchOn
        self.setLabel()
        if let delegate = self.delegate {
            delegate.buttonPressed(ndx:ndx, switchOn: switchOn)
        }
    }
    
    func initialValues(text:String, isOn:Bool, trueText:String, falseText:String, ndx:Int, delegate:ItemSwitchCellDelegate) {
        self.switchLabel.text = text
        self.switchOn = isOn
        self.ndx = ndx
        self.trueText = trueText
        self.falseText = falseText
        self.delegate = delegate
        self.setLabel()
    }
    
    func setLabel() {
        if self.switchOn {
            self.switchButton.setTitle(self.trueText, for: UIControlState())
        } else {
            self.switchButton.setTitle(self.falseText, for: UIControlState())
        }
        
    }
}
