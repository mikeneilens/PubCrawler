//
//  ListOfBeerOrPub.swift
//  pubCrawler
//
//  Created by Michael Neilens on 14/10/2019.
//  Copyright © 2019 Michael Neilens. All rights reserved.
//

import Foundation

enum BeerOrPub {
    case Beer(String, Int)
    case Pub(PubForBeer)
}

func createListOfBeerOrPub(listOfBeers:ListOfBeers, beerSelected:Array<Bool>)->Array<BeerOrPub>{
    var beerOrPubs=Array<BeerOrPub>()
    
    var currentBeer = ""
    var noOfBeers = -1
    for beer in listOfBeers.beers {
        if (beer.name != currentBeer)  {
            noOfBeers += 1
            currentBeer = beer.name
            beerOrPubs.append(BeerOrPub.Beer(currentBeer, noOfBeers))
        }
        if beerSelected.count > 0 && beerSelected[noOfBeers] {
            beerOrPubs.append(BeerOrPub.Pub(beer.pubForBeer))
        }
    }
    return beerOrPubs
}

extension Array where Element == BeerOrPub  {
    var noOfBeers:Int {
        let maxBeerNdx:Int = self.compactMap{(beerOrPub:BeerOrPub) in
            if case .Beer(_, let beerNdx) = beerOrPub { return beerNdx } else {return nil}}
            .last ?? -1
        return maxBeerNdx + 1
    }
    func beerNdx(forRow row:Int) -> Int? {
        if case .Beer(_, let beerNdx) = self[row] {
            return beerNdx
        } else {
            return nil
        }
    }
}
