//
//  PubCrawlsTableViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 21/02/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit

class PubCrawlsTableViewController: AbstractTableViewController  {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet var resetButton: UIBarButtonItem!  //not weak as want to retain the button when it is removed from navbar
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate var userId=UId()
    fileprivate var listOfpubCrawls = ListOfPubCrawls()

    fileprivate var lastSearch = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.navigationItem.leftBarButtonItem = nil
        userId.refreshUId()
        self.navigationItem.title = "Pub Crawls"
        self.searchBar.delegate = self
        self.searchBar.setShortPlaceholder(using: K.shortPubCrawlSearchText)
    }

    func getPubCrawl(forCrawlId crawlId:String) {
        let pubCrawl = PubCrawl(name: "Please wait...", sequence:0)
        self.listOfpubCrawls = ListOfPubCrawls(from:[pubCrawl] )
        self.startCreatingListOfPubCrawls(withSearchText: crawlId)
        self.searchBar.text=" "
        self.addResetButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        
        self.startCreatingListOfPubCrawls(withSearchText:self.lastSearch)
        self.tableView.reloadData()

    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segueId = segue.identifier {
            switch segueId {
                case K.SegueId.showPubsForPubCrawl:
                    if let pubCrawlDetailTableViewController = segue.destination as? PubCrawlDetailTableViewController {
                        if let indexPath = self.tableView.indexPathForSelectedRow {
                            let row = indexPath.row
                            pubCrawlDetailTableViewController.pubCrawl = listOfpubCrawls.pubCrawls[row]
                            pubCrawlDetailTableViewController.pubCrawlNdx = row
                        }
                    }
            case K.SegueId.showCreatePubCrawl:
                if let createPubCrawlViewController = segue.destination as? CreatePubCrawlViewController {
                    createPubCrawlViewController.listOfPubCrawls = self.listOfpubCrawls
                }
                default:
                    break
            }
        }
    }
    
    @IBAction func resetPressed(_ sender: UIBarButtonItem) {
        self.searchBar.text=""
        self.navigationItem.leftBarButtonItem = nil
        self.startCreatingListOfPubCrawls(withSearchText:"")
    }
    
    func addResetButton(){
        if self.navigationItem.leftBarButtonItem == nil {
            self.navigationItem.leftBarButtonItem=self.resetButton
        }
    }
    
}

extension PubCrawlsTableViewController { //datasource delegate methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfpubCrawls.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        let pubCrawl = self.listOfpubCrawls.pubCrawls[row]
        
        cell.textLabel!.text = pubCrawl.name
        
        return cell
    }

}

extension PubCrawlsTableViewController:ListOfPubCrawlsCreatorListDelegate { //delegate methods for ListOfPubCrawlsCreator

    func startCreatingListOfPubCrawls(withSearchText search:String) {
        
        self.startActivityIndicator()
        
        if search.isEmpty {
            ListOfPubCrawlsCreator(delegate:self).createListOfPubCrawls(forUId:userId)
        } else {
            ListOfPubCrawlsCreator(delegate:self).searchForPubCrawls(withName: search, forUId:userId)
        }
        
        self.lastSearch = search
    }

    func finishedCreating(listOfPubCrawls list:ListOfPubCrawls) {
        self.stopActivityIndicator()
    
        if ((self.searchBar.text != "") && (list.isEmpty) ) {
            if let searchtext = self.searchBar.text {
                self.showErrorMessage(withMessage: "No pubCrawls found for '" + searchtext + "'", withTitle: "Couldn't find any pub crawls")
            }
        } else {
            self.listOfpubCrawls = list
            self.tableView.reloadData()
        }
        
        if (self.searchBar.text != "") {
            self.addResetButton()
        }
    }

}

extension PubCrawlsTableViewController:UISearchBarDelegate {  //delegate methods for searchbar

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let search = searchBar.text  {
            self.startCreatingListOfPubCrawls(withSearchText:search)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        self.searchBar.text = self.lastSearch
    }
}

