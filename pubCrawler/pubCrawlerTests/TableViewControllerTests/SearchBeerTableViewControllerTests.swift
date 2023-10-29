//
//  SearchBeerTableViewControllerTests.swift
//  pubCrawlerTests
//
//  Created by Michael Neilens on 29/10/2023.
//  Copyright © 2023 Michael Neilens. All rights reserved.
//

import XCTest
@testable import pubCrawler
final class SearchBeerTableViewControllerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_number_of_sections_is_one() throws {
        let searchBeerTableViewController = SearchBeerTableViewController()
        XCTAssertEqual(searchBeerTableViewController.numberOfSections(in: UITableView()), 1)
    }
    func test_number_of_rows_in_section_matches_number_of_beers() {
        let searchBeerTableViewController = SearchBeerTableViewController()
        searchBeerTableViewController.listOfBeerOrPub = [BeerOrPub.Beer("Beer1"),BeerOrPub.Beer("Beer2")]
        XCTAssertEqual(searchBeerTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),2)
    }
    func test_cell_for_row_should_return_a_beer_cell_if_row_contains_beer() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchBeerTableViewController = storyboard.instantiateViewController(withIdentifier: "Search Beer") as! SearchBeerTableViewController
        let beer = BeerOrPub.Beer("Beer1")
        let pub = BeerOrPub.Pub(PubForBeer(pubName: "pub", pubService: "ps", isRegular: true, location: Location(), distanceToOrigin: 1.0))
        searchBeerTableViewController.listOfBeerOrPub = [beer, pub]
        let cell = searchBeerTableViewController.tableView(searchBeerTableViewController.tableView!, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.textLabel?.text, "Beer1")
    }
    func test_cell_for_row_should_return_a_pub_cell_if_row_contains_pub() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchBeerTableViewController = storyboard.instantiateViewController(withIdentifier: "Search Beer") as! SearchBeerTableViewController
        let beer = BeerOrPub.Beer("Beer1")
        let pub = BeerOrPub.Pub(PubForBeer(pubName: "pub", pubService: "ps", isRegular: true, location: Location(), distanceToOrigin: 1.0))
        searchBeerTableViewController.listOfBeerOrPub = [beer, pub]
        let cell = searchBeerTableViewController.tableView(searchBeerTableViewController.tableView!, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(cell.textLabel?.text, "pub")
    }
    func test_cell_for_row_should_return_a_pub_cell_with_guest_if_row_contains_pub_and_it_is_not_regular() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchBeerTableViewController = storyboard.instantiateViewController(withIdentifier: "Search Beer") as! SearchBeerTableViewController
        let beer = BeerOrPub.Beer("Beer1")
        let pub = BeerOrPub.Pub(PubForBeer(pubName: "pub", pubService: "ps", isRegular: false, location: Location(), distanceToOrigin: 1.0))
        searchBeerTableViewController.listOfBeerOrPub = [beer, pub]
        let cell = searchBeerTableViewController.tableView(searchBeerTableViewController.tableView!, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(cell.textLabel?.text, "pub (guest beer)")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
