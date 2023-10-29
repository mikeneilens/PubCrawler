//
//  PubDetailTableViewControllerTests.swift
//  pubCrawlerTests
//
//  Created by Michael Neilens on 29/10/2023.
//  Copyright © 2023 Michael Neilens. All rights reserved.
//

import XCTest
@testable import pubCrawler
final class PubDetailTableViewControllerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_there_is_a_next_pub_if_next_pub_service_is_not_empty() throws {
        let pubTableViewController = PubDetailTableViewController()
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: nil, beer: nil, guest: nil, feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: "next pub service")
        pubTableViewController.pub = pub
        XCTAssertTrue(pubTableViewController.isNextPub)
    }
    func test_there_is_not_a_next_pub_if_next_pub_service_is_empty() throws {
        let pubTableViewController = PubDetailTableViewController()
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: nil, beer: nil, guest: nil, feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: "")
        pubTableViewController.pub = pub
        XCTAssertFalse(pubTableViewController.isNextPub)
    }
    func test_section_heading_is_same_as_defined_in_constants() {
        let pubTableViewController = PubDetailTableViewController()
        XCTAssertEqual(pubTableViewController.tableView(UITableView(), heightForHeaderInSection: 0), K.PubHeadings.height)
    }
    func test_number_of_sections_matches_size_of_headings_variable() {
        let pubTableViewController = PubDetailTableViewController()
        pubTableViewController.headings = ["heading1","heading2","heading3"]
        XCTAssertEqual(pubTableViewController.numberOfSections(in: UITableView()), 3)
    }
    func test_number_of_rows_for_beer_section_is_number_of_beers() {
        let pubTableViewController = PubDetailTableViewController()
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: nil, beer: ["beer1","beer2","beer3"], guest: nil, feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        pubTableViewController.headings = [K.PubHeadings.beersHeading]
        XCTAssertEqual(pubTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),3)
    }
    func test_number_of_rows_for_guest_beer_section_is_number_of_guest_beers() {
        let pubTableViewController = PubDetailTableViewController()
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: nil, beer: ["beer1","beer2","beer3"], guest: ["beer4","beer5"], feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        pubTableViewController.headings = [K.PubHeadings.guests]
        XCTAssertEqual(pubTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),2)
    }
    func test_number_of_rows_for_address_is_2_if_photo_url_is_empty() {
        let pubTableViewController = PubDetailTableViewController()
        let pub = Pub(pubHeader: nil, address: nil, photoURL: "", telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: nil, beer: nil, guest: nil, feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        pubTableViewController.headings = [K.PubHeadings.address]
        XCTAssertEqual(pubTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),2)
    }
    func test_number_of_rows_for_address_is_3_if_photo_url_is_not_empty() {
        let pubTableViewController = PubDetailTableViewController()
        let pub = Pub(pubHeader: nil, address: nil, photoURL: "photoURL", telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: nil, beer: nil, guest: nil, feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        pubTableViewController.headings = [K.PubHeadings.address]
        XCTAssertEqual(pubTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),3)
    }
    func test_number_of_rows_for_features_is_number_of_features_if_pubs_nearby_empty() {
        let pubTableViewController = PubDetailTableViewController()
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: nil, beer: nil, guest: nil, feature: ["1","2","3","4"], facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        pubTableViewController.headings = [K.PubHeadings.features]
        XCTAssertEqual(pubTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),4)
    }
    func test_number_of_rows_for_features_is_number_of_features_plus_one_if_pubs_nearby_not_empty() {
        let pubTableViewController = PubDetailTableViewController()
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: nil, beer: nil, guest: nil, feature: ["1","2","3","4"], facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: "pubs nearby service", beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        pubTableViewController.headings = [K.PubHeadings.features]
        XCTAssertEqual(pubTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),5)
    }
    func test_number_of_rows_for_facilities_is_number_of_features() {
        let pubTableViewController = PubDetailTableViewController()
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: nil, beer: nil, guest: nil, feature: nil, facility: ["1","2","3","4"], changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        pubTableViewController.headings = [K.PubHeadings.facilities]
        XCTAssertEqual(pubTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),4)
    }
    func test_number_of_rows_for_pubcrawls_is_same_of_size_of_list_of_pubCrawls_plus_one() {
        let pubTableViewController = PubDetailTableViewController()
        let listOfPubCrawls = ListOfPubCrawls(from: [PubCrawl(),PubCrawl()])
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: nil, beer: nil, guest: nil, feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: listOfPubCrawls, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        pubTableViewController.headings = [K.PubHeadings.pubCrawls]
        XCTAssertEqual(pubTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),3)
    }
    func test_number_of_rows_for_hygiene_ratings_is_same_of_size_of_list_of_hygiene_ratings() {
        let pubTableViewController = PubDetailTableViewController()
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: nil, beer: nil, guest: nil, feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        pubTableViewController.hygieneRatings = ListOfFoodHygieneRatings(foodHygienRatings: [FoodHygieneRating(),FoodHygieneRating()])
        pubTableViewController.headings = [K.PubHeadings.foodHygieneRating]
        XCTAssertEqual(pubTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),2)
    }
    func test_number_of_rows_for_visit_history_is_2() {
        let pubTableViewController = PubDetailTableViewController()
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: nil, beer: nil, guest: nil, feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        pubTableViewController.headings = [K.PubHeadings.visitHistory]
        XCTAssertEqual(pubTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),2)
    }
    func test_number_of_rows_for_section_with_invalid_heading_is_1() {
        let pubTableViewController = PubDetailTableViewController()
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: nil, beer: nil, guest: nil, feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        pubTableViewController.headings = ["incorrect heading"]
        XCTAssertEqual(pubTableViewController.tableView(UITableView(), numberOfRowsInSection: 0),1)
    }
    func test_creating_short_about_cell_when_about_text_is_short() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pubTableViewController = storyboard.instantiateViewController(withIdentifier: "pub") as! PubDetailTableViewController
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: "abcdefghijklmnopqrstuv", beer: nil, guest: nil, feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        let cell = pubTableViewController.createShortAboutCell(pubTableViewController.tableView, indexPath: IndexPath(row: 0, section: 0))
        XCTAssertFalse(cell is LongAboutTableViewCell )
        XCTAssertEqual(cell.textLabel?.text, "abcdefghijklmnopqrstuv" )
    }
    func test_creating_short_about_cell_when_about_text_is_long() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pubTableViewController = storyboard.instantiateViewController(withIdentifier: "pub") as! PubDetailTableViewController
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW", beer: nil, guest: nil, feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        let cell = pubTableViewController.createShortAboutCell(pubTableViewController.tableView, indexPath: IndexPath(row: 0, section: 0))
        XCTAssertTrue(cell is LongAboutTableViewCell )
        let longAboutCell = cell as! LongAboutTableViewCell
        XCTAssertEqual(longAboutCell.variableSizeTextLabel.text, "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW" )
    }
    func test_creating_long_about_cell_with_show_more() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pubTableViewController = storyboard.instantiateViewController(withIdentifier: "pub") as! PubDetailTableViewController
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW", beer: nil, guest: nil, feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        pubTableViewController.showAllAbout = false
        let cell = pubTableViewController.createLongAboutCell(pubTableViewController.tableView, indexPath: IndexPath(row: 0, section: 0))
        XCTAssertTrue(cell is LongAboutTableViewCell )
        let longAboutCell = cell as! LongAboutTableViewCell
        XCTAssertEqual(longAboutCell.variableSizeTextLabel.text, "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW" )
        XCTAssertEqual(longAboutCell.showMoreLabel.text, "show more" )
    }
    func test_creating_long_about_cell_with_show_less() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pubTableViewController = storyboard.instantiateViewController(withIdentifier: "pub") as! PubDetailTableViewController
        let pub = Pub(pubHeader: nil, address: nil, photoURL: nil, telephone: nil, openingTimes: nil, mealTimes: nil, owner: nil, about: "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW", beer: nil, guest: nil, feature: nil, facility: nil, changeLikedService: nil, changeVisitedService: nil, hygieneRatingService: nil, pubsNearByService: nil, beerGuideService: nil, visited: nil, liked: nil, createPubCrawlService: nil, listOfPubCrawls: nil, listOfOtherPubCrawls: nil, nextPubService: nil)
        pubTableViewController.pub = pub
        pubTableViewController.showAllAbout = true
        let cell = pubTableViewController.createLongAboutCell(pubTableViewController.tableView, indexPath: IndexPath(row: 0, section: 0))
        XCTAssertTrue(cell is LongAboutTableViewCell )
        let longAboutCell = cell as! LongAboutTableViewCell
        XCTAssertEqual(longAboutCell.variableSizeTextLabel.text, "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW" )
        XCTAssertEqual(longAboutCell.showMoreLabel.text, "show less" )
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
