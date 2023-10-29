//
//  SearchTableViewControllerTests.swift
//  pubCrawlerTests
//
//  Created by Michael Neilens on 29/10/2023.
//  Copyright © 2023 Michael Neilens. All rights reserved.
//

import XCTest
@testable import pubCrawler
final class SearchTableViewControllerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_no_of_rows_is_number_of_pubs_if_more_pubService_is_empty() throws {
        let listOfPubHeaders = ListOfPubs(pubHeaders: [PubHeader()], listTitle: "title", morePubSerice: "")
        let searchTableViewController = SearchTableViewController()
        searchTableViewController.listOfPubHeaders = listOfPubHeaders
        XCTAssertEqual(searchTableViewController.numberOfRows, 1)
    }
    func test_no_of_rows_is_number_of_pubs_plus_one_if_more_pubService_is_not_empty() throws {
        let listOfPubHeaders = ListOfPubs(pubHeaders: [PubHeader()], listTitle: "title", morePubSerice: "morePubsService")
        let searchTableViewController = SearchTableViewController()
        searchTableViewController.listOfPubHeaders = listOfPubHeaders
        XCTAssertEqual(searchTableViewController.numberOfRows, 2)
    }
    func test_no_of_sections_is_one() throws {
        let listOfPubHeaders = ListOfPubs(pubHeaders: [PubHeader()], listTitle: "title", morePubSerice: "morePubsService")
        let searchTableViewController = SearchTableViewController()
        searchTableViewController.listOfPubHeaders = listOfPubHeaders
        XCTAssertEqual(searchTableViewController.numberOfSections(in: UITableView()), 1)
    }
    func test_no_of_rows_in_a_section_is_number_of_pubs_if_more_pubService_is_empty() throws {
        let listOfPubHeaders = ListOfPubs(pubHeaders: [PubHeader()], listTitle: "title", morePubSerice: "")
        let searchTableViewController = SearchTableViewController()
        searchTableViewController.listOfPubHeaders = listOfPubHeaders
        XCTAssertEqual(searchTableViewController.tableView(UITableView(), numberOfRowsInSection:0), 1)
    }
    func test_no_of_rows_in_a_section_is_number_of_pubs_plus_one_if_more_pubService_is_not_empty() throws {
        let listOfPubHeaders = ListOfPubs(pubHeaders: [PubHeader()], listTitle: "title", morePubSerice: "morePubsService")
        let searchTableViewController = SearchTableViewController()
        searchTableViewController.listOfPubHeaders = listOfPubHeaders
        XCTAssertEqual(searchTableViewController.tableView(UITableView(), numberOfRowsInSection:0), 2)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
