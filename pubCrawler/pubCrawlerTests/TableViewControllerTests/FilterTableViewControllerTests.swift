//
//  FilterTableViewControllerTests.swift
//  pubCrawlerTests
//
//  Created by Michael Neilens on 20/11/2023.
//  Copyright © 2023 Michael Neilens. All rights reserved.
//

import XCTest
@testable import pubCrawler
final class FilterTableViewControllerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_no_of_sections_in_tableview_is_1() throws {
        let filterTableViewController = FilterTableViewController()
        XCTAssertEqual(filterTableViewController.numberOfSections(in: UITableView()),1)
    }
    func test_no_of_rows_equals_number_of_options() throws {
        let filterTableViewController = FilterTableViewController()
        filterTableViewController.options = [
            SearchTerm(qStringName: "o1", key: "k1", value: true, text: "t1"),
            SearchTerm(qStringName: "o2", key: "k2", value: true, text: "t2")]
        XCTAssertEqual(filterTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),2)
    }
    func test_cell_for_row_is_SettingsTableViewCell_with_properties_from_the_option() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let filterTableViewController = storyboard.instantiateViewController(withIdentifier: "FilterTableViewController") as! FilterTableViewController
        let cell0 = filterTableViewController.tableView(filterTableViewController.tableView, cellForRowAt:IndexPath(row: 0, section: 0) )
        XCTAssertTrue(cell0 is SettingsTableViewCell)
        let settingsTableViewCell0 = cell0 as? SettingsTableViewCell
        XCTAssertEqual(settingsTableViewCell0?.labelText.text,"Only find pubs selling real ale")
        XCTAssertEqual(settingsTableViewCell0?.optionSwitch.isOn,true)
        let cell1 = filterTableViewController.tableView(filterTableViewController.tableView, cellForRowAt:IndexPath(row: 1, section: 0) )
        XCTAssertTrue(cell1 is SettingsTableViewCell)
        let settingsTableViewCell1 = cell1 as? SettingsTableViewCell
        XCTAssertEqual(settingsTableViewCell1?.labelText.text,"Only find pubs")
        XCTAssertEqual(settingsTableViewCell1?.optionSwitch.isOn,true)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
