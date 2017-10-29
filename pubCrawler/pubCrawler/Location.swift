//
//  Location.swift
//  pubCrawler
//
//  Created by Michael Neilens on 13/11/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import Foundation
import CoreLocation

struct Location {
    let lng:Double
    let lat:Double
    var isEmpty:Bool {
        if lng==0.0 && lat==0.0 {
            return true
        } else {
            return false
        }
    }
    var isOutsideUK:Bool {
        if ((self.lat < K.minLat ) || (self.lat > K.maxLat) || (self.lng < K.minLng) || (self.lng > K.maxLng) ) {
            return true
        } else {
            return false
        }
    }
    init(fromJson json:[String:Any]) {
        self.lat = json[K.PubListJsonName.lat]     as? Double ?? 0.0
        self.lng = json[K.PubListJsonName.lng]     as? Double ?? 0.0
    }
    init(fromCoordinate locValue:CLLocationCoordinate2D) {
        self.lat = locValue.latitude
        self.lng = locValue.longitude
    }
    init() { //default init
        self = Location(fromJson:[:])
    }
    
    static func == (lhs:Location, rhs:Location) -> Bool {
        if (lhs.lat == rhs.lat) && (lhs.lng == rhs.lng) {
            return true
        } else {
            return false
        }
    }
}
func distanceBetween(locationA:Location, locationB:Location) -> Double
{
    let a = CLLocation(latitude: locationA.lat, longitude: locationA.lng)
    let b = CLLocation(latitude: locationB.lat, longitude: locationB.lng)
    let d = a.distance(from: b) / 1609.34
    return d
}
