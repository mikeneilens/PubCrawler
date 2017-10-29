//
//  FoodHygieneRating.swift
//  pubCrawler
//
//  Created by Michael Neilens on 14/10/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import Foundation
import MNWebServiceCall

struct FoodHygieneRating {
    let businessName:String
    let foodHygieneRating:String
    let ratingKey:String
    let ratingDate:String
    var displayText:String {
        if (foodHygieneRating.isEmpty) {
            return "Not available for " + businessName
        } else {
            return "  for " + businessName
        }
    }
    var displayDate:String {
        if ratingDate != "1901-01-01" && ratingDate.isNotEmpty {
            return "   (Rated on " + ratingDate + ")"
        } else {
            return ""
        }
    }
    var displayImageURL:String {
        return K.URL.foodHygieneImageURL + ratingKey + ".JPG"
    }
    init(){
        self.businessName="this location"
        self.foodHygieneRating=""
        self.ratingKey=""
        self.ratingDate=""

    }
    init(fromJson json:[String:Any]) {
        self.businessName      = json[K.FoodHygeineJsonName.businessName]      as? String ?? ""
        self.foodHygieneRating = json[K.FoodHygeineJsonName.foodHygieneRating] as? String ?? ""
        self.ratingKey         = json[K.FoodHygeineJsonName.ratingKey]         as? String ?? ""
        self.ratingDate        = json[K.FoodHygeineJsonName.ratingDate]        as? String ?? ""
    }
}

struct ListOfFoodHygieneRatings {
    let foodHygieneRatings:[FoodHygieneRating]

    init(){
        self.foodHygieneRatings = [FoodHygieneRating]()
    }
    
    init(fromJson json:[String:Any]) {
        guard let jsonHygeineRatings = json[K.FoodHygeineJsonName.foodHygieneRatings] as? [ [String:Any] ] else {
            self = ListOfFoodHygieneRatings(withHygieneRating: FoodHygieneRating())
            return
        }
        
        var newFoodHygienRatings = [FoodHygieneRating]()
        for jsonHygeineRating:[String:Any] in jsonHygeineRatings {
            let foodHygieneRating=FoodHygieneRating(fromJson:jsonHygeineRating)
            newFoodHygienRatings.append(foodHygieneRating)
        }
        self.foodHygieneRatings = newFoodHygienRatings
    }
    
    init(withHygieneRating foodHygienRating:FoodHygieneRating) {
        self.foodHygieneRatings = [foodHygienRating]
    }
}

protocol FoodHygieneRatingsCreatorDelegate :CallWebServiceType  {
    func finishedCreating(listOfFoodHygieneRatings:ListOfFoodHygieneRatings)
}

struct FoodHygieneRatingsCreator: JSONResponseDelegate {
    let listDelegate:FoodHygieneRatingsCreatorDelegate
    
    init (delegate:FoodHygieneRatingsCreatorDelegate) {
        self.listDelegate = delegate
    }
    
    func createListOfFoodHygieneRatings(forPub pub:Pub) {
        let urlPath = pub.hygieneRatingService
        WebService(delegate:self).getJson(urlString: urlPath)
    }
    
    func finishedGetting(json:[String:Any]) {
        
        let (status, errorText)=json.errorStatus
        switch status {
        case 0:
            let listOfRatings = ListOfFoodHygieneRatings(fromJson:json)
            self.listDelegate.finishedCreating(listOfFoodHygieneRatings:listOfRatings)
        case -100:
            let noHygieneRating=FoodHygieneRating()
            let listOfRatings = ListOfFoodHygieneRatings(withHygieneRating: noHygieneRating)
            self.listDelegate.finishedCreating(listOfFoodHygieneRatings:listOfRatings)

        default:
            self.listDelegate.requestFailed(error:JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not retrieve hygiene rating")
        }
    }
    func failedGettingJson(error:Error) {
        self.listDelegate.requestFailed(error:JSONError.ConversionFailed, errorText:"Error connecting to internet", errorTitle:"Could not retrieve hygiene rating")
    }
    
}
