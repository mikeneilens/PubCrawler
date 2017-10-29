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
protocol copyPubCrawlDelegate :CallWebServiceType{
    func finishedCopying(listOfPubCrawls:ListOfPubCrawls)
}
//Creates new pub crawls
struct PubCrawlCreator:JSONResponseDelegate {
    
    enum CreatorDelegate {
        case create(createPubCrawlDelegate)
        case copy(copyPubCrawlDelegate)
    }
    
    let delegate:CreatorDelegate
    let pub:Pub
    
    init(withDelegate delegate:CreatorDelegate) {
        self = PubCrawlCreator(withDelegate:delegate, withPub:Pub())
    }
    init(withDelegate delegate:CreatorDelegate, withPub pub:Pub) {
        switch delegate {
        case .create(let createPubCrawlDelegate):
            self.delegate = .create(createPubCrawlDelegate)
        case .copy(let copyPubCrawlDelegate):
            self.delegate = .copy(copyPubCrawlDelegate)
        }
        self.pub = pub
    }

    func create(forListOfPubCrawls listOfPubCrawls:ListOfPubCrawls, name:String) {
        let service = listOfPubCrawls.createPubCrawlService + name.cleanQString
        WebService(delegate:self).getJson(urlString: service)
    }
    func create(name:String) {
        let service =  pub.createPubCrawlService + name.cleanQString
        WebService(delegate:self).getJson(urlString: service)
    }
    
    func copy(pubCrawl:PubCrawl) {
        let service = pubCrawl.copyService
        WebService(delegate:self).getJson(urlString: service)
    }
    
    func finishedGetting(json:[String:Any]) {
        
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            switch self.delegate {
            case .create(let createDelegate):
                let listOfPubCrawls = ListOfPubCrawls(fromJson: json)
                let pub = Pub(fromJson: json)
                createDelegate.finishedCreatingPubCrawl(listOfPubCrawls:listOfPubCrawls, pub:pub)
            case .copy(let copyDelegate):
                let listOfPubCrawls = ListOfPubCrawls(fromJson: json)
                copyDelegate.finishedCopying(listOfPubCrawls:listOfPubCrawls)
            }
        default:
            switch self.delegate {
            case .create(let createDelegate):
                createDelegate.requestFailed(error: JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not create the pub crawl")
            case .copy(let copyDelegate):
                copyDelegate.requestFailed(error: JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not copy the pub crawl")
            }
        }
    }
    func failedGettingJson(error:Error) {
        switch self.delegate {
        case .create(let createDelegate):
            createDelegate.requestFailed(error: JSONError.NoData, errorText:"Error connecting to internet", errorTitle:"Could not create the pub crawl")
        case .copy(let copyDelegate):
            copyDelegate.requestFailed(error: JSONError.NoData, errorText:"Error connecting to internet", errorTitle:"Could not copy the pub crawl")
        }
    }
}

protocol removePubFromPubCrawlDelegate :CallWebServiceType{
    func finishedRemovingPubFromPubCrawl(listOfPubHeaders:ListOfPubs)
}
protocol resequencePubsDelegate :CallWebServiceType{
    func finishedResequencing(listOfPubHeaders:ListOfPubs)
}

struct PubCrawlUpdater:JSONResponseDelegate {
    
    enum ChangeDelegate {
        case resequence(resequencePubsDelegate)
        case removePubFromPubCrawl(removePubFromPubCrawlDelegate)
    }
    let delegate:ChangeDelegate
    
    init(withDelegate delegate:ChangeDelegate) {
        self.delegate = delegate
    }
    
    func remove(pubHeader:PubHeader) {
        let service = pubHeader.removePubService
        WebService(delegate:self).getJson(urlString: service)
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
        let service = pubCrawl.sequencePubsService + csv
        WebService(delegate:self).getJson(urlString: service)
    }
    
    func finishedGetting(json:[String:Any]) {
        
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            switch self.delegate {
            case .resequence(let delegate):
                let listOfPubs = ListOfPubs(fromJson: json)
                delegate.finishedResequencing(listOfPubHeaders:listOfPubs)
            case .removePubFromPubCrawl(let delegate):
                let listOfPubs = ListOfPubs(fromJson: json)
                delegate.finishedRemovingPubFromPubCrawl(listOfPubHeaders: listOfPubs)
            }
            
        default:
            switch self.delegate {
            case .resequence(let delegate):
                delegate.requestFailed(error: JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not resequence the pub crawl")
            case .removePubFromPubCrawl(let delegate):
                delegate.requestFailed(error:JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not remove pub from pub crawl")
            }
        }
    }
    func failedGettingJson(error:Error) {
        
        switch self.delegate {
        case .resequence(let delegate):
            delegate.requestFailed(error: JSONError.NoData, errorText:"Error connecting to internet", errorTitle:"Could not resequence the pub crawl")
        case .removePubFromPubCrawl(let delegate):
            delegate.requestFailed(error:JSONError.NoData, errorText:"Error connecting to internet", errorTitle:"Could not remove pub from pub crawl")
        }
    }

}



//Destroys pub crawls.
protocol removePubCrawlDelegate :CallWebServiceType{
    func finishedRemovingPubCrawl(listOfPubCrawls:ListOfPubCrawls)
}

struct PubCrawlDestroyer:JSONResponseDelegate {
    
    let removeDelegate:removePubCrawlDelegate
    let pubCrawl:PubCrawl

    init(withRemoveDelegate delegate:removePubCrawlDelegate, pubCrawl:PubCrawl) {
        self.removeDelegate = delegate
        self.pubCrawl = pubCrawl
    }
    
    func remove() {
        let service = self.pubCrawl.removeService
        WebService(delegate:self).getJson(urlString: service)
    }
    
    func finishedGetting(json:[String:Any]) {
        
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let listOfPubCrawls = ListOfPubCrawls(fromJson: json)
            self.removeDelegate.finishedRemovingPubCrawl(listOfPubCrawls:listOfPubCrawls)
            
        default:
            self.removeDelegate.requestFailed(error: JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not remove the pub crawl")
        }
    }
    func failedGettingJson(error:Error) {
        self.removeDelegate.requestFailed(error: JSONError.NoData, errorText:"Error connecting to internet", errorTitle:"Could not remove the pub crawl")
    }
    
}

protocol getEmailTextDelegate :CallWebServiceType{
    func finishedGetting(emailText:String)
}

struct EmailCreator:JSONResponseDelegate {
    let delegate:getEmailTextDelegate
    let pubCrawl:PubCrawl
    
    init(withDelegate delegate:getEmailTextDelegate, pubCrawl:PubCrawl) {
        self.delegate = delegate
        self.pubCrawl = pubCrawl
    }
    
    func getEmailText() {
        let service = self.pubCrawl.emailTextService
        WebService(delegate:self).getJson(urlString: service)
    }

    func finishedGetting(json:[String:Any]) {
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let emailText = json[K.PubCrawlJsonName.emailText] as? String ?? ""
            self.delegate.finishedGetting(emailText: emailText)
        default:
            self.delegate.requestFailed(error:JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not get email text")
        }
    }
    func failedGettingJson(error:Error) {
        self.delegate.requestFailed(error:JSONError.NoData, errorText:"Error connecting to internet", errorTitle:"Could not get email text")
    }


}