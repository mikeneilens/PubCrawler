//
//  PubNameTableViewCell.swift
//  pubCrawler
//
//  Created by Michael Neilens on 27/02/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit

protocol PubCrawlNameTableViewCellDelegate{
    func nameChanged(name:String)
}

class PubCrawlNameTableViewCell: UITableViewCell, UITextFieldDelegate {

    var delegate:PubCrawlNameTableViewCellDelegate?
    @IBOutlet weak var pubCrawlNameText: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        pubCrawlNameText.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let delegate = delegate {
            delegate.nameChanged(name:textField.text!)
        }
    }

}
