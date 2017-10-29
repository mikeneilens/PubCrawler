//
//  NotificationCentreExtensions.swift
//  pubCrawler
//
//  Created by Michael Neilens on 16/11/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import Foundation

extension NotificationCenter {
    //Use custom Post when sending notifications to ensure message is formed correctly. Use the custom Notification property to determine contents of message.
    static func addObserverPubCrawlChanged(_ any: Any, selector:Selector) {
        NotificationCenter.default.addObserver(any, selector: selector, name: K.Notification.pubCrawlChanged, object: nil)
    }
    static func addObserverPubCrawlRemoved(_ any: Any, selector:Selector) {
        NotificationCenter.default.addObserver(any, selector: selector, name: K.Notification.pubCrawlRemoved, object: nil)
    }
    static func addObserverPubCrawlAdded(_ any: Any, selector:Selector) {
        NotificationCenter.default.addObserver(any, selector: selector, name: K.Notification.pubCrawlAdded, object: nil)
    }
    static func addObserverListOfPubCrawlsChanged(_ any: Any, selector:Selector) {
        NotificationCenter.default.addObserver(any, selector: selector, name: K.Notification.listOfPubCrawlsChanged, object: nil)
    }
    static func addObserverPubChanged(_ any: Any, selector:Selector) {
        NotificationCenter.default.addObserver(any, selector: selector, name: K.Notification.pubChanged, object: nil)
    }

    func post(removedPubCrawl:PubCrawl) {
        var notification = Notification(name:K.Notification.pubCrawlRemoved, object:nil, userInfo:[:])
        notification.pubCrawl = removedPubCrawl
        NotificationCenter.default.post(notification)
    }
    func post(addedPubCrawl:PubCrawl) {
        var notification = Notification(name:K.Notification.pubCrawlAdded, object:nil, userInfo:[:])
        notification.pubCrawl = addedPubCrawl
        NotificationCenter.default.post(notification)
    }
    func post(changedPubCrawl:PubCrawl, with pubHeader:PubHeader) {
        var notification = Notification(name:K.Notification.pubCrawlChanged, object:nil, userInfo:[:])
        notification.pubCrawl = changedPubCrawl
        notification.pubHeader = pubHeader
        NotificationCenter.default.post(notification)
    }
    func post(changedPubCrawl:PubCrawl) {
        var notification = Notification(name:K.Notification.pubCrawlChanged, object:nil, userInfo:[:])
        notification.pubCrawl = changedPubCrawl
        NotificationCenter.default.post(notification)
    }
    func post(changedListOfPubCrawls:ListOfPubCrawls) {
        var notification = Notification(name:K.Notification.listOfPubCrawlsChanged, object:nil, userInfo:[:])
        notification.listOfPubCrawls = changedListOfPubCrawls
        NotificationCenter.default.post(notification)
    }
    func post(changedPub:Pub) {
        var notification = Notification(name:K.Notification.pubChanged, object:nil, userInfo:[:])
        notification.pub = changedPub
        NotificationCenter.default.post(notification)
    }
}


extension Notification {
    var listOfPubCrawls:ListOfPubCrawls {
        get {
            return self.userInfo?["ListOfPubCrawls"] as? ListOfPubCrawls ?? ListOfPubCrawls()
        }
        set(newListOfPubCrawls) {
            self.userInfo?["ListOfPubCrawls"] = newListOfPubCrawls
        }
    }
    var pubCrawl:PubCrawl {
        get {
            return self.userInfo?["PubCrawl"] as? PubCrawl ?? PubCrawl()
        }
        set(newPubCrawl) {
            self.userInfo?["PubCrawl"] = newPubCrawl
        }
    }
    var pubHeader:PubHeader {
        get {
            return self.userInfo?["PubHeader"] as? PubHeader ?? PubHeader()
        }
        set (newPubHeader) {
            self.userInfo?["PubHeader"] = newPubHeader
        }
    }
    var pub:Pub {
        get {
            return self.userInfo?["Pub"] as? Pub ?? Pub(fromJson: [:])
        }
        set (newPub) {
            self.userInfo?["Pub"] = newPub
        }
    }

}
