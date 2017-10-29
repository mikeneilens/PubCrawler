//
//  IndexPathExtensions.swift
//  pubCrawler
//
//  Created by Michael Neilens on 12/10/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import Foundation

extension IndexPath {
    var rowAndSection: (Int, Int) {
        return (self.row, self.section)
    }
    
}
