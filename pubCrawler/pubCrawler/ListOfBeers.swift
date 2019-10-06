//
//  ListOfBeers.swift
//  pubCrawler
//
//  Created by Michael Neilens on 29/09/2019.
//  Copyright © 2019 Michael Neilens. All rights reserved.
//

import Foundation
import MNWebServiceCall

struct ListOfBeers {
    let beers:Array<Beer>
    let location:Location
    init() {
        beers = Array()
        location = Location()
    }
    
    init (fromJson json:[String:Any]) {
        self.location = Location(fromJson: json)
        var newBeers = Array<Beer>()
        if let jsonBeers = json[K.BeerListJsonName.beers] as? [[String:Any]] {
            for jsonBeer:[String:Any] in jsonBeers {
                let beer=Beer(fromJson:jsonBeer, searchOrigin:self.location)
                newBeers.append(beer)
            }
        }
        self.beers = newBeers
    }
    
    struct BeerSection {
        let name:String
        let listOfPubs:Array<PubForBeer>
    }
       
    var uniqueBeerNames:Array<String> {
        let beerNames = beers.map{$0.name}
        var uniqueNames = Array<String>()
        for beerName in beerNames {
            if !uniqueNames.contains(beerName){
                uniqueNames.append(beerName)
            }
        }
        return uniqueNames
    }
    
    func first(_ limit:Int, _ beers:Array<Beer>) -> Array<Beer> {
        if beers.count < limit {return beers}
        let distanceFromOrigins = beers.map{$0.pubForBeer.distanceToOrigin}.sorted()
        let maxDistance = distanceFromOrigins[limit - 1]
        return beers.filter{$0.pubForBeer.distanceToOrigin <= maxDistance}
    }
    
    var beerSections:Array<BeerSection> {
        var beerSections = Array<BeerSection>()
        let firstOneHundredBeers = first(300, beers)
        for name in uniqueBeerNames {
            let sectionPubs = firstOneHundredBeers.filter{$0.name == name}.map{$0.pubForBeer}
                .sorted{(firstPub, secondPub) in firstPub.distanceToOrigin < secondPub.distanceToOrigin}
            if sectionPubs.count > 0 {
                beerSections.append(BeerSection(name: name, listOfPubs: sectionPubs))
            }
        }
        return beerSections
    }
 
}

protocol ListOfBeersCreatorDelegate :WebServiceDelegate {
    func finishedCreating(listOfBeers:ListOfBeers)
}

struct ListOfBeersCreator: WebServiceCallerType {
    
    let delegate:ListOfBeersCreatorDelegate
    let errorDelegate: WebServiceDelegate
    let serviceName = "obtain beers"

    init (withDelegate delegate:ListOfBeersCreatorDelegate) {
        self.delegate = delegate
        self.errorDelegate = delegate
    }
    
    func createList(usingSearchString search:String, location:Location,deg:String, options:[SearchTerm], uId:UId) {
        let paramDict = [K.QueryParm.search:search, K.QueryParm.page:"1", K.QueryParm.lat:String(location.lat), K.QueryParm.lng:String(location.lng), K.QueryParm.uId:uId.text, K.QueryParm.deg:deg]
        let urlPath = K.URL.beerListURL.addParametersToURL(paramDict:paramDict)

        let optionsDict = convertToDictionary(searchOptions: options)
        let urlPathWithOptions = urlPath.addParametersToURL(paramDict: optionsDict)
        
        self.requestList(usingURLString:urlPathWithOptions)
    }
        
    private func requestList(usingURLString urlPath:String) {
        self.call(withDelegate: self, url: urlPath)
    }

    func finishedGetting(json:[String:Any]) {
        
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let listOfBeers = ListOfBeers(fromJson:json)
            self.delegate.finishedCreating(listOfBeers: listOfBeers)
        default:
            self.failedGettingJson(error:JSONError.ConversionFailed, errorText:errorText)
        }
    }
}
