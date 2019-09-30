//
//  Beer.swift
//  pubCrawler
//
//  Created by Michael Neilens on 29/09/2019.
//  Copyright © 2019 Michael Neilens. All rights reserved.
//

import Foundation

struct Beer {
    let name:String
    let pubName:String
    let pubService:String
    let isRegular:Bool
    
    init (fromJson json:[String:Any] ) {
        self.name       = json[K.BeerJsonName.name]       as? String ?? ""
        self.pubName    = json[K.BeerJsonName.pubName]    as? String ?? ""
        self.pubService = json[K.BeerJsonName.pubService] as? String ?? ""
        self.isRegular  = json.getBoolValue(forKey: K.BeerJsonName.isRegular, trueIfValueIs: "yes")
    }
}
