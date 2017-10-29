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

class PubCrawlDetailTableViewController: AbstractTableViewController, updatePubCrawlDelegate, removePubCrawlDelegate, removePubFromPubCrawlDelegate, resequencePubsDelegate,addUsertoPubCrawlDelegate, copyPubCrawlDelegate, PubCrawlSettingTableViewCellDelegate, updatePubCrawlSettingDelegate, MFMailComposeViewControllerDelegate, getEmailTextDelegate  {
   
    
    @IBOutlet weak var mapButton: UIBarButtonItem!
    @IBOutlet weak var reOrderButton: UIBarButtonItem!
    @IBOutlet weak var joinButton: UIBarButtonItem!
    @IBOutlet weak var copyButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    var pubCrawl=PubCrawl()
    var pubCrawlNdx=0
    
    fileprivate var headings = [String]()
    fileprivate var listOfPubHeaders=ListOfPubs()
    
    fileprivate var editButton=UIBarButtonItem()
    fileprivate var saveButton=UIBarButtonItem()
    fileprivate var cancelButton=UIBarButtonItem()

    fileprivate var crawlNameChanged = false
    fileprivate var crawlSequenceChanged = false
    fileprivate var crawlSettingChanged = false
    fileprivate var isPublic = false
    
    fileprivate var pubCrawlNameTableViewCell:PubCrawlNameTableViewCell?
    fileprivate var pubCrawlSettingTableViewCell:PubCrawlSettingTableViewCell?

