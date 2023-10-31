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
    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
