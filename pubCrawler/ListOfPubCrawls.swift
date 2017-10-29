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
protocol updatePubCrawlDelegate :CallWebServiceType {
    func finishedUpdatingPubCrawlName(listOfPubCrawls:ListOfPubCrawls)
}
protocol updatePubCrawlSettingDelegate :CallWebServiceType{
    func finishedUpdatingPubCrawlSetting(listOfPubCrawls:ListOfPubCrawls)
}
protocol addUsertoPubCrawlDelegate :CallWebServiceType{
    func finishedAddingUser(listOfPubCrawls:ListOfPubCrawls)
}

struct ListOfPubCrawlsCreator:JSONResponseDelegate {
    
    enum CreatorDelegate {
        case list(ListOfPubCrawlsCreatorListDelegate)
        case update(updatePubCrawlDelegate)
        case updateSetting(updatePubCrawlSettingDelegate)
        case addUser(addUsertoPubCrawlDelegate)
    }
    let delegate:CreatorDelegate
    
    init (delegate:CreatorDelegate) {
        switch delegate {
            case .list(let listDelegate):
                self.delegate = .list(listDelegate)
            case .update(let updateDelegate):
                self.delegate = .update(updateDelegate)
            case .updateSetting(let updateSettingDelegate):
                self.delegate = .updateSetting(updateSettingDelegate)
            case .addUser(let addUserDelegate):
                self.delegate = .addUser(addUserDelegate)
        }
    }

    func createPubCrawl(forUId userId:UId) {
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
        WebService(delegate:self).getJson(urlString: urlPath)
    }
    
    func update(pubCrawl:PubCrawl, newName:String) {
        let service = pubCrawl.updateService + newName.cleanQString
        WebService(delegate:self).getJson(urlString: service)
    }
    func updateSetting(forPubCrawl pubCrawl:PubCrawl) {
        let service = pubCrawl.updateSettingsService
        WebService(delegate:self).getJson(urlString: service)
    }
    func addUser(toPubCrawl pubCrawl:PubCrawl ) {
        let service = pubCrawl.addUserService
        WebService(delegate:self).getJson(urlString: service)
    }
    
    func finishedGetting(json:[String:Any]) {
        
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let listOfPubCrawls = ListOfPubCrawls(fromJson:json)

            switch self.delegate {
                case .list(let listDelegate):
                    listDelegate.finishedCreating(listOfPubCrawls: listOfPubCrawls)
            case .update(let delegate):
                let listOfPubCrawls = ListOfPubCrawls(fromJson: json)
                delegate.finishedUpdatingPubCrawlName(listOfPubCrawls:listOfPubCrawls)
            case .updateSetting(let delegate):
                let listOfPubCrawls = ListOfPubCrawls(fromJson: json)
                delegate.finishedUpdatingPubCrawlSetting(listOfPubCrawls:listOfPubCrawls)
            case .addUser(let delegate):
                let listOfPubCrawls = ListOfPubCrawls(fromJson: json)
                delegate.finishedAddingUser(listOfPubCrawls:listOfPubCrawls)
            }
        default:
            switch delegate {
            case .list(let delegate):
                delegate.requestFailed(error: JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not retrieve list of pub crawls")
            case .update(let delegate):
                delegate.requestFailed(error: JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not update the pub crawl")
            case .updateSetting(let delegate):
                delegate.requestFailed(error: JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not update settings of the pub crawl")
            case .addUser(let delegate):
                delegate.requestFailed(error: JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not add user to the pub crawl")
            }
        }
    }
    func failedGettingJson(error:Error) {
        switch delegate {
        case .list(let delegate):
            delegate.requestFailed(error: JSONError.ConversionFailed, errorText:"Error connecting to internet", errorTitle:"Could not retrieve list of pub crawls")
        case .update(let delegate):
            delegate.requestFailed(error: JSONError.NoData, errorText:"Error connecting to internet", errorTitle:"Could not update the pub crawl")
        case .updateSetting(let delegate):
            delegate.requestFailed(error: JSONError.NoData, errorText:"Error connecting to internet", errorTitle:"Could not update settings of the pub crawl")
        case .addUser(let delegate):
            delegate.requestFailed(error: JSONError.NoData, errorText:"Error connecting to internet", errorTitle:"Could not add user to the pub crawl")

        }
    }
}


