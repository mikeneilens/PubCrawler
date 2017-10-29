//
//  listAlertViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 30/07/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//
//  This creates an alertView showing a list of items to pick from and a "create new item" option.
//  The users response is passed back to the delegate of this class with an item identifier.

import UIKit

struct ListItem {
    var itemId=""
    var name=""
    var ndx=0
}

protocol ListAlertDelegate {
    func itemAdded(listItem:ListItem)
    func createNewItem()
}

class ListAlertViewController: UIAlertController {
    
    var delegate:ListAlertDelegate?
    var listOfItems=[ListItem]()
    var emptyTitle="List is empty"
    var itemTitle="Select an item"
    var createText="Create a new item..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.listOfItems.isEmpty) {
            self.title = self.emptyTitle
        } else {
            self.title = self.itemTitle
            self.addActions()
        }
        
        self.addCreateItemMessage()
        self.addCancelMessage()
    }
    
    func addActions() {
        for item in listOfItems {
            let action = UIAlertAction(title: item.name, style: .default, handler: {action in self.add(item:item) })
            self.addAction(action)
        }
    }
    
    func addCreateItemMessage() {
        let action = UIAlertAction(title: self.createText, style: .default, handler: {action in self.createItem()})
        self.addAction(action)
    }
    
    func addCancelMessage() {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {action in self.cancel() })
        self.addAction(cancelAction)
    }
    
    func add(item:ListItem) {
        if let delegate = self.delegate {
            delegate.itemAdded(listItem: item)
        }
    }
    func createItem() {
        if let delegate = self.delegate {
            delegate.createNewItem()
        }
    }
    
    func cancel() {
        
    }
    
    
}