    let crawlNameHeading="Name"
    let newCrawlNameHeading="Please enter a pub crawl name"
    let pubsHeading="Pubs"
    let noPubsHeading="No pubs on this pub crawl"
    let settingHeading="Pub Crawl Settings"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.pubCrawl.name.isEmpty)  {
            print("Error PubCrawlDetailTableViewController - pubCrawl not initialised before loading view")
        }
        
        self.editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(PubCrawlDetailTableViewController.editPressed))
        self.saveButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PubCrawlDetailTableViewController.donePressed))
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PubCrawlDetailTableViewController.cancelPressed))
        
        self.mapButton.isEnabled = false
        
        self.headings = [self.newCrawlNameHeading]
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
        
        if let tabBar = self.tabBarController?.tabBar {
            tabBar.isHidden = true
        }
        if let toolBar = self.navigationController?.toolbar {
            toolBar.isHidden = false
        }
        
        if let navController = self.navigationController  {
            navController.isToolbarHidden = false
            self.startCreatingListOfPubs()
        }
       
        self.showDefaultButtons()
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
            self.resignFirstResponder()

        if let tabBar = self.tabBarController?.tabBar {
            tabBar.isHidden = false
        }
        if let toolBar = self.navigationController?.toolbar {
            toolBar.isHidden = true
        }
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
        
        var newName = ""
        if let pubCrawlNameCell = self.pubCrawlNameTableViewCell {
            newName = pubCrawlNameCell.pubCrawlNameText.text!
        }
                    
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
        if let pubCrawlNameCell = self.pubCrawlNameTableViewCell {
            pubCrawlNameCell.pubCrawlNameText.text = self.pubCrawl.name
        }
        self.setNameAndSettingCells(isEnabled:false)
        self.showDefaultButtons()
    }
    
    func setNameAndSettingCells(isEnabled enabled:Bool) {
        if let pubCrawlNameCell = self.pubCrawlNameTableViewCell {
            pubCrawlNameCell.pubCrawlNameText.isEnabled = self.pubCrawl.canUpdate
        }
        
        if let pubCrawlSettingCell = self.pubCrawlSettingTableViewCell {
            pubCrawlSettingCell.settingSwitch.isEnabled = self.pubCrawl.canUpdateSetting
        }
        
        self.setEditing(enabled, animated: true)
        
    }
    
    func updatePubCrawl(name:String) {
        self.startActivityIndicator()
        ListOfPubCrawlsCreator(delegate:.update(self)).update(pubCrawl: self.pubCrawl, newName: name)
    }
    func finishedUpdatingPubCrawlName(listOfPubCrawls:ListOfPubCrawls) {
        self.stopActivityIndicator()

        self.pubCrawl = listOfPubCrawls.pubCrawls[self.pubCrawlNdx]
        self.showDefaultButtons()
        self.tableView.reloadData()
        
        NotificationCenter.default.post(changedListOfPubCrawls: listOfPubCrawls)
        
        _ = self.navigationController?.popViewController(animated: true)
    }

    func finishedCreating(pubCrawl:PubCrawl) {
        self.stopActivityIndicator()

        NotificationCenter.default.post(addedPubCrawl:pubCrawl)
        
        _ = self.navigationController?.popViewController(animated: true)

    }

    func updatePubCrawlSetting() {
        self.startActivityIndicator()
        ListOfPubCrawlsCreator(delegate: .updateSetting(self)).updateSetting(forPubCrawl: self.pubCrawl)
    }
    func finishedUpdatingPubCrawlSetting(listOfPubCrawls:ListOfPubCrawls) {
        self.stopActivityIndicator()
    
        self.pubCrawl = listOfPubCrawls.pubCrawls[self.pubCrawlNdx]
        self.showDefaultButtons()
        self.tableView.reloadData()
        
        NotificationCenter.default.post(changedListOfPubCrawls: listOfPubCrawls)
    }
    
    func updatePubCrawlSequence() {
        self.startActivityIndicator()
        PubCrawlUpdater(withDelegate: .resequence(self)).resequence(pubCrawl:self.pubCrawl, listOfPubHeaders: self.listOfPubHeaders)
    }
    func finishedResequencing(listOfPubHeaders:ListOfPubs) {
        self.stopActivityIndicator()
        self.crawlSequenceChanged = false
        self.showDefaultButtons()

        self.listOfPubHeaders = listOfPubHeaders
        self.tableView.reloadData()
    }

    func deletePubCrawl()  {
        self.startActivityIndicator()
        PubCrawlDestroyer(withRemoveDelegate:self, pubCrawl:self.pubCrawl).remove()
    }
    
    func finishedRemovingPubCrawl(fromPub pub: Pub) {
        self.stopActivityIndicator()
        self.listOfPubHeaders = self.listOfPubHeaders.remove(pubHeader:pub.pubHeader)
        self.tableView.reloadData()
        
        NotificationCenter.default.post(changedPubCrawl: self.pubCrawl, with:pub.pubHeader)

    }
    
    func finishedRemovingPubCrawl(listOfPubCrawls:ListOfPubCrawls) {
        self.stopActivityIndicator()
   
        NotificationCenter.default.post(changedListOfPubCrawls: listOfPubCrawls)
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func removePub(withPubHeader pubHeader:PubHeader) {
        self.startActivityIndicator()
        PubCrawlUpdater(withDelegate: .removePubFromPubCrawl(self)).remove(pubHeader: pubHeader)
    }
    
    func finishedRemovingPubFromPubCrawl(listOfPubHeaders: ListOfPubs) {
        self.stopActivityIndicator()
        self.listOfPubHeaders = listOfPubHeaders
        self.tableView.reloadData()
    }
   
    // The array of pubHeaders is updated if cells are moved.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
    
        let from = fromIndexPath.row
        let to = toIndexPath.row
        self.listOfPubHeaders  = self.listOfPubHeaders.movePubHeader(from:from, to:to)
        self.crawlSequenceChanged = true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        
        if self.headings[section] == self.pubsHeading {
            return true
        }
        return false
    }
    
    @IBAction func joinButtonPressed(_ sender: UIBarButtonItem) {
        self.joinPubCrawl()
    }
    func joinPubCrawl() {
        ListOfPubCrawlsCreator(delegate: .addUser(self)).addUser(toPubCrawl: self.pubCrawl)
        self.startActivityIndicator()
    }
    func finishedAddingUser(listOfPubCrawls:ListOfPubCrawls){
        stopActivityIndicator()
        joinButton.isEnabled = false
        
        NotificationCenter.default.post(changedListOfPubCrawls: listOfPubCrawls)
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
        self.copyPubCrawl()
    }
    
    func copyPubCrawl() {
        self.startActivityIndicator()
        PubCrawlCreator(withDelegate: .copy(self)).copy(pubCrawl:self.pubCrawl)
    }
    func finishedCopying(listOfPubCrawls:ListOfPubCrawls) {
        stopActivityIndicator()
        NotificationCenter.default.post(changedListOfPubCrawls: listOfPubCrawls)

        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
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
        var rows = 0
        switch self.headings[section] {
        case  self.crawlNameHeading:
            rows = 1
        case self.newCrawlNameHeading:
            rows = 1
        case self.pubsHeading:
            rows = self.listOfPubHeaders.count
        case self.noPubsHeading:
            rows = 0
        case self.settingHeading:
            rows = 1
        default:
            break
        }
        return rows
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let heading = UILabel()
        heading.backgroundColor = K.headingBackgroundColor
        heading.textColor = K.headingFontColor
        heading.text = self.headings[section]
        return heading
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return K.headingHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (row, section) = indexPath.rowAndSection
        let cell = UITableViewCell()
        
        switch self.headings[section] {
        case  self.crawlNameHeading:
            self.pubCrawlNameTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "PubCrawlNameTableViewCell") as? PubCrawlNameTableViewCell
            self.pubCrawlNameTableViewCell!.pubCrawlNameText.text = self.pubCrawl.name
            self.pubCrawlNameTableViewCell!.pubCrawlNameText.isEnabled = false
            self.pubCrawlNameTableViewCell!.delegate = self
            
            return self.pubCrawlNameTableViewCell!
        case self.newCrawlNameHeading:
            self.pubCrawlNameTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "PubCrawlNameTableViewCell") as? PubCrawlNameTableViewCell
            self.pubCrawlNameTableViewCell!.pubCrawlNameText.isEnabled = true
            self.pubCrawlNameTableViewCell!.delegate = self
            
            return self.pubCrawlNameTableViewCell!
        case self.pubsHeading:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PubNameTableViewCell") as! PubNameTableViewCell
            cell.textLabel!.text = self.listOfPubHeaders[row].name
            cell.detailTextLabel!.text = self.listOfPubHeaders.distanceToPreveiousPubText(atIndex:row)
            cell.showDisclosureIndicator()
            return cell
        case self.settingHeading:
            self.pubCrawlSettingTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "PubCrawlSettingTableViewCell") as? PubCrawlSettingTableViewCell
            self.pubCrawlSettingTableViewCell!.settingSwitch.isEnabled = self.isEditing
            if self.pubCrawl.isPublic  {
                self.pubCrawlSettingTableViewCell!.settingSwitch.isOn = true
            } else {
                self.pubCrawlSettingTableViewCell!.settingSwitch.isOn = false
            }
            self.pubCrawlSettingTableViewCell!.delegate = self
            
            return self.pubCrawlSettingTableViewCell!
        default:
            break
        }
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let (row, section) = indexPath.rowAndSection
        
        let heading = self.headings[section]
        
        switch heading {
        case self.crawlNameHeading:
            return self.pubCrawl.canRemove
        case self.settingHeading:
            return false
        case self.pubsHeading:
            return self.listOfPubHeaders.pubHeaders[row].canRemovePub
        default:
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let (row, section) = indexPath.rowAndSection
        
        if editingStyle == .delete {
            
            switch self.headings[section] {
            case self.crawlNameHeading:
                 self.deletePubCrawl()
            case self.pubsHeading:
                let pubHeader = self.listOfPubHeaders[row]
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
            self.headings = [self.crawlNameHeading, self.pubsHeading]
        } else {
            self.headings = [self.crawlNameHeading, self.noPubsHeading]
        }
        if self.pubCrawl.canUpdateSetting {
            self.headings.append(self.settingHeading)
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



