//
//  Beer.swift
//  pubCrawler
//
//  Created by Michael Neilens on 29/09/2019.
//  Copyright © 2019 Michael Neilens. All rights reserved.
//

import Foundation

struct PubForBeer {
    let pubName:String
    let pubService:String
    let isRegular:Bool
    let location:Location
    let distanceToOrigin:Double
    var distanceText:String {
        let distanceRounded = round( distanceToOrigin * 10 ) / 10
        return "\(distanceRounded) miles "
    }
}

struct Beer {
    let name:String
    let pubForBeer:PubForBeer
    
    init (fromJson json:[String:Any], searchOrigin:Location ) {
        self.name       = json[K.BeerJsonName.name]       as? String ?? ""
        let pubName    = json[K.BeerJsonName.pubName]    as? String ?? ""
        let pubService = json[K.BeerJsonName.pubService] as? String ?? ""
        let isRegular  = json.getBoolValue(forKey: K.BeerJsonName.isRegular, trueIfValueIs: "yes")
        let location = Location(fromJson: json)
        let distanceToOrigin = distanceBetween(locationA: searchOrigin, locationB: location)
        
        self.pubForBeer = PubForBeer(pubName: pubName, pubService: pubService, isRegular: isRegular,location:location, distanceToOrigin:distanceToOrigin)
    }
}
