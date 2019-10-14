//
//  ListOfBeerOrPub.swift
//  pubCrawler
//
//  Created by Michael Neilens on 14/10/2019.
//  Copyright © 2019 Michael Neilens. All rights reserved.
//

import Foundation

enum BeerOrPub {
    case Beer(String)
    case Pub(PubForBeer)
}

func createListOfBeerOrPub(listOfBeers:ListOfBeers, beerSelected:Dictionary<String, Bool>)->Array<BeerOrPub>{
    var beerOrPubs=Array<BeerOrPub>()
    
    var currentBeer = ""
    var noOfBeers = -1
    for beer in listOfBeers.beers {
        if (beer.name != currentBeer)  {
            noOfBeers += 1
            currentBeer = beer.name
            beerOrPubs.append(BeerOrPub.Beer(currentBeer))
        }
        if beerSelected.isTrue(for: currentBeer) {
            beerOrPubs.append(BeerOrPub.Pub(beer.pubForBeer))
        }
    }
    return beerOrPubs
}
