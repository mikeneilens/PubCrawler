//
//  Constants.swift
//  pubCrawler
//
//  Created by Michael Neilens on 29/03/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit
struct K {
    struct Notification {
        static let filterChanged = NSNotification.Name(rawValue:"filterChanged")  //notify with new pubCrawl
    }
    static let minLat = 49.8
    static let maxLat = 60.9
    static let minLng = -10.7
    static let maxLng = 1.9
    static let defaultSearch = "London"
    static let usingDefaultSearchWarningMessage = "Cannout find your location or you are outside of United Kingdom so showing pubs in " + defaultSearch
    static let nearMeSearchText = "nearby"
    static let shortPubSearchText="Town, pub or postcode"
    static let shortPubCrawlSearchText="Name of pub crawl"
    struct SegueId {
        static let showDetail = "showDetail"
        static let showOptions = "showOptions"
        static let showNewPubCrawl = "showNewPubCrawl"
        static let showPubCrawlMap = "showPubCrawlMap"
        static let showPubsForPubCrawl = "showPubsForPubCrawl"
        static let showAbout = "showAbout"
        static let showMap = "showMap"
        static let showPicture = "showPicture"
        static let showPubCrawls = "showPubCrawls"
        static let showPubsNearby = "showPubsNearby"
        static let showCreatePubCrawl = "showCreatePubCrawl"
        static let showPubCrawlForPub = "showPubCrawlForPub"
        static let showSearchOnMap = "showSearchOnMap"
    }
    struct DefaultKey {
        static let uId = "uId"
        static let searchTerms = [SearchTerm(qStringName: "realAle", key: "RealAle", value: true, text:"Only find pubs selling real ale" )
                                 ,SearchTerm(qStringName: "pubs", key: "Pubs", value: true, text:"Only find pubs" )
                                 ,SearchTerm(qStringName: "garden", key: "Garden", value: false, text:"Only places with a garden")
                                 ,SearchTerm(qStringName: "lmeals", key: "LunchtimeMeal", value: false, text:"Only places serving lunch")
                                 ,SearchTerm(qStringName: "emeals", key: "EveningMeal", value: false, text:"Only places serving evening meals")
                                 ,SearchTerm(qStringName: "memberDiscount", key: "MemberDiscountScheme", value: false, text:"Discount scheme")
                                 ,SearchTerm(qStringName: "events", key: "events", value: false, text:"Events such as quizzes")
                                ]
    }
    struct URL {
        static let pubListURL="https://pubcrawlapi.appspot.com/listofpubs/?"
        static let pubCrawlURL="https://pubcrawlapi.appspot.com/listofpubcrawls/?"
        static let foodHygieneURL="https://pubcrawlapi.appspot.com/hygienerating/?"
        static let helpURL="https://www.api.neilens.co.uk/help/"
        static let hygieneHelpURL="https://www.api.neilens.co.uk/hygienehelp/"
        static let foodHygieneImageURL="http://ratings.food.gov.uk/images/scores/small/"
        static let beerListURL="https://pubcrawlapi.appspot.com/listofbeers/?"
    }
    struct QueryParm {
        static let function="function"
        static let lat="lat"
        static let lng="lng"
        static let deg="deg"
        static let uId="uId"
        static let search="search"
        static let page="page"
        static let realAle="realAle"
        static let pubs="pubs"
        static let memberDiscount="memberDiscount"
        static let setting="setting"
        static let sequenceCSV="sequenceCSV"
        struct Function {
            static let list="list"
            static let search="search"
        }
    }
    struct PubHeadings {
        static let address="Address"
        static let telephone="Telephone"
        static let openingTime="Opening Times"
        static let foodHygieneRating="Local Food Hygiene Ratings"
        static let mealTime="Meal Times"
        static let owner="Owner"
        static let about="About"
        static let beersHeading="Regular Beers"
        static let guests="Guest Beers"
        static let features="Features"
        static let facilities="Facilities"
        static let visitHistory="Visit history"
        static let pubCrawls="On Pub Crawls"
        //Address section rows
        static let addressRow = 0
        static let mapRow = 1
        static let pictureRow = 2
        //Visit History section rows
        static let visitedRow = 0
        static let likedRow = 1
        
        static let backgroundColor = UIColor.black
        static let fontColor = UIColor.white
        static let height:CGFloat = 25.0
    }
    struct PubCrawlHeadings {
        static let crawlName="Pub Crawl"
        static let newCrawlName="Please enter a pub crawl name"
        static let pubs="Pubs"
        static let noPubs="No pubs on this pub crawl"
        static let setting="Pub Crawl Settings"
    }
    
    struct PubJsonName {
        static let pub = "Pub"
        static let name = "Name"
        static let address = "Address"
        static let photoURL = "PhotoURL"
        static let telephone = "Telephone"
        static let openingTimes = "OpeningTimes"
        static let mealTimes = "MealTimes"
        static let owner = "Owner"
        static let about = "About"
        static let guestBeerDesc = "GuestBeerDesc"
        static let lat = "Lat"
        static let lng = "Lng"
        static let regularBeers = "RegularBeers"
        static let guestBeers = "GuestBeers"
        static let features = "Features"
        static let facilities = "Facilities"
        static let visited = "Visited"
        static let liked = "Liked"
        static let createPubCrawlService = "CreatePubCrawlService"
        static let changeVisitedService = "ChangeVisitedService"
        static let changeLikedService = "ChangeLikedService"
        static let pubsNearbyService = "NearByService"
        static let hygieneRatingService = "HygieneRatingService"
        static let nextPubService = "NextPubService"
    }
    struct PubListJsonName {
        static let pubs = "Pubs"
        static let name = "Name"
        static let town = "Town"
        static let distance = "Distance"
        static let lat = "Lat"
        static let lng = "Lng"
        static let sequence = "Sequence"
        static let pubService = "PubService"
        static let removePubService = "RemovePubService"
        static let morePubsService = "MorePubsService"
        static let listTitle = "ListTitle"
        static let pageNo = "PageNo"
    }
    struct PubCrawlJsonName {
        static let pubCrawl = "PubCrawl"
        static let otherPubCrawl = "OtherPubCrawl"
        static let name = "Name"
        static let isOwner = "Owner"
        static let isPublic = "IsPublic"
        static let sequence = "Sequence"
        static let addPubCrawlService = "AddPubCrawlService"
        static let removePubCrawlService = "RemovePubCrawlService"
        static let pubsService = "PubsService"
        static let copyService = "CopyService"
        static let removeService = "RemoveService"
        static let updateService = "UpdateService"
        static let updateSettingsService = "UpdateSettingService"
        static let addUserService = "AddUserService"
        static let sequencePubsService = "SequencePubsService"
        static let emailTextService = "EmailTextService"
        static let emailText = "EmailText"
    }
    struct BeerListJsonName {
        static let beers = "Beers"
    }
    struct BeerJsonName {
        static let name = "Name"
        static let pubName = "PubName"
        static let pubService = "PubService"
        static let isRegular = "IsRegular"
    }
    struct FoodHygeineJsonName {
        static let businessName = "BusinessName"
        static let foodHygieneRating = "FoodHygieneRating"
        static let foodHygieneRatings = "FoodHygieneRatings"
        static let ratingKey = "RatingKey"
        static let ratingDate = "RatingDate"
    }
    struct Message {
        static let status = "Status"
        static let text = "Text"
    }
    static let message = "Message"
    struct MapView {
        static let minSpan = 0.005
        static let maxPubsToFetch = 40
    }

}
