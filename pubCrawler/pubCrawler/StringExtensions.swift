//
//  StringExtensions.swift
//  pubCrawler
//
//  Created by Michael Neilens on 11/07/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import Foundation

extension String {
    var cleanQString:String { //cleans up a string being passed as a parameter
        let toArray = self.components(separatedBy: " ")
        return toArray.joined(separator: "+")
    }

    var replacedGBP:String { //replaces the currency sign in a string
        let toArray = self.components(separatedBy: "GBP")
        return toArray.joined(separator: "£")
    }
    
    func addParametersToURL(paramDict:[String:String]) ->String { //adds a list of parameters held in a dictionary to a URL
        return self + paramDict.paramList
    }
    
    var condensedWhitespace: String {
        let components = self.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    var onlyContainsNoneAlphaNumerics:Bool { //only letters or numbers are valid!
        for scalar in self.unicodeScalars {
            let value = scalar.value
            if !(value >= 65 && value <= 90) && !(value >= 97 && value <= 122) && !(value >= 48 && value <= 57)
            { return false}
        }
        return true
    }
    
    var isNotEmpty:Bool {
        return !self.isEmpty
    }
}
