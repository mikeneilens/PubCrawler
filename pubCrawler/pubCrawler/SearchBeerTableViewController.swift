//
//  SearchBeer2TableViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 13/10/2019.
//  Copyright © 2019 Michael Neilens. All rights reserved.
//

import UIKit
import CoreLocation

class SearchBeerTableViewController: AbstractTableViewController {

    @IBOutlet weak var nearMeButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
        
    let locationManager = CLLocationManager()
    
    fileprivate var listOfBeers = ListOfBeers()
    
    fileprivate var listOfBeerOrPub = Array<BeerOrPub>()
    fileprivate var beerSelected = Array<Bool>()
    
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
                    if case BeerOrPub.Pub(let pubForBeer) = self.listOfBeerOrPub[indexPath.row] {
                        let pubHeaderJson = ["Name":pubForBeer.pubName, "PubService":pubForBeer.pubService]
                        pubDetailTableViewController.pubHeader = PubHeader(fromJson:pubHeaderJson)
                    }
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
            
        ListOfBeersCreator(withDelegate: self).createList(usingSearchString:search, location:currentLocation, deg:"0.08", options:userId.searchOptions, uId:self.userId)
    }
    func updateListOfBeersForLocation() {
        self.startActivityIndicator()
        
        ListOfBeersCreator(withDelegate: self).createList(usingSearchString:"", location:currentLocation, deg:"0.08", options:userId.searchOptions, uId:self.userId)
    }

    func finishedCreating(listOfBeers: ListOfBeers) {
        stopActivityIndicator()
        if listOfBeers.beers.isEmpty {
            if let searchtext = self.searchBar.text {
                self.showErrorMessage(withMessage: "No beers found for '" + searchtext + "'", withTitle:"Couldn't find any beers")
            }
        } else {
            self.listOfBeers = listOfBeers
            
            self.listOfBeerOrPub = createListOfBeerOrPub(listOfBeers: listOfBeers, beerSelected: [])
            self.beerSelected = Array(repeating: false, count: listOfBeerOrPub.noOfBeers)

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
        return 1
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.listOfBeerOrPub.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch self.listOfBeerOrPub[row] {
        case .Pub(let pubForBeer):
             return createPubCell(pubForBeer: pubForBeer, indexPath: indexPath)
        case .Beer(let beerName, let beerNdx):
            return createBeerCell(beerName:beerName, beerNdx:beerNdx, indexPath:indexPath)
        }        
    }
    func createPubCell(pubForBeer:PubForBeer, indexPath:IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "pubCell", for: indexPath)
        if pubForBeer.isRegular {
            cell.textLabel!.text = pubForBeer.pubName
        } else {
            cell.textLabel!.text = pubForBeer.pubName + " (guest beer)"
        }
        cell.detailTextLabel?.text = pubForBeer.distanceText
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }
    func createBeerCell(beerName:String, beerNdx:Int, indexPath:IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "beerCell", for: indexPath)
        cell.textLabel?.text = beerName
        if let beerCell = cell as? BeerTableViewCell {
            beerCell.setSelector(beerSelected[beerNdx])
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let beerNdx = listOfBeerOrPub.beerNdx(forRow:indexPath.row) else {return}
        beerSelected[beerNdx] = !beerSelected[beerNdx]
        if let beerCell = tableView.cellForRow(at: indexPath) as? BeerTableViewCell {
            beerCell.setSelector(beerSelected[beerNdx])
        }
        self.listOfBeerOrPub = createListOfBeerOrPub(listOfBeers: listOfBeers, beerSelected: beerSelected)
        self.tableView.reloadData()
    }
    
    
}
