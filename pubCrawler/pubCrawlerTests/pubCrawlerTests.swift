//
//  pubCrawlerTests.swift
//  pubCrawlerTests
//
//  Created by Michael Neilens on 15/02/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import XCTest
@testable import pubCrawler
/*
class pubCrawlerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testLocation() {
        let emptylocation = Location(lng: 0, lat: 0)
        XCTAssert(emptylocation.isEmpty,"isEmpty should return true if lng and lat are zero")
 
        let newYorklocation = Location(lng:-74.0059700,lat:40.7142700)
        XCTAssert(!newYorklocation.isEmpty,"isEmpty should return false if lng or lat are not zero")
        XCTAssert(newYorklocation.isOutsideUK,"isOutsideUK should return true if location is New York")
        let manchesterLocation = Location(lng:-2.2374300, lat:53.4809500)
        
        XCTAssert(!manchesterLocation.isOutsideUK,"isOutsideUK should return false if location is Manchester")
    }
    
    func testPubHeader() {
        let pubHeaderString="{\"Id\":\"10\",\"Branch\":\"STH\",\"Name\":\"Rocket\",\"Distance\":\"0.2 miles (0.3km)\",\"Town\":\"Rainhill\"}"
        let pubHeaderJson:NSDictionary = convertStringToDictionary2(text: pubHeaderString) ?? NSDictionary()
        let pubHeader=PubHeader(fromJson: pubHeaderJson)
        XCTAssert(pubHeader.name == "Rocket","Pub header name not set correctly" )
        XCTAssert(pubHeader.id=="10","Pub header id not set correctly")
        XCTAssert(pubHeader.branch=="STH","Pub Header branch not set correctly")
        XCTAssert(pubHeader.town=="Rainhill","Pub Header town not set correctly")
        XCTAssert(pubHeader.distance=="0.2 miles (0.3km)","Pub Header distance not set correctly")
        XCTAssert(pubHeader.location==Location(lng:0,lat:0),"Pub Header location not set correctly")

        let pubHeaderString2="{\"Id\":\"10\",\"Branch\":\"STH\",\"Name\":\"Rocket\",\"Distance\":\"0.2 miles (0.3km)\",\"Town\":\"Rainhill\",\"Lat\":53.3,\"Lng\":-2.4}"
        let pubHeaderJson2:NSDictionary = convertStringToDictionary2(text: pubHeaderString2) ?? NSDictionary()
        let pubHeader2=PubHeader(fromJson: pubHeaderJson2)
        XCTAssert(pubHeader2.location==Location(lng:-2.4,lat:53.3),"Pub Header location not set correctly")
    }
    
    func testPub() {
        let pubString = "{\"Name\":\"Sir Michael Balcon\",\"Address\":\"46-47 The Mall Ealing W5 3TJ\",\"Telephone\":\"123 456\",\"OpeningTimes\":\"9am-11.30 Mon-Thu; 9am-Midnight Fri and Sat; 9am-11.30 Sun\",\"MealTimes\":\"9am-11\",\"Owner\":\"Wetherspoon\",\"About\":\"Located on the Uxbridge Road east of Ealing town centre.\",\"GuestBeerDesc\":\"This pub serves 5 changing beers. \",\"Lng\":-0.2986,\"Lat\":51.51355,\"RegularBeers\":[\"Greene King Abbot\",\"Greene King IPA\",\"Sharp's Doom Bar\"],\"GuestBeers\":[\"Adnams - varies\",\"Hogs Back - varies\",\"Sambrook's - varies\"],\"Features\":[\"Real Ale Available\",\"Real Cider Available\",\"Beer Festivals\",\"Cask Marque Accredited\",\"Quiet Pub\"],\"Facilities\":[\"Disabled Access \",\"Lunchtime Meals \",\"Evening Meals \",\"Pub Garden \",\"Family Friendly \",\"Newspapers \",\"Real Fire \",\"Smoking Area \",\"Sports TV \",\"Wifi \"],\"PubCrawl\":[{\"CrawlId\":\"YWQAEXCJ\",\"Name\":\"Ealing central\",\"Owner\":\"y\",\"IsOnList\":\"y\",\"IsPublic\":\"y\",\"IsOnCrawl\":\"y\"}],\"Visited\":\"y\",\"Liked\":\"y\",\"Message\":{\"Status\":0,\"Text\":\"Pub retrieved.\"}}"
        let pubJson:NSDictionary = convertStringToDictionary2(text: pubString) ?? NSDictionary()
        let pubHeaderString="{\"Id\":\"b\",\"Branch\":\"a\",\"Name\":\"Sir Michael Balcon\",\"Distance\":\"e\",\"Town\":\"d\",\"Lat\":1.0,\"Lng\":2.0,\"Sequence\":2}"
        let pubHeaderJson:NSDictionary = convertStringToDictionary2(text: pubHeaderString) ?? NSDictionary()
        let pubHeader=PubHeader(fromJson: pubHeaderJson)

        let pub=Pub(fromJson:pubJson, pubHeader:pubHeader)
        
        XCTAssert(pub.pubHeader.name=="Sir Michael Balcon","Pub name is not set correctly")
        XCTAssert(pub.pubHeader.id=="b","Pub id is not set correctly")
        XCTAssert(pub.pubHeader.branch=="a","Pub branch is not set correctly")
        XCTAssert(pub.pubHeader.town=="d","Pub town is not set correctly")
        XCTAssert(pub.pubHeader.distance=="e","Pub distance is not set correctly")
        XCTAssert(pub.pubHeader.location==Location(lng:-0.2986,lat:51.51355),"Pub location is not set correctly")
        XCTAssert(pub.pubHeader.sequence==2,"Pub sequence is not set correctly")
        XCTAssert(pub.address=="46-47 The Mall Ealing W5 3TJ","Pub address is not set correctly")
        XCTAssert(pub.telephone=="123 456","Pub telephone is not set correctly")
        XCTAssert(pub.openingTimes=="9am-11.30 Mon-Thu; 9am-Midnight Fri and Sat; 9am-11.30 Sun","Pub openingTimes is not set correctly")
        XCTAssert(pub.mealTimes=="9am-11","Pub mealTimes is not set correctly")
        XCTAssert(pub.owner=="Wetherspoon","Pub owner is not set correctly")
        XCTAssert(pub.about=="Located on the Uxbridge Road east of Ealing town centre.","Pub about is not set correctly")
        XCTAssert(pub.beer.count == 3 ,"Pub beers.count is not set correctly")
        if pub.beer.count == 3 {
            XCTAssert(pub.beer[0] == "Greene King Abbot" ,"Pub beer[0] is not set correctly")
            XCTAssert(pub.beer[1] == "Greene King IPA" ,"Pub beer[1] is not set correctly")
            XCTAssert(pub.beer[2] == "Sharp's Doom Bar" ,"Pub beer[2] is not set correctly")
        }
        XCTAssert(pub.guest.count == 4 ,"Pub beers.count is not set correctly")
        if pub.guest.count == 4 {
            XCTAssert(pub.guest[1] == "Adnams - varies" ,"Pub guest[0] is not set correctly")
            XCTAssert(pub.guest[2] == "Hogs Back - varies" ,"Pub guest[1] is not set correctly")
            XCTAssert(pub.guest[3] == "Sambrook's - varies" ,"Pub guest[2] is not set correctly")
            XCTAssert(pub.guest[0] == "This pub serves 5 changing beers." ,"Pub guest[3] is not set correctly")
        }
        XCTAssert(pub.feature.count == 5 ,"Pub features.count is not set correctly")
        if pub.feature.count == 5 {
            XCTAssert(pub.feature[0] == "Real Ale Available" ,"Pub feature[0] is not set correctly")
            XCTAssert(pub.feature[1] == "Real Cider Available" ,"Pub feature[1] is not set correctly")
            XCTAssert(pub.feature[2] == "Beer Festivals" ,"Pub feature[2] is not set correctly")
            XCTAssert(pub.feature[3] == "Cask Marque Accredited" ,"Pub feature[3] is not set correctly")
            XCTAssert(pub.feature[4] == "Quiet Pub" ,"Pub feature[4] is not set correctly")
        }
        XCTAssert(pub.facility.count == 10 ,"Pub facilitys.count is not set correctly")
        if pub.facility.count == 10 {
            XCTAssert(pub.facility[0] == "Disabled Access " ,"Pub facility[0] is not set correctly")
            XCTAssert(pub.facility[1] == "Lunchtime Meals " ,"Pub facility[1] is not set correctly")
            XCTAssert(pub.facility[2] == "Evening Meals " ,"Pub facility[2] is not set correctly")
            XCTAssert(pub.facility[3] == "Pub Garden " ,"Pub facility[3] is not set correctly")
            XCTAssert(pub.facility[4] == "Family Friendly " ,"Pub facility[4] is not set correctly")
        }
        XCTAssert(pub.listOfPubCrawls.pubCrawls.count==1,"Pub pubcrawls.count is not set correctly")
        if pub.listOfPubCrawls.pubCrawls.count==1 {
            XCTAssert(pub.listOfPubCrawls.pubCrawls[0].crawlId=="YWQAEXCJ","Pub pubcrawls[0].crawlId  is not set correctly")
            XCTAssert(pub.listOfPubCrawls.pubCrawls[0].name=="Ealing central","Pub pubcrawls[0].name  is not set correctly")
            XCTAssert(pub.listOfPubCrawls.pubCrawls[0].isOnCrawl,"Pub pubcrawls[0].isOnCrawl  is not set correctly")
            XCTAssert(pub.listOfPubCrawls.pubCrawls[0].isOnList,"Pub pubcrawls[0].isOwner  is not set correctly")
            XCTAssert(pub.listOfPubCrawls.pubCrawls[0].isPublic,"Pub pubcrawls[0].isPublic  is not set correctly")
        }
        XCTAssert(pub.visited == true ,"Pub visited is not set correctly")
        XCTAssert(pub.liked == true ,"Pub liked is not set correctly")
        
        let pubCrawlString = "{\"PubCrawl\":[{\"CrawlId\":\"YWQAEXCJ\",\"Name\":\"Ealing central\",\"Owner\":\"y\",\"IsOnList\":\"y\",\"IsPublic\":\"y\",\"IsOnCrawl\":\"y\"},{\"CrawlId\":\"ABCDEFGH\",\"Name\":\"test1\",\"Owner\":\"n\",\"IsOnList\":\"n\",\"IsPublic\":\"n\",\"IsOnCrawl\":\"n\"}],\"Message\":{\"Status\":0,\"Text\":\"Pub retrieved.\"}}"
        let pubCrawlJson:NSDictionary = convertStringToDictionary2(text: pubCrawlString) ?? NSDictionary()
        let listOfPubCrawls = pub.getPubCrawls(fromJson:pubCrawlJson)
        XCTAssert(listOfPubCrawls.pubCrawls.count == 2, "Wrong number of pubCrawls returned by pub.getPubCrawls" )
        if listOfPubCrawls.pubCrawls.count == 2 {
            XCTAssert(listOfPubCrawls.pubCrawls[0].crawlId=="YWQAEXCJ","pubcrawls[0].crawlId  is not set correctly")
            XCTAssert(listOfPubCrawls.pubCrawls[0].name=="Ealing central","pubcrawls[0].name  is not set correctly")
            XCTAssert(listOfPubCrawls.pubCrawls[0].isOnCrawl,"pubcrawls[0].isOnCrawl  is not set correctly")
            XCTAssert(listOfPubCrawls.pubCrawls[0].isOnList,"pubcrawls[0].isOwner  is not set correctly")
            XCTAssert(listOfPubCrawls.pubCrawls[0].isPublic,"pubcrawls[0].isPublic  is not set correctly")
            XCTAssert(listOfPubCrawls.pubCrawls[1].crawlId=="ABCDEFGH","pubcrawls[0].crawlId  is not set correctly")
            XCTAssert(listOfPubCrawls.pubCrawls[1].name=="test1","pubcrawls[0].name  is not set correctly")
            XCTAssert(!listOfPubCrawls.pubCrawls[1].isOnCrawl,"pubcrawls[0].isOnCrawl  is not set correctly")
            XCTAssert(!listOfPubCrawls.pubCrawls[1].isOnList,"pubcrawls[0].isOwner  is not set correctly")
            XCTAssert(!listOfPubCrawls.pubCrawls[1].isPublic,"pubcrawls[0].isPublic  is not set correctly")
        }
        
        let userId = UId(text:"ABCDEFGH")
        let urlString = pub.urlToUpdateVisit(forUId: userId)
        let url = URL(string:urlString)
        let urlDict = url?.queryParams

        XCTAssert(urlDict?.count == 5,"url for update pub visit does not contain correct number of parameters")
        let uid = urlDict?["uId"] as? String ?? ""
        XCTAssert(uid == "ABCDEFGH","url for pubCreator does not contain uId")
        let id = urlDict?["id"] as? String ?? ""
        XCTAssert(id == "b","url for pubCreator does not contain correct id")
        let branch = urlDict?["branch"] as? String ?? ""
        XCTAssert(branch == "a","url for pubCreator does not contain correct branch")
        let visited = urlDict?["visited"] as? String ?? ""
        XCTAssert(visited == "y","url for pubCreator does not contain correct visited")
        let liked = urlDict?["liked"] as? String ?? ""
        XCTAssert(liked == "y","url for pubCreator does not contain correct liked")

    }
}

class pubCrawlerTestsPubCreatorDelegate:XCTestCase, PubCreatorDelegate {

    func testPubCreator() {
        let pubHeaderString="{\"Id\":\"b\",\"Branch\":\"a\",\"Name\":\"Sir Michael Balcon\",\"Distance\":\"e\",\"Town\":\"d\",\"Lat\":1.0,\"Lng\":2.0,\"Sequence\":2}"
        let pubHeaderJson:NSDictionary = convertStringToDictionary2(text: pubHeaderString) ?? NSDictionary()
        let pubHeader=PubHeader(fromJson: pubHeaderJson)
        
        let pubString = "{\"Name\":\"Sir Michael Balcon\",\"Address\":\"46-47 The Mall Ealing W5 3TJ\",\"Telephone\":\"123 456\",\"OpeningTimes\":\"9am-11.30 Mon-Thu; 9am-Midnight Fri and Sat; 9am-11.30 Sun\",\"MealTimes\":\"9am-11\",\"Owner\":\"Wetherspoon\",\"About\":\"Located on the Uxbridge Road east of Ealing town centre.\",\"GuestBeerDesc\":\"This pub serves 5 changing beers. \",\"Lng\":-0.2986,\"Lat\":51.51355,\"RegularBeers\":[\"Greene King Abbot\",\"Greene King IPA\",\"Sharp's Doom Bar\"],\"GuestBeers\":[\"Adnams - varies\",\"Hogs Back - varies\",\"Sambrook's - varies\"],\"Features\":[\"Real Ale Available\",\"Real Cider Available\",\"Beer Festivals\",\"Cask Marque Accredited\",\"Quiet Pub\"],\"Facilities\":[\"Disabled Access \",\"Lunchtime Meals \",\"Evening Meals \",\"Pub Garden \",\"Family Friendly \",\"Newspapers \",\"Real Fire \",\"Smoking Area \",\"Sports TV \",\"Wifi \"],\"PubCrawl\":[{\"CrawlId\":\"YWQAEXCJ\",\"Name\":\"Ealing central\",\"Owner\":\"y\",\"IsOnList\":\"y\",\"IsPublic\":\"y\",\"IsOnCrawl\":\"y\"}],\"Visited\":\"y\",\"Liked\":\"y\",\"Message\":{\"Status\":0,\"Text\":\"Pub retrieved.\"}}"
        let pubJson:NSDictionary = convertStringToDictionary2(text: pubString) ?? NSDictionary()
        
        let pubCreator = PubCreator(withDelegate: self, forPubHeader:pubHeader)
        pubCreator.finishedGetting(json: pubJson)

        let userId = UId(text:"ABCDEFGH")
        let urlString = pubCreator.uRLtoCreatePub(forUId: userId)
        let url = URL(string:urlString)
        let urlDict = url?.queryParams
        XCTAssert(urlDict?.count == 4,"url for pubCreator does not contain correct number of parameters")
        let branch = urlDict?["branch"] as? String ?? ""
        XCTAssert(branch == "a","url for pubCreator does not contain branch")
        let id = urlDict?["id"] as? String ?? ""
        XCTAssert(id == "b","url for pubCreator does not contain id")
        let uid = urlDict?["uId"] as? String ?? ""
        XCTAssert(uid == "ABCDEFGH","url for pubCreator does not contain uId")
        let v = urlDict?["v"] as? String ?? ""
        XCTAssert(v == "1","url for pubCreator does not contain v")
    }
    
    func testPubCreatorFails() {
        let pubHeaderString="{\"Id\":\"b\",\"Branch\":\"test\",\"Name\":\"c\",\"Distance\":\"e\",\"Town\":\"d\",\"Lat\":\"1\",\"Lng\":\"2\",\"Sequence\":\"2\"}"
        let pubHeaderJson:NSDictionary = convertStringToDictionary2(text: pubHeaderString) ?? NSDictionary()
        let pubHeader=PubHeader(fromJson: pubHeaderJson)
        
        let pubString = "{\"Message\":{\"Status\":-1,\"Text\":\"Pub not found.\"}}"
        let pubJson:NSDictionary = convertStringToDictionary2(text: pubString) ?? NSDictionary()
        
        let pubCreator = PubCreator(withDelegate: self, forPubHeader:pubHeader)
        pubCreator.finishedGetting(json: pubJson)
    }
    
    func finishedCreating(newPub pub:Pub) {
        XCTAssert(pub.pubHeader.name=="Sir Michael Balcon","Pub name is not set correctly")
        XCTAssert(pub.pubHeader.id=="b","Pub id is not set correctly")
        XCTAssert(pub.pubHeader.branch=="a","Pub branch is not set correctly")
        XCTAssert(pub.pubHeader.town=="d","Pub town is not set correctly")
        XCTAssert(pub.pubHeader.distance=="e","Pub distance is not set correctly")
        XCTAssert(pub.pubHeader.location==Location(lng:-0.2986,lat:51.51355),"Pub location is not set correctly")
        XCTAssert(pub.pubHeader.sequence==2,"Pub sequence is not set correctly")
        XCTAssert(pub.address=="46-47 The Mall Ealing W5 3TJ","Pub address is not set correctly")
        XCTAssert(pub.telephone=="123 456","Pub telephone is not set correctly")
        XCTAssert(pub.openingTimes=="9am-11.30 Mon-Thu; 9am-Midnight Fri and Sat; 9am-11.30 Sun","Pub openingTimes is not set correctly")
        XCTAssert(pub.mealTimes=="9am-11","Pub mealTimes is not set correctly")
        XCTAssert(pub.owner=="Wetherspoon","Pub owner is not set correctly")
        XCTAssert(pub.about=="Located on the Uxbridge Road east of Ealing town centre.","Pub about is not set correctly")
        XCTAssert(pub.beer.count == 3 ,"Pub beers.count is not set correctly")
        if pub.beer.count == 3 {
            XCTAssert(pub.beer[0] == "Greene King Abbot" ,"Pub beer[0] is not set correctly")
            XCTAssert(pub.beer[1] == "Greene King IPA" ,"Pub beer[1] is not set correctly")
            XCTAssert(pub.beer[2] == "Sharp's Doom Bar" ,"Pub beer[2] is not set correctly")
        }
        XCTAssert(pub.guest.count == 4 ,"Pub beers.count is not set correctly")
        if pub.guest.count == 4 {
            XCTAssert(pub.guest[1] == "Adnams - varies" ,"Pub guest[0] is not set correctly")
            XCTAssert(pub.guest[2] == "Hogs Back - varies" ,"Pub guest[1] is not set correctly")
            XCTAssert(pub.guest[3] == "Sambrook's - varies" ,"Pub guest[2] is not set correctly")
            XCTAssert(pub.guest[0] == "This pub serves 5 changing beers." ,"Pub guest[3] is not set correctly")
        }
        XCTAssert(pub.feature.count == 5 ,"Pub features.count is not set correctly")
        if pub.feature.count == 5 {
            XCTAssert(pub.feature[0] == "Real Ale Available" ,"Pub feature[0] is not set correctly")
            XCTAssert(pub.feature[1] == "Real Cider Available" ,"Pub feature[1] is not set correctly")
            XCTAssert(pub.feature[2] == "Beer Festivals" ,"Pub feature[2] is not set correctly")
            XCTAssert(pub.feature[3] == "Cask Marque Accredited" ,"Pub feature[3] is not set correctly")
            XCTAssert(pub.feature[4] == "Quiet Pub" ,"Pub feature[4] is not set correctly")
        }
        XCTAssert(pub.facility.count == 10 ,"Pub facilitys.count is not set correctly")
        if pub.facility.count == 10 {
            XCTAssert(pub.facility[0] == "Disabled Access " ,"Pub facility[0] is not set correctly")
            XCTAssert(pub.facility[1] == "Lunchtime Meals " ,"Pub facility[1] is not set correctly")
            XCTAssert(pub.facility[2] == "Evening Meals " ,"Pub facility[2] is not set correctly")
            XCTAssert(pub.facility[3] == "Pub Garden " ,"Pub facility[3] is not set correctly")
            XCTAssert(pub.facility[4] == "Family Friendly " ,"Pub facility[4] is not set correctly")
        }
        XCTAssert(pub.listOfPubCrawls.pubCrawls.count==1,"Pub pubcrawls.count is not set correctly")
        if pub.listOfPubCrawls.pubCrawls.count==1 {
            XCTAssert(pub.listOfPubCrawls.pubCrawls[0].crawlId=="YWQAEXCJ","Pub pubcrawls[0].crawlId  is not set correctly")
            XCTAssert(pub.listOfPubCrawls.pubCrawls[0].name=="Ealing central","Pub pubcrawls[0].name  is not set correctly")
            XCTAssert(pub.listOfPubCrawls.pubCrawls[0].isOnCrawl,"Pub pubcrawls[0].isOnCrawl  is not set correctly")
            XCTAssert(pub.listOfPubCrawls.pubCrawls[0].isOnList,"Pub pubcrawls[0].isOwner  is not set correctly")
            XCTAssert(pub.listOfPubCrawls.pubCrawls[0].isPublic,"Pub pubcrawls[0].isPublic  is not set correctly")
        }
        XCTAssert(pub.visited == true ,"Pub visited is not set correctly")
        XCTAssert(pub.liked == true ,"Pub liked is not set correctly")
        
    }
    func requestFailed(error:JSONError, errorText:String, errorTitle:String){
        XCTAssert(errorText == "Pub not found." ,"Error \(errorText), \(errorTitle)")
    }

}

class pubCrawlerTestsListOfPubCrawls: XCTestCase {
    func testContains() {
        let pubCrawlsString="{\"PubCrawl\":[{\"CrawlId\":\"MYIXSKBJ\",\"Name\":\"Derby pubs\",\"Owner\":\"n\",\"IsOnList\":\"n\",\"IsPublic\":\"n\"},{\"CrawlId\":\"CUVCJVEZ\",\"Name\":\"David's Legendary PC\",\"Owner\":\"n\",\"IsOnList\":\"n\",\"IsPublic\":\"n\"},{\"CrawlId\":\"WIWYVOMR\",\"Name\":\"dirty dozen\",\"Owner\":\"n\",\"IsOnList\":\"n\",\"IsPublic\":\"n\"},{\"CrawlId\":\"HDIJSHKW\",\"Name\":\"Duke street wood street\",\"Owner\":\"n\",\"IsOnList\":\"n\",\"IsPublic\":\"n\"},{\"CrawlId\":\"YUDLCGQY\",\"Name\":\"Daz Stag Do\",\"Owner\":\"n\",\"IsOnList\":\"n\",\"IsPublic\":\"n\"},{\"CrawlId\":\"VKXNATRU\",\"Name\":\"Daz Stag\",\"Owner\":\"n\",\"IsOnList\":\"n\",\"IsPublic\":\"n\"},{\"CrawlId\":\"OMKSNDSP\",\"Name\":\"durham\",\"Owner\":\"n\",\"IsOnList\":\"n\",\"IsPublic\":\"n\"}],\"Message\":{\"Status\":0,\"Text\":\"Pub crawls retrieved.\"}}"
        
        let listOfPubCrawlsJson:NSDictionary = convertStringToDictionary2(text: pubCrawlsString) ?? NSDictionary()
        let listOfPubCrawls=ListOfPubCrawls(fromJson: listOfPubCrawlsJson)
        XCTAssert(listOfPubCrawls.contains(crawlId:"MYIXSKBJ"),"listOfPubCrawls does contain crawlid MYIXSKBJ")
        XCTAssert(!listOfPubCrawls.contains(crawlId:"RUBBISH!"),"listOfPubCrawls does not contain crawlid RUBBISH!")

    }
}

func convertStringToDictionary2(text: String) -> NSDictionary?  {
    if let data = text.data(using: String.Encoding.utf8) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
            return json
        } catch {
            print("Something went wrong")
        }
    }
    return nil
}
*/
