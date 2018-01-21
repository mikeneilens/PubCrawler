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

protocol ListOfPubCrawlsCreatorListDelegate :CallWebServiceType  {
    func finishedCreating(listOfPubCrawls:ListOfPubCrawls)
}

struct ListOfPubCrawlsCreator:JSONResponseDelegate {
    
    let delegate:ListOfPubCrawlsCreatorListDelegate
    
    init (delegate:ListOfPubCrawlsCreatorListDelegate) {
        self.delegate = delegate
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
        WebServieCaller().call(withDelegate: self, url: urlPath)
    }

    func finishedGetting(json:[String:Any]) {
        
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let listOfPubCrawls = ListOfPubCrawls(fromJson:json)
            self.delegate.finishedCreating(listOfPubCrawls: listOfPubCrawls)
            
        default:
            self.delegate.requestFailed(error: JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not retrieve list of pub crawls")
        }
    }
    func failedGettingJson(error:Error) {
        self.delegate.requestFailed(error: JSONError.ConversionFailed, errorText:"Error connecting to internet", errorTitle:"Could not retrieve list of pub crawls")
    }
}

protocol updatePubCrawlDelegate :CallWebServiceType {
    func finishedUpdatingPubCrawlIn(listOfPubCrawls:ListOfPubCrawls)
}

struct ListOfPubCrawlsUpdater:JSONResponseDelegate {
    
    let delegate:updatePubCrawlDelegate
    
    init (delegate:updatePubCrawlDelegate) {
        self.delegate = delegate
    }
    
    func update(pubCrawl:PubCrawl, newName:String) {
        let urlPath = pubCrawl.updateService + newName.cleanQString
        WebServieCaller().call(withDelegate: self, url: urlPath)
    }
    func updateSetting(forPubCrawl pubCrawl:PubCrawl) {
        let urlPath = pubCrawl.updateSettingsService
        WebServieCaller().call(withDelegate: self, url: urlPath)
    }
    func addUser(toPubCrawl pubCrawl:PubCrawl ) {
        let urlPath = pubCrawl.addUserService
        WebServieCaller().call(withDelegate: self, url: urlPath)
    }
    
    func finishedGetting(json:[String:Any]) {
        
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let listOfPubCrawls = ListOfPubCrawls(fromJson:json)
            delegate.finishedUpdatingPubCrawlIn(listOfPubCrawls:listOfPubCrawls)
        default:
            delegate.requestFailed(error: JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not update pub crawl")
        }
    }
    func failedGettingJson(error:Error) {
        delegate.requestFailed(error: JSONError.ConversionFailed, errorText:"Error connecting to internet", errorTitle:"Could not update pub crawl")
    }
}



