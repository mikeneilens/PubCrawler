//
//  TableViewCellExtension.swift
//  pubCrawler
//
//  Created by Michael Neilens on 12/07/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func showDisclosureIndicator () {
        self.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        self.selectionStyle = .default
    }
    func hideDisclosureIndicator () {
        self.accessoryType = UITableViewCellAccessoryType.none
        self.selectionStyle = .none
    }
}
