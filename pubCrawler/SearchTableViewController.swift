//
//  MasterViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 15/02/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit
import CoreLocation


class SearchTableViewController: AbstractTableViewController {

    @IBOutlet weak var nearMeButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!

    let locationManager = CLLocationManager()
    var pub=Pub() //set this to get pubs near to a pub
    var listOfPubHeaders = ListOfPubs()
    fileprivate var userId=UId()
    fileprivate var currentLocation=Location()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userId.refreshUId()

        //if there is no pub specified, get a list of pubs near to the current location
        //otherwise get a list of pubs near to the specified pub.
        if pub.pubHeader.name.isEmpty {
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.updateListOfPubs(forPub:pub)
        }
        
        self.searchBar.delegate=self
        self.searchBar.setShortPlaceholder(using: K.shortPubSearchText)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let searchBar = self.searchBar {
            searchBar.resignFirstResponder()
        }
    }
    
    @IBAction func nearMeButtonPressed(_ sender: UIBarButtonItem) {
        self.searchBar.resignFirstResponder()
        self.getPubsNearBy()
    }
    
    @objc func getPubsNearBy() {
        if currentLocation.isOutsideUK {
            self.showErrorMessage(withMessage: K.usingDefaultSearchWarningMessage , withTitle: "Warning")
            self.updateListOfPubs(forSearchString: K.defaultSearch)
        } else {
            self.updateListOfPubs(forSearchString: K.nearMeSearchText)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.SegueId.showDetail  {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let pubDetailTableViewController = segue.destination as? PubDetailTableViewController  {
                    let pubHeader = self.listOfPubHeaders[indexPath.row]
                    pubDetailTableViewController.pubHeader = pubHeader
                }
            }
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == K.SegueId.showDetail {
            //if selecting the last row, show more pubs instead of showing the pub details
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if indexPath.row >= self.listOfPubHeaders.count {
                    self.getMorePubs()
                    return false
                }
            }
        }
        return true
    }
}

extension SearchTableViewController:ListOfPubsCreatorDelegate { //ListOfPubsCreator delegate methods
    
    func updateListOfPubs(forSearchString search:String) {
        self.startActivityIndicator()
        ListOfPubsCreator(withDelegate: self).createList(usingSearchString:search, location:self.currentLocation, options:userId.searchOptions, uId:self.userId)
    }

    func updateListOfPubs(forPub pub:Pub) {
        self.startActivityIndicator()
        ListOfPubsCreator(withDelegate: self).createList(usingPub:pub)
    }
    func getMorePubs() {
        self.startActivityIndicator()
        ListOfPubsCreator(withDelegate: self, listOfPubs:self.listOfPubHeaders).getMorePubs()
    }

    func finishedCreating(listOfPubHeaders:ListOfPubs) {
        self.stopActivityIndicator()
        if listOfPubHeaders.isEmpty {
            if let searchtext = self.searchBar.text {
                self.showErrorMessage(withMessage: "No pubs found for '" + searchtext + "'", withTitle: "Couldn't find any pubs")
            }
        } else {
            self.listOfPubHeaders = listOfPubHeaders
            self.tableView.reloadData()
        }
    }
}

extension SearchTableViewController: UISearchBarDelegate { //delegate methods for UISearchBar

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let search = searchBar.text  {
            self.updateListOfPubs(forSearchString: search)
            self.view.endEditing(true)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}

extension SearchTableViewController: CLLocationManagerDelegate { //delegat methods for CLLoctaionManager
    
    func locationManager(_ manager:CLLocationManager, didChangeAuthorization status:CLAuthorizationStatus) {
        if ((status == .authorizedAlways) || (status == .authorizedWhenInUse)) {
            self.nearMeButton.isEnabled = true
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            //allow a half a second before attempting to get pubs near current location to allow for geolocation updating.
            Timer.scheduledTimer(timeInterval: 0.5, target:self, selector: #selector(self.getPubsNearBy), userInfo: nil, repeats: false)
        } else {
            self.nearMeButton.isEnabled = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.currentLocation = Location(fromCoordinate:locValue)
    }
   
}

extension SearchTableViewController {
    var numberOfRows:Int {
        if self.listOfPubHeaders.morePubsAvailable {
            return self.listOfPubHeaders.count + 1
        } else {
            return self.listOfPubHeaders.count
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if row < self.listOfPubHeaders.count {
            let pubHeader = self.listOfPubHeaders[row]
            cell.textLabel!.text = pubHeader.name + " "
            cell.detailTextLabel!.text = pubHeader.distanceText
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        } else {
            cell.textLabel!.text = "more pubs..."
            cell.accessoryType = UITableViewCellAccessoryType.none
            cell.detailTextLabel!.text = ""
        }
        
        return cell
    }
    
}

