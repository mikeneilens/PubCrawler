//
//  DetailTableTableViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 20/02/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit

class PubDetailTableViewController: AbstractTableViewController {

    var pubHeader = PubHeader() // set up by creator
    
    var pub = Pub() { //always refresh headings if pub data changed
        didSet {
            self.headings = self.createHeadings()
        }
    }
    
    var showAllAbout = false
    
    var headings=[String]()
    fileprivate var pictureCell=PictureTableViewCell()
    var hygieneRatings=ListOfFoodHygieneRatings()
    fileprivate var editButton=UIBarButtonItem()
    fileprivate var nextButton=UIBarButtonItem()
    fileprivate var cancelButton=UIBarButtonItem()
    fileprivate var dataSourceNeedsUpdating=false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.pubHeader.name.isEmpty) {
            print("Error PubDetailTableViewController - userId and pubHeader not initialised before loading view")
        }
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.navigationItem.title = self.pubHeader.name
        
        self.editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(PubDetailTableViewController.editPressed))
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PubDetailTableViewController.cancelPressed))
        self.nextButton = UIBarButtonItem(title:"Next", style:.plain ,target: self, action: #selector(PubDetailTableViewController.nextPressed))

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.startCreating(pubWithPubHeader:self.pubHeader)
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier {
            
            switch segueId {
            case K.SegueId.showMap:
                if let mapVC = segue.destination as? MapViewController {
                    mapVC.location = self.pub.pubHeader.location
                    mapVC.name = self.pub.pubHeader.name
                    mapVC.address = self.pub.address
                }
                break
            case K.SegueId.showPicture:
                if let pictureVC = segue.destination as? PictureViewController {
                    pictureVC.photoURL = self.pub.photoURL
                }
                break
            case K.SegueId.showPubsNearby:
                if let searchVC = segue.destination as? SearchTableViewController {
                    searchVC.pub = self.pub
                }
                break
            case K.SegueId.showPubCrawlForPub:
                if let pubCrawlDetailVC = segue.destination as? PubCrawlDetailTableViewController {
                    let indexPath = self.tableView.indexPathForSelectedRow
                    if let ndx = indexPath?.row {
                        pubCrawlDetailVC.pubCrawl = self.pub.listOfPubCrawls.pubCrawls[ndx]
                    }
                }
            default:
                break
            }
        }
    }
    
    func createHeadings() -> [String] {
        
        var newHeadings = [String]()
        //The order that headings are added to the array determines the order that they are displayed
        if self.pub.address.isNotEmpty        {newHeadings.append(K.PubHeadings.address)}
        if self.pub.pubHeader.name.isNotEmpty {newHeadings.append(K.PubHeadings.pubCrawls)}
        if self.pub.about.isNotEmpty          {newHeadings.append(K.PubHeadings.about)}
        if self.pub.telephone.isNotEmpty      {newHeadings.append(K.PubHeadings.telephone)}
        if self.pub.openingTimes.isNotEmpty   {newHeadings.append(K.PubHeadings.openingTime)}
        if self.pub.address.isNotEmpty        {newHeadings.append(K.PubHeadings.foodHygieneRating)}
        if self.pub.mealTimes.isNotEmpty      {newHeadings.append(K.PubHeadings.mealTime)}
        if self.pub.owner.isNotEmpty          {newHeadings.append(K.PubHeadings.owner)}
        if self.pub.beer.isNotEmpty           {newHeadings.append(K.PubHeadings.beersHeading)}
        if self.pub.guest.isNotEmpty          {newHeadings.append(K.PubHeadings.guests)}
        if ( ((pub.address.isNotEmpty) && (pub.pubsNearByIsAvailable)) || (pub.feature.isNotEmpty)) {newHeadings.append(K.PubHeadings.features)}
        if self.pub.facility.isNotEmpty       {newHeadings.append(K.PubHeadings.facilities)}
        if self.pub.pubHeader.name.isNotEmpty {newHeadings.append(K.PubHeadings.visitHistory)}
        return newHeadings
    }
    
    @objc func editPressed() {
        self.isEditing = true
        self.navigationItem.rightBarButtonItem = self.cancelButton
    }
    @objc func cancelPressed() {
        self.isEditing = false
        self.navigationItem.rightBarButtonItem = self.editButton
    }
    @objc func nextPressed() {
        self.startCreatingNext(pub:self.pub)
    }

}

