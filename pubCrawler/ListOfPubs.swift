//
//  ListOfPubs.swift
//  pubCrawler
//
//  Created by Michael Neilens on 15/02/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import Foundation
import MNWebServiceCall

struct ListOfPubs {
    let pubHeaders:[PubHeader]
    let morePubsService:String
    var morePubsAvailable:Bool { return morePubsService.isNotEmpty  }

    init () {
        self.pubHeaders = [PubHeader]()
        self.morePubsService = ""
    }
    init (fromJson json:[String:Any]) {
        self=ListOfPubs(fromJson:json, existingList:ListOfPubs())
    }

    init (fromJson json:[String:Any], existingList:ListOfPubs) {
        self.morePubsService = json[K.PubListJsonName.morePubsService] as? String ?? ""
        var newPubHeaders = existingList.pubHeaders
        if let jsonPubs = json[K.PubListJsonName.pubs] as? [[String:Any]] {
            for jsonPub:[String:Any] in jsonPubs {
                let pubHeader=PubHeader(fromJson:jsonPub);
                newPubHeaders.append(pubHeader)
            }
        }
        self.pubHeaders = newPubHeaders
    }
    init (using newPubHeaders:[PubHeader], existingList:ListOfPubs) {
        self.morePubsService = existingList.morePubsService
        self.pubHeaders = newPubHeaders
    }

    func distanceToPreveiousPubText(atIndex indx:Int)->String {
        if indx > 0 {
            let pubHeaderA = self.pubHeaders[indx]
            let pubHeaderB = self.pubHeaders[indx - 1]
            let distance = distanceBetween(locationA:pubHeaderA.location, locationB: pubHeaderB.location)
            let distanceRounded = round( distance * 10 ) / 10
            return "\(distanceRounded) miles from " + pubHeaderB.name
        } else {
            return ""
        }
    }
    
    func remove(pubHeader:PubHeader) ->ListOfPubs {
        var newPubHeaders=[PubHeader]()
        for existingPubHeader in self.pubHeaders {
            if pubHeader.name != existingPubHeader.name  {
                newPubHeaders.append(existingPubHeader)
            }
        }
        return ListOfPubs(using:newPubHeaders,existingList:self)
    }
    
    func movePubHeader(from:Int, to:Int) -> ListOfPubs {
        if to != from  {
            var newPubHeaders = [PubHeader]()
            let movedPub = self.pubHeaders[from]
            
            for i in (0..<self.pubHeaders.count).reversed()  {
                if ( i == to) && (to > from) {
                    newPubHeaders.insert(movedPub, at: 0)
                }
                if  i != from {
                    let oldPub = pubHeaders[i]
                    newPubHeaders.insert(oldPub, at: 0)
                }
                if ( i == to) && (to < from) {
                    newPubHeaders.insert(movedPub, at: 0)
                }
            }
            return ListOfPubs(using:newPubHeaders,existingList:self)
        } else {
            return self
        }
    }
    
    func reorder() -> ListOfPubs {
        //this attempts to put pubs in distance order.
        //Starting at the first pub in the list, it finds the nearest pub and adds that to the new list and removes it from the old list.
        //It repeats this for the pub it has added to the list until there are no pubs left in the old list.
        //There's probably a funky recursive way to do this better.
        var newPubHeaders = [PubHeader]()
        newPubHeaders.append(self.pubHeaders[0])
        var oldPubHeaders = self.pubHeaders
        oldPubHeaders[0] = PubHeader()
        
        for ndx in 0..<(oldPubHeaders.count - 1)  {
            let pubHeaderA = newPubHeaders[ndx]
            var minDistance = 999999.0
            var closestPubNdx = 0
            
            for ndx2 in 0..<oldPubHeaders.count  {
                let pubHeaderB = oldPubHeaders[ndx2]
                let d = distanceBetween(locationA: pubHeaderA.location, locationB: pubHeaderB.location)
                if d < minDistance  {
                    minDistance = d
                    closestPubNdx = ndx2
                }
            }
            let closestPubHeader = oldPubHeaders[closestPubNdx]
            oldPubHeaders[closestPubNdx] = PubHeader()
            newPubHeaders.append(closestPubHeader)
        }
        return ListOfPubs(using: newPubHeaders, existingList: self)
    }
}

extension ListOfPubs  {
    subscript(ndx:Int) ->PubHeader {
        get {return self.pubHeaders[ndx]     }
    }
 
    var count:Int {return self.pubHeaders.count}
    var isEmpty:Bool {return self.pubHeaders.isEmpty}
    var isNotEmpty:Bool {return self.pubHeaders.isNotEmpty}
}

 
// ListOfPubCreator is a factory used to make a new ListOfPubs
protocol ListOfPubsCreatorDelegate :WebServiceDelegate {
    func finishedCreating(listOfPubHeaders:ListOfPubs)
}

struct ListOfPubsCreator: WebServiceCallerType {
    
    let delegate:ListOfPubsCreatorDelegate
    let listOfPubs:ListOfPubs
    let errorDelegate: WebServiceDelegate
    let serviceName = "update pub"

    init (withDelegate delegate:ListOfPubsCreatorDelegate) {
        self.delegate = delegate
        self.listOfPubs = ListOfPubs()
        self.errorDelegate = delegate
    }
    init (withDelegate delegate:ListOfPubsCreatorDelegate, listOfPubs:ListOfPubs) {
        self.delegate = delegate
        self.listOfPubs = listOfPubs
        self.errorDelegate = delegate
    }
    
    func createList(usingSearchString search:String, location:Location, options:[SearchOption], uId:UId)
    {
        let paramDict = [K.QueryParm.search:search, K.QueryParm.page:"1", K.QueryParm.lat:String(location.lat), K.QueryParm.lng:String(location.lng), K.QueryParm.uId:uId.text]
        let urlPath = K.URL.pubListURL.addParametersToURL(paramDict:paramDict)

        let optionsDict = convertToDictionary(searchOptions: options)
        let urlPathWithOptions = urlPath.addParametersToURL(paramDict: optionsDict)
        
        self.requestList(usingURLString:urlPathWithOptions)
    }
    
    func createList(usingPubCrawl pubCrawl:PubCrawl)  {
        let service = pubCrawl.pubsService
        self.requestList(usingURLString:service)
    }
    
    func createList(usingPub pub:Pub)  {
        let service = pub.pubsNearByService
        self.requestList(usingURLString:service)
    }

    func getMorePubs()  {
        let service = self.listOfPubs.morePubsService
        self.requestList(usingURLString:service)
    }

    private func requestList(usingURLString urlPath:String) {
        self.call(withDelegate: self, url: urlPath)
    }

    func finishedGetting(json:[String:Any]) {
        
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let listOfPubHeaders = ListOfPubs(fromJson:json, existingList:listOfPubs)
            self.delegate.finishedCreating(listOfPubHeaders: listOfPubHeaders)
        default:
            self.failedGettingJson(error:JSONError.ConversionFailed, errorText:errorText)
        }
    }    
}

func convertToDictionary(searchOptions:[SearchOption]) -> [String:String] {
    var realAle="no"
    var onlyPubs="no"
    var memberDiscountScheme="no"
    for option in searchOptions {
        switch option {
        case .realAle:
            realAle="yes"
        case .pubs:
            onlyPubs="yes"
        case .memberDiscountScheme:
            memberDiscountScheme="yes"
        }
    }
    return ["realAle":realAle,"pubs":onlyPubs,"memberDiscount":memberDiscountScheme]
}

