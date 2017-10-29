//
//  SearchBarExtension.swift
//  pubCrawler
//
//  Created by Michael Neilens on 01/10/2017.
//  Copyright © 2017 Michael Neilens. All rights reserved.
//

import UIKit

extension UISearchBar {
    func setShortPlaceholder(using text:String)  {
        if self.frame.width <= 320 {
            self.placeholder = text
        }
    }
}
