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
    
    init (fromJson json:[String:Any]) {
        var newBeers = Array<Beer>()
        if let jsonBeers = json[K.BeerListJsonName.beers] as? [[String:Any]] {
            for jsonBeer:[String:Any] in jsonBeers {
                let beer=Beer(fromJson:jsonBeer)
                newBeers.append(beer)
            }
        }
        self.beers = newBeers
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
