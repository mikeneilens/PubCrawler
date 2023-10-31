//
//  PubCrawlsTableViewControllerTests.swift
//  pubCrawlerTests
//
//  Created by Michael Neilens on 31/10/2023.
//  Copyright © 2023 Michael Neilens. All rights reserved.
//

import XCTest
@testable import pubCrawler
final class PubCrawlsTableViewControllerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func test_number_of_sections_is_one() throws {
        let pubCrawlsTableViewController = PubCrawlsTableViewController()
        XCTAssertEqual(pubCrawlsTableViewController.numberOfSections(in: UITableView()), 1)
    }
    func test_number_of_rows_in_section_matches_number_of_pubCrawls() {
        let pubCrawlsTableViewController = PubCrawlsTableViewController()
        let pubCrawl1 = PubCrawl(name: "pubcrawl1", sequence: 0)
        let pubCrawl2 = PubCrawl(name: "pubcrawl2", sequence: 0)
        pubCrawlsTableViewController.listOfpubCrawls = ListOfPubCrawls(from: [pubCrawl1,pubCrawl2])
        XCTAssertEqual(pubCrawlsTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),2)
    }
    func test_creating_cell_for_a_pub_crawl_for_a_particular_row() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pubCrawlsTableViewController = storyboard.instantiateViewController(withIdentifier: "pub crawls") as! PubCrawlsTableViewController
        let pubCrawl1 = PubCrawl(name: "pubcrawl1", sequence: 0)
        let pubCrawl2 = PubCrawl(name: "pubcrawl2", sequence: 0)
        pubCrawlsTableViewController.listOfpubCrawls = ListOfPubCrawls(from: [pubCrawl1,pubCrawl2])
        let cell = pubCrawlsTableViewController.tableView(pubCrawlsTableViewController.tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(cell.textLabel?.text, "pubcrawl2")
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
