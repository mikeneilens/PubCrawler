//
//  Pub.swift
//  pubCrawler
//
//  Created by Michael Neilens on 15/02/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import Foundation
import MNWebServiceCall

struct PubHeader {
    let name:String
    let town:String
    let distance:String
    let sequence:Int
    let location:Location
    let pubService:String
    let removePubService:String

    var distanceText:String {
        if distance.isEmpty {
            return town
        } else {
            return "\(town), \(distance)"
        }
    }
    var canRemovePub:Bool {return removePubService.isNotEmpty}
    
    init() { self = PubHeader(fromJson:[:])}
    
    init (fromJson json:[String:Any]) {
        self.name         = json[K.PubListJsonName.name]  as? String ?? ""
        self.town         = json[K.PubListJsonName.town]     as? String ?? ""
        self.distance     = json[K.PubListJsonName.distance] as? String ?? ""
        self.location     = Location(fromJson:json)
        self.sequence     = json[K.PubListJsonName.sequence] as? Int    ?? 0
        self.pubService   = json[K.PubListJsonName.pubService]   as? String ?? ""
        self.removePubService   = json[K.PubListJsonName.removePubService]   as? String ?? ""
    }
}

struct Pub {
    let pubHeader:PubHeader
    let address:String
    let photoURL:String
    let telephone:String
    let openingTimes:String
    let mealTimes:String
    let owner:String
    let about:String
    let beer:[String]
    let guest:[String]
    let feature:[String]
    let facility:[String]
    let changeLikedService:String
    let changeVisitedService:String
    let hygieneRatingService:String
    let pubsNearByService:String
    let visited:Bool
    let liked:Bool
    let createPubCrawlService:String
    let listOfPubCrawls:ListOfPubCrawls
    let listOfOtherPubCrawls:ListOfPubCrawls
    let nextPubService:String
    
    var canCreatePubCrawl:Bool {return createPubCrawlService.isNotEmpty}
    var canChangeLiked:Bool {return changeLikedService.isNotEmpty}
    var canChangeVisisted:Bool {return changeVisitedService.isNotEmpty}
    var pubsNearByIsAvailable:Bool {return pubsNearByService.isNotEmpty}
    
    init (fromJson json:[String:Any] ) {
        self.pubHeader      = PubHeader(fromJson: json)
        self.address        = json[K.PubJsonName.address]       as? String ?? ""
        self.photoURL       = json[K.PubJsonName.photoURL]      as? String ?? ""
        self.telephone      = json[K.PubJsonName.telephone]     as? String ?? ""
        self.openingTimes   = json[K.PubJsonName.openingTimes]  as? String ?? ""
        self.mealTimes      = json[K.PubJsonName.mealTimes]     as? String ?? ""
        self.owner          = json[K.PubJsonName.owner]         as? String ?? ""
        self.about          = json[K.PubJsonName.about]         as? String ?? ""
        let guestBeerDesc   = json[K.PubJsonName.guestBeerDesc] as? String ?? ""
        if (guestBeerDesc != "") {
            var tempGuest   = [guestBeerDesc.condensedWhitespace]
            tempGuest      += json.getValues(forKey: K.PubJsonName.guestBeers,   withDefault:"unknown")
            self.guest      = tempGuest
        } else {
            self.guest      = json.getValues(forKey: K.PubJsonName.guestBeers,   withDefault:"unknown")
        }
        
        self.beer     = json.getValues(forKey: K.PubJsonName.regularBeers, withDefault:"unknown")
        self.feature  = json.getValues(forKey: K.PubJsonName.features,     withDefault:"unknown")
        self.facility = json.getValues(forKey: K.PubJsonName.facilities,   withDefault:"unknown")
        self.visited = json.getBoolValue(forKey: K.PubJsonName.visited, trueIfValueIs: "y")
        self.liked   = json.getBoolValue(forKey: K.PubJsonName.liked,   trueIfValueIs: "y")
        
        self.createPubCrawlService = json[K.PubJsonName.createPubCrawlService] as? String ?? ""
        self.changeVisitedService = json[K.PubJsonName.changeVisitedService] as? String ?? ""
        self.changeLikedService = json[K.PubJsonName.changeLikedService] as? String ?? ""
        self.hygieneRatingService = json[K.PubJsonName.hygieneRatingService] as? String ?? ""
        self.pubsNearByService = json[K.PubJsonName.pubsNearbyService] as? String ?? ""
        self.nextPubService = json[K.PubJsonName.nextPubService] as? String ?? ""
        
        let otherPubCrawlsJson = json.getValues(forKey: K.PubCrawlJsonName.otherPubCrawl, withDefault:[String:Any]())
        self.listOfOtherPubCrawls =  getPubCrawls(fromJson: otherPubCrawlsJson)
        let pubCrawlsJson = json.getValues(forKey: K.PubCrawlJsonName.pubCrawl, withDefault:[String:Any]())
        self.listOfPubCrawls = getPubCrawls(fromJson: pubCrawlsJson)
    }
    init() { //default initialise
        self = Pub(fromJson: [:])
    }
        
}