extension PubDetailTableViewController:PubCreatorDelegate { //delegate methods for pubCreator
    func startCreating(pubWithPubHeader pubHeader:PubHeader) {
        self.startActivityIndicator()
        PubCreator(withDelegate: self, forPubHeader:pubHeader).createPub()
    }
    func startCreatingNext(pub:Pub) {
        self.startActivityIndicator()
        PubCreator(withDelegate: self, forPubHeader:pub.pubHeader).createNext(pub:pub)
    }
    
    func finishedCreating(newPub pub:Pub) {
        self.stopActivityIndicator()
        
        self.pubHeader = pub.pubHeader
        self.pub = pub

        self.navigationItem.title = self.pubHeader.name
        self.setRightBarButton()
        
        self.hygieneRatings = ListOfFoodHygieneRatings(withHygieneRating: FoodHygieneRating())
        self.tableView.reloadData()

        self.getFoodHygieneRatings(forPub: pub)
    }
    
    private func setRightBarButton() {
        self.navigationItem.rightBarButtonItem = nil
        if self.isNextPub {
            self.showNextButton()
        } else {
            if self.canRemovePubCrawl {
                self.showEditButton()
            }
        }
    }
    private func showEditButton() {
        self.navigationItem.rightBarButtonItem = self.editButton
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    private func showNextButton() {
        self.navigationItem.rightBarButtonItem = self.nextButton
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    var canRemovePubCrawl:Bool {
        for pubCrawl in self.pub.listOfPubCrawls.pubCrawls {
            if pubCrawl.canRemovePubcrawl {
                return true
            }
        }
        return false
    }
    var isNextPub:Bool {
        self.pub.nextPubService.isNotEmpty
    }
}

extension PubDetailTableViewController:FoodHygieneRatingsCreatorDelegate { //delegate methods for foodHygieneCreator
    func getFoodHygieneRatings(forPub pub:Pub) {
        //don't use activity indicator in case the service is down.
        FoodHygieneRatingsCreator(delegate: self).createListOfFoodHygieneRatings(forPub:pub)
    }
    func finishedCreating(listOfFoodHygieneRatings:ListOfFoodHygieneRatings) {
        self.hygieneRatings = listOfFoodHygieneRatings
        self.tableView.reloadData()
    }
}

extension PubDetailTableViewController { //tableViewDelegate methods
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headingView = self.createSectionHeadingView()
        let headingLabel = self.createSectionHeadingLabel(headingView: headingView)

        headingLabel.text = self.headings[section]
        headingView.addSubview(headingLabel)
        
        return headingView
    }
    private func createSectionHeadingView() -> UIView {
        let viewHeight = Double(K.PubHeadings.height)
        let headingFrame = CGRect(x:0.0 , y: 0.0, width: Double(self.view.frame.size.width.native), height: viewHeight)
        
        let headingView = UITableViewHeaderFooterView(frame: headingFrame)
        return headingView
    }
    private func createSectionHeadingLabel(headingView:UIView) -> UILabel {
        let headingFrame = headingView.frame
        let headingHeight = Double(headingFrame.size.height)

        let leftMargin:Double = 8.0
        let rightMargin:Double = 8.0
        let labelWidth = Double(headingFrame.size.width.native) - leftMargin - rightMargin
        let labelFrame = CGRect(x:leftMargin, y:0.0, width:labelWidth, height:headingHeight)
        let headingLabel = UILabel(frame: labelFrame)
        headingLabel.font = UIFont.systemFont(ofSize: headingLabel.font!.pointSize, weight: .bold)
        return headingLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        K.PubHeadings.height
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (row, section) = indexPath.rowAndSection
        
        switch self.headings[section] {
        case K.PubHeadings.about:
            self.showAllAbout = !self.showAllAbout
            self.tableView.reloadData()
        case K.PubHeadings.pubCrawls:
            if row == self.pub.listOfPubCrawls.count {
                self.displayAddToPubCrawlAlert()
            }
        case K.PubHeadings.telephone:
            self.callNumber(phoneNumber: self.pub.telephone)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let (row, section) = indexPath.rowAndSection
        
        let heading = self.headings[section]
        
        if heading == K.PubHeadings.pubCrawls {
            if  row < self.pub.listOfPubCrawls.count {
                let pubCrawl = self.pub.listOfPubCrawls[row]
                if pubCrawl.canRemovePubcrawl {
                    return true
                }
            }
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let (row, section) = indexPath.rowAndSection
        
        if editingStyle == .delete {
            
            let heading = self.headings[section]
            
            if heading == K.PubHeadings.pubCrawls {
                let pubCrawl = self.pub.listOfPubCrawls[row]
                self.remove(pubCrawl:pubCrawl)
            }
        }
    }

    private func callNumber(phoneNumber:String) {
        if let url = URL(string:"telprompt://" + phoneNumber), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
extension PubDetailTableViewController:ItemSwitchCellDelegate { //delegate that deals with visited or liked switch being changed
    
    func buttonPressed(ndx:Int, switchOn:Bool) {
        
        switch ndx {
        case K.PubHeadings.visitedRow:
            self.startActivityIndicator()
            PubUpdater(pub: self.pub, withDelegate: self).updateVisit()
        case K.PubHeadings.likedRow:
            self.startActivityIndicator()
            PubUpdater(pub: self.pub, withDelegate: self).updateLiked( )
        default:
            break
        }
    }
}

extension PubDetailTableViewController:UpdatePubDelegate { //delegate called anytime pub is changed, eg. pub crawl added or pub visited
    func finishedUpdating(pub:Pub) {
        
        self.stopActivityIndicator()
        self.pub = pub
        self.tableView.reloadData()
    }
}

extension PubDetailTableViewController:AddToPubCrawlDelegate { //creates the listAlertViewController and contains delegates

    func displayAddToPubCrawlAlert() {
        let addToPubCrawlViewController = AddToPubCrawlViewController(title: "", message: "", preferredStyle: .actionSheet)
        addToPubCrawlViewController.delegate = self
        addToPubCrawlViewController.listOfPubCrawls = self.pub.listOfOtherPubCrawls
        
        if let popoverController = addToPubCrawlViewController.popoverPresentationController { //needed for iPad
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.bounds.width / 4, y: self.tableView.bounds.height / 2, width: 1.0, height: 1.0)
        }
        
        self.present(addToPubCrawlViewController, animated:true, completion:nil)
    }

    func pubCrawlAdded(atIndex ndx:Int){
        self.startActivityIndicator()
        PubUpdater(pub: self.pub, withDelegate: self).add(pubCrawlAtNdx:ndx)
    }
    
    func createPubCrawl(){
        self.displacyCreatePubCrawlViewController()
    }

}

extension PubDetailTableViewController { //method to create a new pub crawl
    func displacyCreatePubCrawlViewController() {
        let createPubCrawlVC = self.storyboard?.instantiateViewController(withIdentifier: "CreatePubCrawlViewController") as! CreatePubCrawlViewController
        createPubCrawlVC.pub = self.pub
        self.navigationController?.pushViewController(createPubCrawlVC, animated: true)
    }
}

extension PubDetailTableViewController { //method for removing pub from a pub crawl
    func remove(pubCrawl:PubCrawl) {
        self.cancelPressed()
        self.startActivityIndicator()
        PubUpdater(pub: self.pub, withDelegate: self).remove(pubCrawl:pubCrawl)
    }
}

extension PubDetailTableViewController:PubImageLoadedDelegate {
    func pubImageLoaded(imageStatus: ImageStatus) {
        
        switch imageStatus {
        case .noPubImage:
            self.pictureCell.pictureLabel.text = "Picture not available"
            self.pictureCell.pictureImage.isHidden = true
            self.pictureCell.isUserInteractionEnabled = false
        case .imageLoaded:
            self.pictureCell.pictureLabel.text = "Show picture..."
            self.pictureCell.pictureImage.isHidden = false
            self.pictureCell.isUserInteractionEnabled = true
        case .imageNotLoaded:
            self.pictureCell.pictureLabel.text = "Picture loading"
            self.pictureCell.pictureImage.isHidden = true
            self.pictureCell.isUserInteractionEnabled = false
        }
    }
}

extension PubDetailTableViewController { //datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        self.headings.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return switch self.headings[section]
        {
        case K.PubHeadings.beersHeading:
            self.pub.beer.count
        case K.PubHeadings.address:
            if self.pub.photoURL.isNotEmpty {
                3
            } else {
                2
            }
        case K.PubHeadings.guests:
            self.pub.guest.count
        case K.PubHeadings.features:
            if self.pub.pubsNearByIsAvailable {
                self.pub.feature.count + 1
            } else {
                self.pub.feature.count
            }
        case K.PubHeadings.facilities:
            self.pub.facility.count
        case K.PubHeadings.pubCrawls:
            self.pub.listOfPubCrawls.count + 1
        case K.PubHeadings.foodHygieneRating:
            self.hygieneRatings.foodHygieneRatings.count
        case K.PubHeadings.visitHistory:
            2
        default:
            1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (row, section) = indexPath.rowAndSection
        
        let pubDetailcell = tableView.dequeueReusableCell(withIdentifier: "pubDetailCell", for: indexPath)
        
        switch self.headings[section]
        {
        case K.PubHeadings.address:
            switch row {
            case K.PubHeadings.addressRow:
                return self.createAddressCell(tableView, indexPath: indexPath)
            case K.PubHeadings.mapRow:
                return tableView.dequeueReusableCell(withIdentifier: "pubShowOnMapCell", for: indexPath)
            case K.PubHeadings.pictureRow:
                return self.createPictureCell(tableView, indexPath:indexPath)
            default:
                break
            }
        case K.PubHeadings.telephone:
            let telephoneCell = tableView.dequeueReusableCell(withIdentifier: "telephoneCell", for: indexPath)
            telephoneCell.textLabel!.text = self.pub.telephone
            return telephoneCell
        case K.PubHeadings.openingTime:
            return self.createOpeningTimesCell(tableView, indexPath: indexPath, openingTimes: self.pub.openingTimes)
        case K.PubHeadings.mealTime:
            return self.createOpeningTimesCell(tableView, indexPath: indexPath, openingTimes: self.pub.mealTimes)
        case K.PubHeadings.owner:
            pubDetailcell.textLabel!.text = self.pub.owner
        case K.PubHeadings.about:
            if (showAllAbout) {
                return self.createLongAboutCell(tableView, indexPath:indexPath)
            } else {
                return self.createShortAboutCell(tableView, indexPath:indexPath)
            }
        case K.PubHeadings.beersHeading:
            pubDetailcell.textLabel!.text = textIn(pubArray:self.pub.beer, atNdx: row)
        case K.PubHeadings.guests:
            pubDetailcell.textLabel!.text = textIn(pubArray:self.pub.guest, atNdx: row)
        case K.PubHeadings.features:
            return self.createFeaturesCell(tableView, indexPath: indexPath)
        case K.PubHeadings.facilities:
            pubDetailcell.textLabel!.text = textIn(pubArray:self.pub.facility, atNdx: row)
        case K.PubHeadings.pubCrawls:
            return self.createPubCrawlCell(tableView, indexPath: indexPath)
        case K.PubHeadings.foodHygieneRating:
            return self.createFoodHygieneRatingCell(tableView, indexPath: indexPath)
        case K.PubHeadings.visitHistory:
            return self.createVisitHistoryCell(tableView, indexPath: indexPath)
        default:
            pubDetailcell.textLabel!.text = "n/a"
        }
        return pubDetailcell
    }
    
    func createLongAboutCell(_ tableView: UITableView, indexPath:IndexPath) ->UITableViewCell {
        let longAboutCell = tableView.dequeueReusableCell(withIdentifier: "longAboutCell", for: indexPath)
        if let cell = longAboutCell as? LongAboutTableViewCell {
            cell.variableSizeTextLabel.text = self.pub.about
            cell.setLabelType(isMultirow: self.showAllAbout)
            return cell
        } else {
            return longAboutCell
        }
    }
    
    func createShortAboutCell(_ tableView: UITableView, indexPath:IndexPath) -> UITableViewCell {
        let shortAboutCell = tableView.dequeueReusableCell(withIdentifier: "shortAboutCell", for: indexPath)
        shortAboutCell.textLabel!.text = self.pub.about
        
        return if let cellLabel = shortAboutCell.textLabel {
            if cellLabel.isTruncated() {
                self.createLongAboutCell(tableView, indexPath: indexPath)
            } else {
                shortAboutCell
            }
        } else {
            shortAboutCell
        }
    }
    
    func createAddressCell(_ tableView: UITableView, indexPath:IndexPath) -> UITableViewCell {
        let addressCell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath)
        return if let cell = addressCell as? AddressTableViewCell {
            configuredAddressCell(addressCell: cell)
        } else {
            addressCell
        }
    }
    func configuredAddressCell(addressCell: AddressTableViewCell) -> AddressTableViewCell {
        addressCell.variableSizeTextLabel.text = self.pub.address
        addressCell.setLabelType(isMultirow: true)
        return addressCell
    }
    
    func createOpeningTimesCell(_ tableView: UITableView, indexPath:IndexPath, openingTimes:String ) -> UITableViewCell {
        let openingTimesCell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath)
        return if let cell = openingTimesCell as? AddressTableViewCell {
            configuredOpeningTimeCell(openingTimesCell: cell, openingTimes: openingTimes)
        } else {
            openingTimesCell
        }
    }
    func configuredOpeningTimeCell(openingTimesCell: AddressTableViewCell, openingTimes:String ) -> AddressTableViewCell {
        openingTimesCell.variableSizeTextLabel.text = openingTimes.splitIntoLines()
        openingTimesCell.setLabelType(isMultirow: true)
        return openingTimesCell
    }
    
    func createPictureCell(_ tableView: UITableView, indexPath:IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "pubShowPictureCell", for: indexPath) as? PictureTableViewCell {
            configuredPictureCell(cell: cell)
        } else {
            tableView.dequeueReusableCell(withIdentifier: "pubDetailCell", for: indexPath)
        }
    }
    func configuredPictureCell(cell: PictureTableViewCell) -> PictureTableViewCell {
        self.pictureCell = cell
        self.pictureCell.pictureLabel.text = "Picture loading"
        self.pictureCell.pictureImage.downloadedFrom(link: self.pub.photoURL, delegate:self)
        return self.pictureCell
    }
    
    func createFoodHygieneRatingCell(_ tableView: UITableView, indexPath:IndexPath) -> UITableViewCell {
        let row = indexPath.row
        return if  self.hygieneRatings.foodHygieneRatings[row].ratingKey.isEmpty {
            configureHygieneCellForNoRating(indexPath: indexPath)
        } else {
            configureHygieneCellForRating(indexPath: indexPath)
        }
    }
    func configureHygieneCellForNoRating(indexPath:IndexPath) -> UITableViewCell {
        let pubDetailCell =  tableView.dequeueReusableCell(withIdentifier: "pubDetailCell", for: indexPath)
        pubDetailCell.textLabel!.text = self.hygieneRatings.foodHygieneRatings[indexPath.row].displayText
        return pubDetailCell
    }
    func configureHygieneCellForRating(indexPath: IndexPath) -> UITableViewCell {
        let hygieneRatingCell = tableView.dequeueReusableCell(withIdentifier: "hygieneRatingCell", for: indexPath)
        return if let cell = hygieneRatingCell as? HygieneRatingCell {
            configuredHygieneCellWithRating(cell: cell, indexPath: indexPath)
        } else {
            tableView.dequeueReusableCell(withIdentifier: "pubDetailCell", for: indexPath)
        }
    }
    func configuredHygieneCellWithRating(cell: HygieneRatingCell, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        cell.hygieneRatingLabel.text = self.hygieneRatings.foodHygieneRatings[row].displayText
        cell.hygieneRatingDateLabel.text = self.hygieneRatings.foodHygieneRatings[row].displayDate
        let imageURL = self.hygieneRatings.foodHygieneRatings[row].displayImageURL
        cell.hygieneRatingImage.downloadedFrom(link: imageURL)
        return cell
    }
    
    func createFeaturesCell(_ tableView: UITableView, indexPath:IndexPath) ->UITableViewCell {
        if indexPath.row < self.pub.feature.count {
            configureFeatureCell(tableView, indexPath: indexPath)
        } else {
            tableView.dequeueReusableCell(withIdentifier: "pubsNearByCell", for: indexPath)
        }
    }
    func configureFeatureCell(_ tableView: UITableView, indexPath:IndexPath) ->UITableViewCell {
        let pubDetailCell =  tableView.dequeueReusableCell(withIdentifier: "pubDetailCell", for: indexPath)
        pubDetailCell.textLabel!.text = self.pub.feature[indexPath.row]
        return pubDetailCell
    }
    
    func createPubCrawlCell(_ tableView: UITableView, indexPath:IndexPath) ->UITableViewCell {
        if indexPath.row < self.pub.listOfPubCrawls.count {
            configurePubCrawlell(tableView, indexPath: indexPath)
        } else {
            tableView.dequeueReusableCell(withIdentifier: "pubUpdatePubCrawlsCell", for: indexPath)
        }
    }
    func configurePubCrawlell(_ tableView: UITableView, indexPath:IndexPath) ->UITableViewCell {
        let pubDetailCell =  tableView.dequeueReusableCell(withIdentifier: "pubCrawlCell", for: indexPath)
        let pubCrawl = self.pub.listOfPubCrawls[indexPath.row]
        pubDetailCell.textLabel!.text = pubCrawl.name
        return pubDetailCell
    }
    
    func createVisitHistoryCell(_ tableView: UITableView, indexPath:IndexPath) -> UITableViewCell{
        switch indexPath.row {
        case K.PubHeadings.visitedRow:
            createVisitedCell(tableView, indexPath: indexPath)
        case K.PubHeadings.likedRow:
            createLikedCell(tableView, indexPath: indexPath)
        default:
            tableView.dequeueReusableCell(withIdentifier: "pubDetailCell", for: indexPath)
        }
    }
    func createVisitedCell(_ tableView: UITableView, indexPath:IndexPath) -> ItemSwitchCell {
        let itemSwitchCell =  tableView.dequeueReusableCell(withIdentifier: "itemSwitchCell", for: indexPath)
        let pubItemSwitchCell = itemSwitchCell as! ItemSwitchCell
        pubItemSwitchCell.initialValues(text:"Visited?:", isOn:self.pub.visited, trueText:"Yes", falseText:"No", ndx:K.PubHeadings.visitedRow, delegate:self)
        return pubItemSwitchCell
    }
    func createLikedCell(_ tableView: UITableView, indexPath:IndexPath) -> ItemSwitchCell {
        let itemSwitchCell =  tableView.dequeueReusableCell(withIdentifier: "itemSwitchCell", for: indexPath)
        let pubItemSwitchCell = itemSwitchCell as! ItemSwitchCell
        pubItemSwitchCell.initialValues(text:"Like it?:", isOn:self.pub.liked, trueText:"Yes", falseText:"No", ndx:K.PubHeadings.likedRow, delegate:self)
        return pubItemSwitchCell
    }
    
    //This safely returns a string from an array, giving "" if the index is out of bounds
    func textIn(pubArray:[String], atNdx ndx:Int)-> String {
        if ndx < pubArray.count {
            pubArray[ndx]
        } else {
            ""
        }
    }
}
