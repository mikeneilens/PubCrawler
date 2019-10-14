//
//  BeerTableViewCell.swift
//  pubCrawler
//
//  Created by Michael Neilens on 13/10/2019.
//  Copyright © 2019 Michael Neilens. All rights reserved.
//

import UIKit

class BeerTableViewCell: UITableViewCell {

    @IBOutlet weak var selector: UIImageView!
    
    let rightImage = UIImage(named: "right-circle-240")
    let downImage = UIImage(named: "down-circle-240")
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setSelector(_ isSelected:Bool) {
        if isSelected {selector.image = downImage}
        else {selector.image = rightImage}
    }
}
