//
//  PubCrawlDetailTableViewControllerTests.swift
//  pubCrawlerTests
//
//  Created by Michael Neilens on 31/10/2023.
//  Copyright © 2023 Michael Neilens. All rights reserved.
//

import XCTest
@testable import pubCrawler
final class PubCrawlDetailTableViewControllerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_number_of_sections_is_same_as_number_of_headings() throws {
        let pubCrawlDetailTableViewController = PubCrawlDetailTableViewController()
        pubCrawlDetailTableViewController.headings = [K.PubCrawlHeadings.crawlName, K.PubCrawlHeadings.pubs, K.PubCrawlHeadings.setting]
        XCTAssertEqual(pubCrawlDetailTableViewController.numberOfSections(in: UITableView()),3)
    }
    func test_no_of_rows_is_1_when_section_is_for_pub_crawl_name() throws {
        let pubCrawlDetailTableViewController = PubCrawlDetailTableViewController()
        pubCrawlDetailTableViewController.headings = [K.PubCrawlHeadings.crawlName]
        XCTAssertEqual(pubCrawlDetailTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),1)
    }
    func test_no_of_rows_is_1_when_section_is_for_new_pub_crawl_name() throws {
        let pubCrawlDetailTableViewController = PubCrawlDetailTableViewController()
        pubCrawlDetailTableViewController.headings = [K.PubCrawlHeadings.newCrawlName]
        XCTAssertEqual(pubCrawlDetailTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),1)
    }
    func test_no_of_rows_is_same_as_number_of_pubs_when_section_is_for_pubs() throws {
        let pubCrawlDetailTableViewController = PubCrawlDetailTableViewController()
        pubCrawlDetailTableViewController.headings = [K.PubCrawlHeadings.pubs]
        pubCrawlDetailTableViewController.listOfPubHeaders = ListOfPubs(pubHeaders: [PubHeader(), PubHeader()], listTitle: "", morePubSerice: "")
        XCTAssertEqual(pubCrawlDetailTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),2)
    }
    func test_no_of_rows_is_zero_when_section_is_for_no_pubs() throws {
        let pubCrawlDetailTableViewController = PubCrawlDetailTableViewController()
        pubCrawlDetailTableViewController.headings = [K.PubCrawlHeadings.noPubs]
        pubCrawlDetailTableViewController.listOfPubHeaders = ListOfPubs(pubHeaders: [PubHeader(), PubHeader()], listTitle: "", morePubSerice: "")
        XCTAssertEqual(pubCrawlDetailTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),0)
    }
    func test_no_of_rows_is_1_when_section_is_for_pub_crawl_settings() throws {
        let pubCrawlDetailTableViewController = PubCrawlDetailTableViewController()
        pubCrawlDetailTableViewController.headings = [K.PubCrawlHeadings.setting]
        XCTAssertEqual(pubCrawlDetailTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),1)
    }
    func test_no_of_rows_is_0_when_section_is_for_an_unknown_heading() throws {
        let pubCrawlDetailTableViewController = PubCrawlDetailTableViewController()
        pubCrawlDetailTableViewController.headings = ["unkown"]
        XCTAssertEqual(pubCrawlDetailTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),0)
    }
    func test_view_for_section_has_same_title_as_the_heading() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pubCrawlDetailTableViewController = storyboard.instantiateViewController(withIdentifier: "PubCrawlDetailTableViewController") as! PubCrawlDetailTableViewController
        let sectionView = pubCrawlDetailTableViewController.tableView(UITableView(), viewForHeaderInSection: 0)
        let sectionLabel = sectionView?.subviews[1] as? UILabel
        XCTAssertEqual(sectionLabel?.text, K.PubCrawlHeadings.newCrawlName)
    }
    
    func test_view_headings_height_matches_constants() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pubCrawlDetailTableViewController = storyboard.instantiateViewController(withIdentifier: "PubCrawlDetailTableViewController") as! PubCrawlDetailTableViewController
        let heightForHeader = pubCrawlDetailTableViewController.tableView(UITableView(), heightForHeaderInSection: 0)
        XCTAssertEqual(heightForHeader, K.PubHeadings.height)
    }
    
    func test_cell_created_for_existing_pubCrawlName() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pubCrawlDetailTableViewController = storyboard.instantiateViewController(withIdentifier: "PubCrawlDetailTableViewController") as! PubCrawlDetailTableViewController
        pubCrawlDetailTableViewController.pubCrawl = PubCrawl(name: "pub crawl name", sequence: 0)
        let pubCrawlNameTableViewCell  =  pubCrawlDetailTableViewController.createReadOnlyCrawlNameCell()
        pubCrawlDetailTableViewController.headings =  [K.PubCrawlHeadings.crawlName]
        XCTAssertEqual(pubCrawlNameTableViewCell.pubCrawlNameText.text, "pub crawl name")
        XCTAssertEqual(pubCrawlNameTableViewCell.pubCrawlNameText.isEnabled, false)
        XCTAssertEqual(pubCrawlNameTableViewCell.delegate as? PubCrawlDetailTableViewController , pubCrawlDetailTableViewController)
    }
    func test_cell_created_for_new_pubCrawlName() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pubCrawlDetailTableViewController = storyboard.instantiateViewController(withIdentifier: "PubCrawlDetailTableViewController") as! PubCrawlDetailTableViewController
        pubCrawlDetailTableViewController.pubCrawl = PubCrawl(name: "pub crawl name", sequence: 0)
        let pubCrawlNameTableViewCell =  pubCrawlDetailTableViewController.createEditableCrawlNameCell()
        pubCrawlDetailTableViewController.headings =  [K.PubCrawlHeadings.crawlName]
        XCTAssertEqual(pubCrawlNameTableViewCell.pubCrawlNameText.text, "")
        XCTAssertEqual(pubCrawlNameTableViewCell.pubCrawlNameText.isEnabled, true)
        XCTAssertEqual(pubCrawlNameTableViewCell.delegate as? PubCrawlDetailTableViewController , pubCrawlDetailTableViewController)
    }
    func test_cell_created_for_pub() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pubCrawlDetailTableViewController = storyboard.instantiateViewController(withIdentifier: "PubCrawlDetailTableViewController") as! PubCrawlDetailTableViewController
        let pubHeader1 = PubHeader(name: "pub1", town: "town1", distance: "1 mile", isInBeerGuide: "", sequence: 0, location: nil, pubService: "", removePubService: "")
        let pubHeader2 = PubHeader(name: "pub2", town: "town2", distance: "2 mile", isInBeerGuide: "", sequence: 0, location: nil, pubService: "", removePubService: "")

        pubCrawlDetailTableViewController.listOfPubHeaders = ListOfPubs(pubHeaders: [pubHeader1, pubHeader2], listTitle: "title", morePubSerice: "")
        let pubNameTableViewCell =  pubCrawlDetailTableViewController.createPubCellContainingPubDetail(indexPath: IndexPath(row: 1, section: 0))
        XCTAssertEqual(pubNameTableViewCell.textLabel?.text, "pub2")
        XCTAssertEqual(pubNameTableViewCell.detailTextLabel?.text, "0.0 miles from pub1")
    }
    func test_creating_pub_crawl_setting_cell_for_private_pubCrawal() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pubCrawlDetailTableViewController = storyboard.instantiateViewController(withIdentifier: "PubCrawlDetailTableViewController") as! PubCrawlDetailTableViewController
        pubCrawlDetailTableViewController.isEditing = true
        let json = [K.PubCrawlJsonName.name:"pubcrawl1", K.PubCrawlJsonName.isPublic:"n"]
        pubCrawlDetailTableViewController.pubCrawl = PubCrawl(fromJson: json)
        let pubCrawlSettingTableViewCell =  pubCrawlDetailTableViewController.createPubCrawlSettingCell()
        XCTAssertEqual(pubCrawlSettingTableViewCell.settingSwitch.isEnabled, true)
        XCTAssertEqual(pubCrawlSettingTableViewCell.settingSwitch.isOn, false)
    }
    func test_creating_pub_crawl_setting_cell_for_public_pubCrawal() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pubCrawlDetailTableViewController = storyboard.instantiateViewController(withIdentifier: "PubCrawlDetailTableViewController") as! PubCrawlDetailTableViewController
        pubCrawlDetailTableViewController.isEditing = true
        let json = [K.PubCrawlJsonName.name:"pubcrawl1", K.PubCrawlJsonName.isPublic:"y"]
        pubCrawlDetailTableViewController.pubCrawl = PubCrawl(fromJson: json)
        let pubCrawlSettingTableViewCell =  pubCrawlDetailTableViewController.createPubCrawlSettingCell()
        XCTAssertEqual(pubCrawlSettingTableViewCell.settingSwitch.isEnabled, true)
        XCTAssertEqual(pubCrawlSettingTableViewCell.settingSwitch.isOn, true)
    }
    func test_can_edit_row() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pubCrawlDetailTableViewController = storyboard.instantiateViewController(withIdentifier: "PubCrawlDetailTableViewController") as! PubCrawlDetailTableViewController
        pubCrawlDetailTableViewController.isEditing = true
        let jsonRemovable = [K.PubCrawlJsonName.name:"pubcrawl1", K.PubCrawlJsonName.removeService:"removeable"]
        pubCrawlDetailTableViewController.pubCrawl = PubCrawl(fromJson: jsonRemovable)
        XCTAssertTrue(pubCrawlDetailTableViewController.tableView(pubCrawlDetailTableViewController.tableView, canEditRowAt: IndexPath(row:0,section:0)))
    }
    
    func test_can_edit_row_if_heading_is_crawlName() {
        let pubCrawlDetailTableViewController = PubCrawlDetailTableViewController()
        let jsonRemovable = [K.PubCrawlJsonName.name:"pubcrawl1", K.PubCrawlJsonName.removeService:"removeable"]
        pubCrawlDetailTableViewController.pubCrawl = PubCrawl(fromJson: jsonRemovable)
        XCTAssertTrue(pubCrawlDetailTableViewController.canEdit(heading: "Pub Crawl", atRow: IndexPath(row: 0, section: 0)))
        let jsonNotRemovable = [K.PubCrawlJsonName.name:"pubcrawl1", K.PubCrawlJsonName.removeService:""]
        pubCrawlDetailTableViewController.pubCrawl = PubCrawl(fromJson: jsonNotRemovable)
        XCTAssertFalse(pubCrawlDetailTableViewController.canEdit(heading: "Pub Crawl", atRow: IndexPath(row: 0, section: 0)))
    }
    func test_can_not_edit_row_for_settings() {
        let pubCrawlDetailTableViewController = PubCrawlDetailTableViewController()
        XCTAssertFalse(pubCrawlDetailTableViewController.canEdit(heading: "Pub Crawl Settings", atRow: IndexPath(row: 0, section: 0)))
    }
    func test_can_edit_row_if_heading_is_pubs() {
        let pubCrawlDetailTableViewController = PubCrawlDetailTableViewController()
        let jsonRemovablePub = [K.PubListJsonName.name:"pub1", K.PubListJsonName.removePubService:"removeable"]
        let pubHeaderRemovable = PubHeader(fromJson: jsonRemovablePub)
        pubCrawlDetailTableViewController.listOfPubHeaders = ListOfPubs(pubHeaders: [pubHeaderRemovable], listTitle: "some pubs", morePubSerice: "")
        XCTAssertTrue(pubCrawlDetailTableViewController.canEdit(heading: "Pubs", atRow: IndexPath(row: 0, section: 0)))
        let jsonNotRemovablePub = [K.PubListJsonName.name:"pub1", K.PubListJsonName.removePubService:""]
        let pubHeaderNotRemovable = PubHeader(fromJson: jsonNotRemovablePub)
        pubCrawlDetailTableViewController.listOfPubHeaders = ListOfPubs(pubHeaders: [pubHeaderNotRemovable], listTitle: "some pubs", morePubSerice: "")
        XCTAssertFalse(pubCrawlDetailTableViewController.canEdit(heading: "Pubs", atRow: IndexPath(row: 0, section: 0)))
    }
    func test_can_edit_row_for_any_other_heading() {
        let pubCrawlDetailTableViewController = PubCrawlDetailTableViewController()
        XCTAssertTrue(pubCrawlDetailTableViewController.canEdit(heading: "Please enter a pub crawl name", atRow: IndexPath(row: 0, section: 0)))
        XCTAssertTrue(pubCrawlDetailTableViewController.canEdit(heading: "No pubs on this pub crawl", atRow: IndexPath(row: 0, section: 0)))
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
