//
//  ListOfPubCrawls.swift
//  pubCrawler
//
//  Created by Michael Neilens on 21/02/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import Foundation
import MNWebServiceCall

struct ListOfPubCrawls {
    let pubCrawls:[PubCrawl]
    let createPubCrawlService:String
    
    init() { self = ListOfPubCrawls(fromJson:[:])}
    
    init(fromJson json:[String:Any]) {

        var pubCrawls = [PubCrawl]()
        if let jsonPubs = json[K.PubCrawlJsonName.pubCrawl] as? [[String:Any]] {
            for jsonPub:[String:Any] in jsonPubs {
                let pubCrawl=PubCrawl(fromJson: jsonPub)
                pubCrawls.append(pubCrawl)
            }
        }
        self.pubCrawls = pubCrawls
        self.createPubCrawlService = json[K.PubJsonName.createPubCrawlService] as? String ?? ""
    }
    
    init(from listOfPubCrawls:ListOfPubCrawls, newPubCrawls:[PubCrawl]) {
        self.pubCrawls = newPubCrawls
        self.createPubCrawlService = listOfPubCrawls.createPubCrawlService
    }
    init(from pubCrawls:[PubCrawl]) {
        self.pubCrawls = pubCrawls
        self.createPubCrawlService = ""
    }

    func contains(newPubCrawl:PubCrawl) -> Bool {
        for pubCrawl in self.pubCrawls {
            if pubCrawl.name == newPubCrawl.name {
                return true
            }
        }
        return false
    }
}

extension ListOfPubCrawls {
    var count:Int {return self.pubCrawls.count}
    var isEmpty:Bool {return self.pubCrawls.isEmpty}
    var isNotEmpty:Bool {return self.pubCrawls.isNotEmpty}
    var last:PubCrawl? {return self.pubCrawls.last}
    subscript(ndx:Int) ->PubCrawl {
        get {return self.pubCrawls[ndx]     }
    }
}

protocol ListOfPubCrawlsCreatorListDelegate :WebServiceDelegate  {
    func finishedCreating(listOfPubCrawls:ListOfPubCrawls)
}

struct ListOfPubCrawlsCreator:WebServiceCallerType {
    
    let delegate:ListOfPubCrawlsCreatorListDelegate
    let errorDelegate: WebServiceDelegate
    let serviceName = "retrieve list of pub crawls"

    init (delegate:ListOfPubCrawlsCreatorListDelegate) {
        self.delegate = delegate
        self.errorDelegate = delegate
    }

    func createListOfPubCrawls(forUId userId:UId) {
        let paramDict = [K.QueryParm.function:K.QueryParm.Function.list, K.QueryParm.uId:userId.text]
        let urlPath = K.URL.pubCrawlURL.addParametersToURL(paramDict:paramDict)
        self.createList(withUrlString:urlPath)
    }
    
    func searchForPubCrawls(withName search:String,forUId userId:UId) {
        let paramDict = [K.QueryParm.function:K.QueryParm.Function.search, K.QueryParm.search:search, K.QueryParm.uId:userId.text]
        let urlPath = K.URL.pubCrawlURL.addParametersToURL(paramDict:paramDict)
        self.createList(withUrlString: urlPath)
    }
    
    private func createList(withUrlString urlPath:String) {
        self.call(withDelegate: self, url: urlPath)
    }

    func finishedGetting(json:[String:Any]) {
        
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let listOfPubCrawls = ListOfPubCrawls(fromJson:json)
            self.delegate.finishedCreating(listOfPubCrawls: listOfPubCrawls)
        default:
            self.failedGettingJson(error:JSONError.ConversionFailed, errorText:errorText)
        }
    }
}

protocol updatePubCrawlDelegate :WebServiceDelegate {
    func finishedUpdatingPubCrawlIn(listOfPubCrawls:ListOfPubCrawls)
}

struct ListOfPubCrawlsUpdater:WebServiceCallerType  {
    
    let delegate:updatePubCrawlDelegate
    let errorDelegate: WebServiceDelegate
    let serviceName = "update pub crawl"

    init (delegate:updatePubCrawlDelegate) {
        self.delegate = delegate
        self.errorDelegate = delegate
    }
    
    func update(pubCrawl:PubCrawl, newName:String) {
        let urlPath = pubCrawl.updateService + newName.cleanQString
        self.call(withDelegate: self, url: urlPath)
    }
    func updateSetting(forPubCrawl pubCrawl:PubCrawl) {
        let urlPath = pubCrawl.updateSettingsService
        self.call(withDelegate: self, url: urlPath)
    }
    func addUser(toPubCrawl pubCrawl:PubCrawl ) {
        let urlPath = pubCrawl.addUserService
        self.call(withDelegate: self, url: urlPath)
    }
    
    func finishedGetting(json:[String:Any]) {
        
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let listOfPubCrawls = ListOfPubCrawls(fromJson:json)
            delegate.finishedUpdatingPubCrawlIn(listOfPubCrawls:listOfPubCrawls)
        default:
            self.failedGettingJson(error:JSONError.ConversionFailed, errorText:errorText)
        }
    }
}



