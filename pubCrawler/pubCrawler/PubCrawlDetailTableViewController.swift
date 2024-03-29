//
//  PubCrawlDetailTableViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 27/02/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI

class PubCrawlDetailTableViewController: AbstractTableViewController, updatePubCrawlDelegate, removePubCrawlDelegate, updatePubsInPubCrawlDelegate, CopyPubCrawlDelegate, PubCrawlSettingTableViewCellDelegate, MFMailComposeViewControllerDelegate, getEmailTextDelegate  {
    
    @IBOutlet weak var mapButton: UIBarButtonItem!
    @IBOutlet weak var reOrderButton: UIBarButtonItem!
    @IBOutlet weak var joinButton: UIBarButtonItem!
    @IBOutlet weak var copyButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    var pubCrawl=PubCrawl()
    var pubCrawlNdx=0
    
    var headings = [String]()
    var listOfPubHeaders=ListOfPubs()
    
    fileprivate var editButton=UIBarButtonItem()
    fileprivate var saveButton=UIBarButtonItem()
    fileprivate var cancelButton=UIBarButtonItem()

    fileprivate var crawlNameChanged = false
    fileprivate var crawlSequenceChanged = false
    fileprivate var crawlSettingChanged = false
    fileprivate var isPublic = false
    
    fileprivate var pubCrawlNameTableViewCell:PubCrawlNameTableViewCell?
    fileprivate var pubCrawlSettingTableViewCell:PubCrawlSettingTableViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.pubCrawl.name.isEmpty)  {
            print("Error PubCrawlDetailTableViewController - pubCrawl not initialised before loading view")
        }
        self.navigationItem.title = ""
        
        self.editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(PubCrawlDetailTableViewController.editPressed))
        self.saveButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PubCrawlDetailTableViewController.donePressed))
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PubCrawlDetailTableViewController.cancelPressed))
        
        self.mapButton.isEnabled = false
        
        self.headings = [K.PubCrawlHeadings.newCrawlName]
        self.isPublic = self.pubCrawl.isPublic
        
        self.startCreatingListOfPubs()
    }
    
    func showDefaultButtons(){
        self.editButton.isEnabled = true
        self.navigationItem.rightBarButtonItem = self.editButton
        self.navigationItem.leftBarButtonItem=nil
            
        if self.listOfPubHeaders.isNotEmpty {
            self.mapButton.isEnabled = true
            if MFMailComposeViewController.canSendMail() {
               self.actionButton.isEnabled = true
            } else {
                self.actionButton.isEnabled = false
            }
        } else {
            self.mapButton.isEnabled = false
            self.actionButton.isEnabled = false
        }

        self.editButton.isEnabled =  (self.pubCrawl.canUpdate || self.pubCrawl.canUpdateSetting || self.pubCrawl.canRemove || self.pubCrawl.canRemovePubcrawl || self.pubCrawl.canSequencePubs)

        self.reOrderButton.isEnabled =  ((self.listOfPubHeaders.count > 2) && (self.pubCrawl.canSequencePubs) )

        self.joinButton.isEnabled = self.pubCrawl.canAddUser
        self.copyButton.isEnabled = self.pubCrawl.canCopy
        
        if self.isEditing {
            self.setEditing(false, animated: true)
        }
        
        self.copyButton.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.toolbar.isHidden = false
        
        if let navController = self.navigationController  {
            navController.isToolbarHidden = false
            self.startCreatingListOfPubs()
        }
       
        self.showDefaultButtons()
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
        
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.toolbar.isHidden = true
    }
    
    @objc func editPressed()
    {
        self.setEditing(true, animated: true)
        self.setNameAndSettingCells(isEnabled:true)
        
        self.navigationItem.rightBarButtonItem=self.saveButton
        self.navigationItem.leftBarButtonItem=self.cancelButton
        
        self.mapButton.isEnabled = false
        self.reOrderButton.isEnabled = false
        self.joinButton.isEnabled = false
        self.copyButton.isEnabled = false
        self.actionButton.isEnabled = false
    }
    
    @objc func donePressed()
    {
        self.setNameAndSettingCells(isEnabled:false)
        
        let newName = self.pubCrawlNameTableViewCell?.pubCrawlNameText.text ?? ""
                    
        if ((self.pubCrawl.name == newName ) && (!self.crawlSequenceChanged) && (!self.crawlSettingChanged) ){
            //nothings changed
            self.showDefaultButtons()
        } else {
            if self.pubCrawl.name != newName {
                if self.isValidPubCrawlName(pubCrawlName:newName) {
                    self.updatePubCrawl(name: newName)
                }
             }
            if self.crawlSequenceChanged {
                self.updatePubCrawlSequence()
            }
            if self.isPublic != self.pubCrawl.isPublic {
                self.updatePubCrawlSetting()
            }
        }
        
    }

    func isValidPubCrawlName(pubCrawlName:String) -> Bool {
        if pubCrawlName.isEmpty  {
            self.showErrorMessage(withMessage: "Pub crawl name can't be blank", withTitle:"Invalid name")
            return false
        } else {
            return true
        }
    }
    
    @objc func cancelPressed() {
        self.pubCrawlNameTableViewCell?.pubCrawlNameText.text = self.pubCrawl.name
        self.setNameAndSettingCells(isEnabled:false)
        self.showDefaultButtons()
    }
    
    func setNameAndSettingCells(isEnabled enabled:Bool) {
        self.pubCrawlNameTableViewCell?.pubCrawlNameText.isEnabled = self.pubCrawl.canUpdate
        self.pubCrawlSettingTableViewCell?.settingSwitch.isEnabled = self.pubCrawl.canUpdateSetting
        self.setEditing(enabled, animated: true)
    }
    
    func updatePubCrawl(name:String) {
        self.startActivityIndicator()
        ListOfPubCrawlsUpdater(delegate:self).update(pubCrawl: self.pubCrawl, newName: name)
    }
    func finishedUpdatingPubCrawlIn(listOfPubCrawls:ListOfPubCrawls) {
        self.stopActivityIndicator()

        self.pubCrawl = listOfPubCrawls.pubCrawls[self.pubCrawlNdx]
        self.showDefaultButtons()
        self.tableView.reloadData()
        
        _ = self.navigationController?.popViewController(animated: true)
    }

    func finishedCreating(pubCrawl:PubCrawl) {
        self.stopActivityIndicator()

        _ = self.navigationController?.popViewController(animated: true)

    }

    func updatePubCrawlSetting() {
        self.startActivityIndicator()
        ListOfPubCrawlsUpdater(delegate: self).updateSetting(forPubCrawl: self.pubCrawl)
    }
    
    func updatePubCrawlSequence() {
        self.startActivityIndicator()
        self.crawlSequenceChanged = false
        PubCrawlUpdater(withDelegate: self).resequence(pubCrawl:self.pubCrawl, listOfPubHeaders: self.listOfPubHeaders)
    }

    func finishedUpdating(listOfPubHeaders: ListOfPubs) {
        self.stopActivityIndicator()
        self.showDefaultButtons()

        self.listOfPubHeaders = listOfPubHeaders
        self.tableView.reloadData()
    }

    func deletePubCrawl()  {
        self.startActivityIndicator()
        PubCrawlDestroyer(withRemoveDelegate:self, pubCrawl:self.pubCrawl).remove()
    }
    
    func finishedRemovingPubCrawl(listOfPubCrawls:ListOfPubCrawls) {
        self.stopActivityIndicator()
   
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func removePub(withPubHeader pubHeader:PubHeader) {
        self.startActivityIndicator()
        PubCrawlUpdater(withDelegate:self).remove(pubHeader: pubHeader)
    }
       
    // The array of pubHeaders is updated if cells are moved.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
    
        let from = fromIndexPath.row
        let to = toIndexPath.row
        self.listOfPubHeaders  = self.listOfPubHeaders.movePubHeader(from:from, to:to)
        self.crawlSequenceChanged = true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return self.headings[indexPath.section] == K.PubCrawlHeadings.pubs
    }
    
    @IBAction func joinButtonPressed(_ sender: UIBarButtonItem) {
        self.joinPubCrawl()
    }
    func joinPubCrawl() {
        ListOfPubCrawlsUpdater(delegate: self).addUser(toPubCrawl: self.pubCrawl)
        self.startActivityIndicator()
    }
    
    @IBAction func actionButtonPressed(_ sender: AnyObject) {
        self.startActivityIndicator()
        self.emailPubCrawl()
    }
    
    func emailPubCrawl() {
        EmailCreator(withDelegate:self, pubCrawl:self.pubCrawl).getEmailText()
    }
    
    func finishedGetting(emailText:String) {
        self.stopActivityIndicator()
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([""])
            mail.setSubject("Pub crawl: " + self.pubCrawl.name)
            mail.setMessageBody(emailText, isHTML: true)
            present(mail, animated: true, completion: nil)
        } else {
            self.showErrorMessage(withMessage: "Could not create email", withTitle: "Unable to send mail")
        }
    }
    
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    @IBAction func reOrderButtonPressed(_ sender: UIBarButtonItem) {
        self.reorder()
    }
    
    @IBAction func copyButtonPressed(_ sender: UIBarButtonItem) {
        let alert = self.createCopyAlert()
        self.present(alert, animated: true)
    }
    func createCopyAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Copy pub crawl", message: "Are you sure you want top copy this pub crawl?", preferredStyle: .alert)
        let cancelCopy = (UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        let confirmCopy = (UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: self.copyConfirmed))
        alert.addAction(cancelCopy)
        alert.addAction(confirmCopy)
        return alert
    }
    func copyConfirmed(alert:UIAlertAction) {
        self.copyPubCrawl()
    }
    func copyPubCrawl() {
        self.startActivityIndicator()
        PubCrawlCopier(withDelegate:self).copy(pubCrawl:self.pubCrawl)
    }
    func finishedCopying(listOfPubCrawls:ListOfPubCrawls) {
        stopActivityIndicator()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segueId = segue.identifier {
            switch segueId {
            case K.SegueId.showPubCrawlMap:
                if let pubCrawlMapViewController = segue.destination as? PubCrawlMapViewController {
                    pubCrawlMapViewController.listOfPubHeaders = self.listOfPubHeaders
                    pubCrawlMapViewController.pubCrawlName = self.pubCrawl.name
                }
            case K.SegueId.showDetail:
                if let pubDetailTableViewController = segue.destination as? PubDetailTableViewController {
                    if let indexPath = self.tableView.indexPathForSelectedRow {
                        let row = indexPath.row
                        pubDetailTableViewController.pubHeader = self.listOfPubHeaders[row]
                    }
                }
            default:
                break
            }
        }
    }

    func reorder () {
        //this attempts to put pubs in distance order.
        self.listOfPubHeaders = self.listOfPubHeaders.reorder()
        self.tableView.reloadData()
        self.crawlSequenceChanged = true
        
        self.editPressed()
    }
    func pubCrawlSettingChanged(settingSwitch: UISwitch) {
        self.crawlSettingChanged = true
        self.isPublic = settingSwitch.isOn
    }
}

