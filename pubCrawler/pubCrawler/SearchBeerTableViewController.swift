//
//  SearchBeerTableViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 06/10/2019.
//  Copyright © 2019 Michael Neilens. All rights reserved.
//

import UIKit
import CoreLocation

class SearchBeerTableViewController: AbstractTableViewController {

    @IBOutlet weak var nearMeButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let locationManager = CLLocationManager()
    var listOfBeers = ListOfBeers()
    fileprivate var userId=UId()
    fileprivate var currentLocation=Location()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userId.refreshUId()
        self.locationManager.delegate = self
        checkLocationServicesPermissionsAndGetData()
        
        self.searchBar.delegate=self
        self.searchBar.setShortPlaceholder(using: K.shortPubSearchText)
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
        self.clearSearchString()
        if currentLocation.isOutsideUK {
            self.showErrorMessage(withMessage: K.usingDefaultSearchWarningMessage , withTitle: "Warning")
            self.updateListOfBeers(forSearchString: K.defaultSearch)
        } else {
            self.updateListOfBeers(forSearchString: K.nearMeSearchText)
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
                    let pubForBeer = self.listOfBeers.beerSections[indexPath.section].listOfPubs[indexPath.row]
                    let pubHeaderJson = ["Name":pubForBeer.pubName, "PubService":pubForBeer.pubService]
                    pubDetailTableViewController.pubHeader = PubHeader(fromJson:pubHeaderJson)
                }
            }
        default:
            break
        }
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

extension SearchBeerTableViewController: ListOfBeersCreatorDelegate {
    //ListOfBeersCreator delegate methods
    
    func updateListOfBeers(forSearchString search:String) {
        self.startActivityIndicator()
        
        ListOfBeersCreator(withDelegate: self).createList(usingSearchString:search, location:currentLocation, deg:"0.05", options:userId.searchOptions, uId:self.userId)
    }
    func updateListOfBeersForLocation() {
        self.startActivityIndicator()
        
        ListOfBeersCreator(withDelegate: self).createList(usingSearchString:"", location:currentLocation, deg:"0.05", options:userId.searchOptions, uId:self.userId)
    }

    func finishedCreating(listOfBeers: ListOfBeers) {
        stopActivityIndicator()
        if listOfBeers.beers.isEmpty {
            if let searchtext = self.searchBar.text {
                self.showErrorMessage(withMessage: "No beers found for '" + searchtext + "'", withTitle: "Couldn't find any beers")
            }
        } else {
            self.listOfBeers = listOfBeers
            self.tableView.reloadData()
        }
    }

}

extension SearchBeerTableViewController: UISearchBarDelegate { //delegate methods for UISearchBar

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let search = searchBar.text  {
            self.updateListOfBeers(forSearchString: search)
            self.view.endEditing(true)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}

extension SearchBeerTableViewController: CLLocationManagerDelegate { //delegat methods for CLLoctaionManager
    
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

extension SearchBeerTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.listOfBeers.beerSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfBeers.beerSections[section].listOfPubs.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.listOfBeers.beerSections[section].name
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "pubCell", for: indexPath)
        
        let pubForBeer = self.listOfBeers.beerSections[indexPath.section].listOfPubs[row]
        if pubForBeer.isRegular {
            cell.textLabel!.text = pubForBeer.pubName
        } else {
            cell.textLabel!.text = pubForBeer.pubName + " (guest beer)"
        }
        cell.detailTextLabel?.text = pubForBeer.distanceText
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        return cell
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return listOfBeers.beerSections.map{"\($0.name.prefix(1))"}
    }
}
