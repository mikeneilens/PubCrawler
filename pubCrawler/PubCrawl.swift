//
//  PubCrawl.swift
//  pubCrawler
//
//  Created by Michael Neilens on 22/02/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import Foundation
import MNWebServiceCall

struct PubCrawl {
    let name:String
    let isPublic:Bool
    let pubsService:String
    let addPubCrawlService:String
    let removePubCrawlService:String
    let copyService:String
    let updateSettingsService:String
    let removeService:String
    let updateService:String
    let addUserService:String
    let sequencePubsService:String
    let emailTextService:String
    let sequence:Int

    var canAddPubCrawl:Bool {return addPubCrawlService.isNotEmpty}
    var canRemovePubcrawl:Bool {return removePubCrawlService.isNotEmpty}
    var canCopy:Bool {return copyService.isNotEmpty}
    var canUpdateSetting:Bool {return updateSettingsService.isNotEmpty}
    var canRemove:Bool {return removeService.isNotEmpty}
    var canUpdate:Bool {return updateService.isNotEmpty}
    var canAddUser:Bool {return addUserService.isNotEmpty}
    var canSequencePubs:Bool {return sequencePubsService.isNotEmpty}
    
    init(){
        self = PubCrawl(fromJson: [String:Any]())
    }
    init (name:String, sequence:Int) {
        let json = [K.PubCrawlJsonName.name:name, K.PubCrawlJsonName.sequence:"\(sequence)"]
        self = PubCrawl(fromJson: json)
    }
    
    init (fromJson jsonPubCrawl:[String:Any]) {
        self.name      = jsonPubCrawl[K.PubCrawlJsonName.name]     as? String ?? ""
        self.isPublic  = jsonPubCrawl.getBoolValue(forKey: K.PubCrawlJsonName.isPublic, trueIfValueIs: "y")
        self.sequence  = jsonPubCrawl[K.PubCrawlJsonName.sequence] as? Int ?? 0
        self.addPubCrawlService  = jsonPubCrawl[K.PubCrawlJsonName.addPubCrawlService]  as? String ?? ""
        self.removePubCrawlService = jsonPubCrawl[K.PubCrawlJsonName.removePubCrawlService]  as? String ?? ""
        self.pubsService         = jsonPubCrawl[K.PubCrawlJsonName.pubsService]  as? String ?? ""
        self.copyService         = jsonPubCrawl[K.PubCrawlJsonName.copyService]  as? String ?? ""
        self.updateSettingsService = jsonPubCrawl[K.PubCrawlJsonName.updateSettingsService]  as? String ?? ""
        self.removeService       = jsonPubCrawl[K.PubCrawlJsonName.removeService]  as? String ?? ""
        self.updateService       = jsonPubCrawl[K.PubCrawlJsonName.updateService]  as? String ?? ""
        self.addUserService      = jsonPubCrawl[K.PubCrawlJsonName.addUserService]  as? String ?? ""
        self.sequencePubsService = jsonPubCrawl[K.PubCrawlJsonName.sequencePubsService] as? String ?? ""
        self.emailTextService    = jsonPubCrawl[K.PubCrawlJsonName.emailTextService] as? String ?? ""
    }

    
}

protocol createPubCrawlDelegate :CallWebServiceType{
    func finishedCreatingPubCrawl(listOfPubCrawls:ListOfPubCrawls, pub:Pub)
}

struct PubCrawlCreator:WebServiceCallerType {
    
    let delegate:createPubCrawlDelegate
    let pub:Pub
    let errorDelegate: CallWebServiceType
    let serviceName = "create the pub crawl"

    init(withDelegate delegate:createPubCrawlDelegate) {
        self.delegate = delegate
        self.errorDelegate = delegate
        self.pub = Pub()
    }
    init(withDelegate delegate:createPubCrawlDelegate, withPub pub:Pub) {
        self.delegate = delegate
        self.errorDelegate = delegate
        self.pub = pub
    }

    func create(forListOfPubCrawls listOfPubCrawls:ListOfPubCrawls, name:String) {
        let urlPath = listOfPubCrawls.createPubCrawlService + name.cleanQString
        self.call(withDelegate: self, url: urlPath)
    }
    
    func create(name:String) {
        let urlPath =  pub.createPubCrawlService + name.cleanQString
        self.call(withDelegate: self, url: urlPath)
    }
    
    func finishedGetting(json:[String:Any]) {
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let listOfPubCrawls = ListOfPubCrawls(fromJson: json)
            let pub = Pub(fromJson: json)
            self.delegate.finishedCreatingPubCrawl(listOfPubCrawls:listOfPubCrawls, pub:pub)
        default:
            self.failedGettingJson(error:JSONError.ConversionFailed, errorText:errorText)
        }
    }
}