extension PubCrawlDetailTableViewController { //datasource methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.headings.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.headings[section] {
        case  K.PubCrawlHeadings.crawlName, K.PubCrawlHeadings.newCrawlName, K.PubCrawlHeadings.setting: 1
        case K.PubCrawlHeadings.pubs: self.listOfPubHeaders.count
        case K.PubCrawlHeadings.noPubs: 0
        default: 0
        }
    }
    
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
        return K.PubHeadings.height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.headings[indexPath.section] {
        case  K.PubCrawlHeadings.crawlName:
            createReadOnlyCrawlNameCell()
        case K.PubCrawlHeadings.newCrawlName:
            createEditableCrawlNameCell()
        case K.PubCrawlHeadings.pubs:
            createPubCellContainingPubDetail(indexPath: indexPath)
        case K.PubCrawlHeadings.setting:
            createPubCrawlSettingCell()
        default:
            UITableViewCell()
        }
    }
    
    func createReadOnlyCrawlNameCell() -> PubCrawlNameTableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "PubCrawlNameTableViewCell") as? PubCrawlNameTableViewCell
        else {   
            let cell = PubCrawlNameTableViewCell()
            self.pubCrawlNameTableViewCell = cell
            return cell
        }
        cell.pubCrawlNameText.text = self.pubCrawl.name
        cell.pubCrawlNameText.isEnabled = false
        cell.delegate = self
        self.pubCrawlNameTableViewCell = cell
        return cell
    }
    func createEditableCrawlNameCell() -> PubCrawlNameTableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "PubCrawlNameTableViewCell") as? PubCrawlNameTableViewCell
        else {
            let cell = PubCrawlNameTableViewCell()
            self.pubCrawlNameTableViewCell = cell
            return cell
        }
        cell.pubCrawlNameText.isEnabled = true
        cell.delegate = self
        self.pubCrawlNameTableViewCell = cell
        return cell
    }
    func createPubCellContainingPubDetail(indexPath: IndexPath) -> PubNameTableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "PubNameTableViewCell") as? PubNameTableViewCell else {return PubNameTableViewCell()}
        cell.textLabel!.text = self.listOfPubHeaders[indexPath.row].name
        cell.detailTextLabel!.text = self.listOfPubHeaders.distanceToPreveiousPubText(atIndex:indexPath.row)
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        cell.selectionStyle = .default
        return cell
    }
    func createPubCrawlSettingCell() -> PubCrawlSettingTableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "PubCrawlSettingTableViewCell") as? PubCrawlSettingTableViewCell
        else {
            let cell = PubCrawlSettingTableViewCell()
            self.pubCrawlSettingTableViewCell = cell
            return cell
        }
        cell.settingSwitch.isEnabled = self.isEditing
        cell.settingSwitch.isOn = self.pubCrawl.isPublic
        cell.delegate = self

        self.pubCrawlSettingTableViewCell = cell
        return cell
    }
 
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        canEdit(heading: self.headings[indexPath.section], atRow: indexPath)
    }
    func canEdit(heading: String, atRow indexPath: IndexPath) -> Bool {
        switch heading {
        case K.PubCrawlHeadings.crawlName:
            self.pubCrawl.canRemove
        case K.PubCrawlHeadings.setting:
            false
        case K.PubCrawlHeadings.pubs:
            self.listOfPubHeaders.pubHeaders[indexPath.row].canRemovePub
        default:
            true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch self.headings[indexPath.section] {
            case K.PubCrawlHeadings.crawlName:
                 self.deletePubCrawl()
            case K.PubCrawlHeadings.pubs:
                let pubHeader = self.listOfPubHeaders[indexPath.row]
                self.removePub(withPubHeader: pubHeader)
            default:
                break
            }
        }
    }
    
}

