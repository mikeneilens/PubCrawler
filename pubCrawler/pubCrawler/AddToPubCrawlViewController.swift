//
//  AddToPubCrawlViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 30/07/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit

struct PubCrawlItem {
    var name=""
    var ndx=0
}

protocol AddToPubCrawlDelegate {
    func pubCrawlAdded(atIndex:Int)
    func createPubCrawl()
}

class AddToPubCrawlViewController: UIAlertController {
    
    var delegate:AddToPubCrawlDelegate?
    var listOfPubCrawls=ListOfPubCrawls()
    let emptyTitle="You have no Pub Crawls"
    let notEmptyTitle="Select a Pub Crawl"
    let createText="Create a Pub Crawl...."

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.listOfPubCrawls.isEmpty) {
            self.title = self.emptyTitle
        } else {
            self.title = self.notEmptyTitle
            self.addActionForEachPubCrawl()
        }
        
        self.addCreateNewPubCrawlMessage()
        self.addCancelMessage()
    }
    
    private func addActionForEachPubCrawl()  {
        for (ndx, pubCrawl) in self.listOfPubCrawls.pubCrawls.enumerated() {
            self.addActionForPubCrawl(ndx:ndx, pubCrawl:pubCrawl)
        }
    }
    
    private func addActionForPubCrawl(ndx:Int, pubCrawl:PubCrawl) {
        let pubCrawlItem = PubCrawlItem(name:pubCrawl.name, ndx:ndx)
        let action = UIAlertAction(title: pubCrawlItem.name, style: .default, handler: {action in self.add(pubCrawlItem:pubCrawlItem) })
        self.addAction(action)
    }
    
    func addCreateNewPubCrawlMessage() {
        let action = UIAlertAction(title: self.createText, style: .default, handler: {action in self.createItem()})
        self.addAction(action)
    }
    
    func addCancelMessage() {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {action in self.cancel() })
        self.addAction(cancelAction)
    }
    
    func add(pubCrawlItem:PubCrawlItem) {
        delegate?.pubCrawlAdded(atIndex:pubCrawlItem.ndx)
    }
    func createItem() {
        delegate?.createPubCrawl()
    }
    
    func cancel() {
        
    }
    
    
}