protocol CopyPubCrawlDelegate :CallWebServiceType{
    func finishedCopying(listOfPubCrawls:ListOfPubCrawls)
}

struct PubCrawlCopier:WebServiceCallerType {
        
    let delegate:CopyPubCrawlDelegate
    let errorDelegate: CallWebServiceType
    let serviceName = "copy the pub crawl"

    init(withDelegate delegate:CopyPubCrawlDelegate) {
        self.delegate = delegate
        self.errorDelegate = delegate
    }
    
    func copy(pubCrawl:PubCrawl) {
        let urlPath = pubCrawl.copyService
        self.call(withDelegate: self, url: urlPath)
    }
    
    func finishedGetting(json:[String:Any]) {
        
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let listOfPubCrawls = ListOfPubCrawls(fromJson: json)
            self.delegate.finishedCopying(listOfPubCrawls:listOfPubCrawls)
        default:
            self.failedGettingJson(error:JSONError.ConversionFailed, errorText:errorText)
        }
    }
}

protocol updatePubsInPubCrawlDelegate :CallWebServiceType{
    func finishedUpdating(listOfPubHeaders:ListOfPubs)
}

struct PubCrawlUpdater:WebServiceCallerType {
    
    let delegate:updatePubsInPubCrawlDelegate
    let errorDelegate: CallWebServiceType
    let serviceName = "update the pub crawl"
    
    init(withDelegate delegate:updatePubsInPubCrawlDelegate) {
        self.delegate = delegate
        self.errorDelegate = delegate
    }
    
    func remove(pubHeader:PubHeader) {
        let urlPath = pubHeader.removePubService
        self.call(withDelegate: self, url: urlPath)
    }
    
    func resequence(pubCrawl:PubCrawl, listOfPubHeaders:ListOfPubs) {
        var csv=""
        for i in 0..<listOfPubHeaders.count {
            for j in 0..<listOfPubHeaders.count {
                if listOfPubHeaders[j].sequence == i  {
                    if  csv != ""  {
                        csv = "\(csv),"
                    }
                    csv += "\(j)"
                }
            }
        }
        let urlPath = pubCrawl.sequencePubsService + csv
        WebServieCaller().call(withDelegate: self, url: urlPath)
    }
    
    func finishedGetting(json:[String:Any]) {
        
        let (status, errorText)=json.errorStatus
        switch status {
            
        case 0:
            let listOfPubs = ListOfPubs(fromJson: json)
            delegate.finishedUpdating(listOfPubHeaders:listOfPubs)
        default:
            self.failedGettingJson(error:JSONError.ConversionFailed, errorText:errorText)
        }
    }
}

//Destroys pub crawls.
protocol removePubCrawlDelegate :CallWebServiceType{
    func finishedRemovingPubCrawl(listOfPubCrawls:ListOfPubCrawls)
}

struct PubCrawlDestroyer:WebServiceCallerType {
    
    let removeDelegate:removePubCrawlDelegate
    let pubCrawl:PubCrawl
    let errorDelegate: CallWebServiceType
    let serviceName = "remove the pub crawl"

    init(withRemoveDelegate delegate:removePubCrawlDelegate, pubCrawl:PubCrawl) {
        self.removeDelegate = delegate
        self.errorDelegate = delegate
        self.pubCrawl = pubCrawl
    }
    
    func remove() {
        let urlPath = self.pubCrawl.removeService
        self.call(withDelegate: self, url: urlPath)
    }
    
    func finishedGetting(json:[String:Any]) {
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let listOfPubCrawls = ListOfPubCrawls(fromJson: json)
            self.removeDelegate.finishedRemovingPubCrawl(listOfPubCrawls:listOfPubCrawls)
        default:
            self.failedGettingJson(error:JSONError.ConversionFailed, errorText:errorText)
        }
    }
    
}

protocol getEmailTextDelegate :CallWebServiceType{
    func finishedGetting(emailText:String)
}

struct EmailCreator:WebServiceCallerType {
    let delegate:getEmailTextDelegate
    let pubCrawl:PubCrawl
    let errorDelegate: CallWebServiceType
    let serviceName = "get email text"

    init(withDelegate delegate:getEmailTextDelegate, pubCrawl:PubCrawl) {
        self.delegate = delegate
        self.errorDelegate = delegate
        self.pubCrawl = pubCrawl
    }
    
    func getEmailText() {
        let urlPath = self.pubCrawl.emailTextService
        self.call(withDelegate: self, url: urlPath)
    }

    func finishedGetting(json:[String:Any]) {
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let emailText = json[K.PubCrawlJsonName.emailText] as? String ?? ""
            self.delegate.finishedGetting(emailText: emailText)
        default:
            self.failedGettingJson(error:JSONError.ConversionFailed, errorText:errorText)        }
    }
}
