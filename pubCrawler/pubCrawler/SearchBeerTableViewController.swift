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
    var sectionSelected = Array<Bool>()
    var selectionButtons = Dictionary<Int, UIButton>()
    fileprivate var userId=UId()
    fileprivate var currentLocation=Location()
    let rightImage = UIImage(named: "right-circle-240")
    let downImage = UIImage(named: "down-circle-240")

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
                self.showErrorMessage(withMessage: "No beers found for '" + searchtext + "'", withTitle: "Couldn't find any beers")
            }
        } else {
            self.listOfBeers = listOfBeers
            self.sectionSelected = Array(repeating: false, count: listOfBeers.beerSections.count)
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
        if self.sectionSelected[section] {
        return self.listOfBeers.beerSections[section].listOfPubs.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return K.BeerHeadings.headingHeight
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headingView = self.createSectionHeadingView()
        let headingLabel = self.createSectionHeadingLabel(headingView: headingView, section: section)
        let buttonLabel = self.createHeadingButton(headingView: headingView, section: section, isSelected: sectionSelected[section])
        let underline = self.createUnderline(headingView: headingView)
        headingLabel.text = "  " + self.listOfBeers.beerSections[section].name
        headingView.addSubview(headingLabel)
        headingView.addSubview(buttonLabel)
        headingView.addSubview(underline)
        selectionButtons[section] = buttonLabel
        return headingView
    }

    private func createSectionHeadingView() -> UIView {
        let viewHeight = Double(K.BeerHeadings.headingHeight)
        let headingFrame = CGRect(x:0.0 , y: 0.0, width: Double(self.view.frame.size.width.native), height: viewHeight)
        let headingView = UIView(frame: headingFrame)
        return headingView
    }
    private func createSectionHeadingLabel(headingView:UIView, section:Int) -> UILabel {
        let headingFrame = headingView.frame
        let headingHeight = Double(headingFrame.size.height)
        let headingWidth = Double(headingFrame.size.width)
        
        let labelWidth = headingWidth// - K.BeerHeadings.buttonWidth
        let labelFrame = CGRect(x:0, y:0.0, width:labelWidth, height:headingHeight)
        
        let headingLabel = UILabel(frame: labelFrame)
        headingLabel.backgroundColor = K.BeerHeadings.backgroundColor
        headingLabel.textColor = K.BeerHeadings.fontColor
        headingLabel.tag = section
        headingLabel.isUserInteractionEnabled = true
        let tapGesture = HeadingLabelGestureRecogniser(target: self, action: #selector(pressedAction(gestureRecogniser:)))
        tapGesture.section = section
        headingLabel.addGestureRecognizer(tapGesture)
        return headingLabel
    }
    private func createHeadingButton(headingView:UIView, section:Int, isSelected:Bool) -> UIButton {
        let headingFrame = headingView.frame
        let headingHeight = Double(headingFrame.size.height)
        let headingWidth = Double(headingFrame.size.width)

        let buttonFrame = CGRect(x:headingWidth - K.BeerHeadings.buttonWidth, y:headingHeight * 0.25, width:K.BeerHeadings.buttonWidth * 0.5, height:headingHeight * 0.5)
        let headingButton = UIButton(frame: buttonFrame)
        headingButton.backgroundColor = K.BeerHeadings.backgroundColor
        headingButton.setImage(rightImage, for: .normal)
        if isSelected { headingButton.setImage(downImage, for: .normal)}
        else {headingButton.setImage(rightImage, for: .normal)}
        headingButton.setTitleColor(K.BeerHeadings.fontColor, for: .normal)
        headingButton.tag = section
        headingButton.addTarget(self, action: #selector(pressedAction(_:)), for: .touchUpInside)
        return headingButton
    }
    
    private func createUnderline(headingView:UIView) -> UIView {
        let headingFrame = headingView.frame
        let headingWidth = Double(headingFrame.size.width)

        let lineFrame = CGRect(x:0.0, y:0.0, width:headingWidth, height:1)
        let underline = UIView(frame: lineFrame)
        underline.backgroundColor = K.BeerHeadings.fontColor
        return underline
    }

    @objc func pressedAction(gestureRecogniser:UIGestureRecognizer) {
        if let headingLabelGestureRecogniser = gestureRecogniser as? HeadingLabelGestureRecogniser {
            changeStateOf(section: headingLabelGestureRecogniser.section)
        }
    }
    @objc func pressedAction(_ sender: UIView) {
        changeStateOf(section: sender.tag)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.tableView.reloadData()
    }
    
    func changeStateOf(section:Int) {
        self.sectionSelected[section] = !self.sectionSelected[section]
        let button = selectionButtons[section]
        let numberOfRows = self.listOfBeers.beerSections[section].listOfPubs.count
        var arrayIndexPaths = Array<IndexPath>()

        for i in 0..<numberOfRows {
            arrayIndexPaths.append(IndexPath(item:i, section:section))
        }
        self.tableView.beginUpdates()
        if self.sectionSelected[section] {
            button?.setImage(downImage, for: .normal)
            self.tableView.insertRows(at: arrayIndexPaths, with: .none)
        } else {
            button?.setImage(rightImage, for: .normal)
            self.tableView.deleteRows(at: arrayIndexPaths, with: .none)
        }
        self.tableView.endUpdates()

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
    
}
class HeadingLabelGestureRecogniser:UITapGestureRecognizer {
    var section:Int = 0
}
