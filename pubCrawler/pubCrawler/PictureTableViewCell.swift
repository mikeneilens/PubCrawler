//
//  PictureCellTableViewCell.swift
//  pubCrawler
//
//  Created by Michael Neilens on 03/03/2017.
//  Copyright © 2017 Michael Neilens. All rights reserved.
//

import UIKit

class PictureTableViewCell: UITableViewCell {

    @IBOutlet weak var pictureLabel: UILabel!
    @IBOutlet weak var pictureImage: PubImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
