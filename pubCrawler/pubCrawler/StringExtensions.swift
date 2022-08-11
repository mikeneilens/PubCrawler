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

    func addParametersToURL(paramDict:[String:String]) ->String { //adds a list of parameters held in a dictionary to a URL
        return self + paramDict.paramList
    }
    
    var condensedWhitespace: String {
        let components = self.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    var isNotEmpty:Bool {
        return !self.isEmpty
    }
    func splitIntoLines()-> String {
        if self.count == 0 { return self }
        let splitString = self.replacingOccurrences(of: "; ", with: "\n")
        if splitString.last == "\n" {
            return String(splitString.dropLast(1))
        } else {
            return splitString
        }
    }
}