func getPubCrawls(fromJson pubCrawlsJson:[[String:Any]]) -> ListOfPubCrawls {
    var pubCrawls = [PubCrawl]()
    for pubCrawlJson in pubCrawlsJson{
        let pubCrawl=PubCrawl(fromJson: pubCrawlJson)
        pubCrawls.append(pubCrawl)
    }
    return ListOfPubCrawls(from:pubCrawls)
}

// PubCreator is used to make a new Pub
protocol PubCreatorDelegate :CallWebServiceType {
    func finishedCreating(newPub pub:Pub)
}

struct PubCreator: JSONResponseDelegate {
    let delegate:PubCreatorDelegate
    let pubHeader:PubHeader
    
    init (withDelegate delegate:PubCreatorDelegate, forPubHeader pubHeader:PubHeader) {
        self.delegate = delegate
        self.pubHeader = pubHeader
    }
    
    func createPub() {
        let urlPath = self.pubHeader.pubService
        WebServieCaller().call(withDelegate: self, url: urlPath)
    }
    func createNext(pub:Pub) {
        let urlPath = pub.nextPubService
        WebServieCaller().call(withDelegate: self, url: urlPath)
    }
    func finishedGetting(json:[String:Any]) {
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let pub = Pub(fromJson: json)
            self.delegate.finishedCreating(newPub:pub)
        default:
            self.delegate.requestFailed(error:JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not retrieve pub")
        }
    }
    func failedGettingJson(error:Error) {
        self.delegate.requestFailed(error:JSONError.ConversionFailed, errorText:"Error connecting to internet", errorTitle:"Could not retrieve pub")
    }
    
}

protocol UpdatePubDelegate:CallWebServiceType  {
    func finishedUpdating(pub:Pub)
}

struct PubUpdater:JSONResponseDelegate {

    let delegate:UpdatePubDelegate
    let pub:Pub
    
    init(pub:Pub, withDelegate delegate:UpdatePubDelegate) {
        self.pub = pub
        self.delegate = delegate
    }
    
    func add(pubCrawlAtNdx ndx:Int ) {
        let urlPath = self.pub.listOfOtherPubCrawls.pubCrawls[ndx].addPubCrawlService
        WebServieCaller().call(withDelegate: self, url: urlPath)
    }
    
    func remove(pubCrawl:PubCrawl) {
        let urlPath = pubCrawl.removePubCrawlService
        WebServieCaller().call(withDelegate: self, url: urlPath)
    }
    
    func updateVisit() {
        let urlPath = self.pub.changeVisitedService
        WebServieCaller().call(withDelegate: self, url: urlPath)
    }
    
    func updateLiked() {
        let urlPath = pub.changeLikedService
        WebServieCaller().call(withDelegate: self, url: urlPath)
    }
    
    func finishedGetting(json:[String:Any]) {

        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let pub = Pub(fromJson: json)
            delegate.finishedUpdating(pub: pub)
        default:
            delegate.requestFailed(error: JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not update pub")
        }
    }
    
    func failedGettingJson(error:Error) {
        delegate.requestFailed(error: JSONError.ConversionFailed, errorText:"Error connecting to internet", errorTitle:"Could not update pub")
    }

}
