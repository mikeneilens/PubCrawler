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
    @IBOutlet weak var showMapButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    var pub=Pub() //set this to get pubs near to a pub
    var listOfPubHeaders = ListOfPubs() { //always refresh headings if pub data changed
        didSet {
            self.updateMapButtonState()
        }
    }
    fileprivate var userId=UId()
    fileprivate var currentLocation=Location()
    private var filterChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userId.refreshUId()

        //if there is no pub specified, get a list of pubs near to the current location
        //otherwise get a list of pubs near to the specified pub.
        if pub.pubHeader.name.isEmpty {
            self.locationManager.delegate = self
            checkLocationServicesPermissionsAndGetData()
        } else {
            self.navigationItem.leftBarButtonItem = nil
            self.updateListOfPubs(forPub:pub)
        }
        
        self.searchBar.delegate=self
        self.searchBar.setShortPlaceholder(using: K.shortPubSearchText)
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: K.Notification.filterChanged, object: nil, queue: nil, using: setFilterChanged)
    }
    
    func checkLocationServicesPermissionsAndGetData() {
        if CLLocationManager.locationServicesEnabled() {
            let authorisationStatus = CLLocationManager.authorizationStatus()
            if authorisationStatus == .authorizedAlways || authorisationStatus == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
                Timer.scheduledTimer(timeInterval: 0.5, target:self, selector: #selector(self.getPubsNearBy), userInfo: nil, repeats: false)
            } else {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if filterChanged {
            self.createRefreshWarning()
            self.filterChanged = false
        }
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
    
    private func updateMapButtonState() {
        if let showMapButton = self.showMapButton {
            showMapButton.isEnabled = self.listOfPubHeaders.isNotEmpty
        }
    }
    @objc func getPubsNearBy() {
        self.clearSearchString()
        if currentLocation.isOutsideUK {
            self.showErrorMessage(withMessage: K.usingDefaultSearchWarningMessage , withTitle: "Warning")
            self.updateListOfPubs(forSearchString: K.defaultSearch)
        } else {
            self.updateListOfPubs(forSearchString: K.nearMeSearchText)
        }
    }
    func clearSearchString() {
        guard let searchBar = self.searchBar else {return}
        searchBar.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case K.SegueId.showDetail:
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let pubDetailTableViewController = segue.destination as? PubDetailTableViewController  {
                    let pubHeader = self.listOfPubHeaders[indexPath.row]
                    pubDetailTableViewController.pubHeader = pubHeader
                }
            }
        case K.SegueId.showSearchOnMap:
            if let pubCrawlMapViewController = segue.destination as? PubCrawlMapViewController {
                pubCrawlMapViewController.listOfPubHeaders = self.listOfPubHeaders
            }
        default:
            break
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
    func setFilterChanged(notification:Notification) {
        if self.listOfPubHeaders.count > 0 {
            self.filterChanged = true
        }
    }
    func createRefreshWarning() {
        let alert = UIAlertController(title: "Filters Changed", message: "Would you like to refresh the search results?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: self.refreshSearch))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    func refreshSearch(alertAction:UIAlertAction) {
        guard let searchText = self.searchBar.text else {return}
        if searchText.isEmpty {
            self.refreshSearchForCurrentLocation()
        } else {
            self.refreshSearchUsingSearchBar()
        }
    }
    func refreshSearchForCurrentLocation() {
        self.nearMeButtonPressed(UIBarButtonItem())
    }
    func refreshSearchUsingSearchBar() {
        self.searchBarSearchButtonClicked(self.searchBar)
    }

}

extension SearchTableViewController:ListOfPubsCreatorDelegate {
    //ListOfPubsCreator delegate methods
    
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
            self.enableNearMeButton(true)
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            //allow a half a second before attempting to get pubs near current location to allow for geolocation updating.
            Timer.scheduledTimer(timeInterval: 0.5, target:self, selector: #selector(self.getPubsNearBy), userInfo: nil, repeats: false)
        } else {
            self.enableNearMeButton(false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.currentLocation = Location(fromCoordinate:locValue)
    }
    func enableNearMeButton(_ enabled:Bool) {
        guard let nearMeButton = self.nearMeButton else {return}
        nearMeButton.isEnabled = enabled
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
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        } else {
            cell.textLabel!.text = "more pubs..."
            cell.accessoryType = UITableViewCell.AccessoryType.none
            cell.detailTextLabel!.text = ""
        }
        
        return cell
    }
    
}