extension PubCrawlDetailTableViewController:ListOfPubsCreatorDelegate { //delegate methods for listOfPubHeadersCreator
    func startCreatingListOfPubs()  {
        self.startActivityIndicator()
        ListOfPubsCreator(withDelegate:self).createList(usingPubCrawl:self.pubCrawl)
    }
    
    func finishedCreating(listOfPubHeaders:ListOfPubs) {
        self.stopActivityIndicator()

        self.listOfPubHeaders = listOfPubHeaders

        if listOfPubHeaders.isNotEmpty {
            self.headings = [K.PubCrawlHeadings.crawlName, K.PubCrawlHeadings.pubs]
        } else {
            self.headings = [K.PubCrawlHeadings.crawlName, K.PubCrawlHeadings.noPubs]
        }
        if self.pubCrawl.canUpdateSetting {
            self.headings.append(K.PubCrawlHeadings.setting)
        }
        
        self.showDefaultButtons()
        self.tableView.reloadData()
    }
    
}

extension PubCrawlDetailTableViewController:PubCrawlNameTableViewCellDelegate { //delegate methods for pubCrawlNameTableViewCell
    func nameChanged(name:String) {
        self.navigationItem.rightBarButtonItem = self.saveButton
        self.crawlNameChanged = true
    }
}




