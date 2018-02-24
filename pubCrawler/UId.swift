//
//  File.swift
//  pubCrawler
//
//  Created by Michael Neilens on 05/03/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//
import Foundation

struct SearchTerm {
    let qStringName:String
    let key:String
    let value:Bool
    let text:String
    var qStringValue:String {
        if self.value {
            return "yes"
        } else {
            return "no"
        }
    }
    func update(value:Bool) -> SearchTerm {
        return SearchTerm(qStringName: self.qStringName, key: key, value: value, text:self.text)
    }
    func write() {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(self.value, forKey:self.key)
    }
}


struct UId {
    var text=""
    
    mutating func refreshUId() {
        let defaults: UserDefaults = UserDefaults.standard
        if let uId = defaults.string(forKey: K.DefaultKey.uId) {
            self.text = uId
        } else {
            var string = ""
            for _ in 0...15 {
                string.append(Character(UnicodeScalar(Int(arc4random_uniform(26) + 65))!))
                
            }
            self.text=string
            defaults.setString(self.text, forKey: K.DefaultKey.uId)

            for searchTerm in K.DefaultKey.searchTerms {
                searchTerm.write()
            }
        }
        
    }
    
    var searchOptions:[SearchTerm] {
        var searchOptions=[SearchTerm]()
        let defaults: UserDefaults = UserDefaults.standard
        
        for searchTerm in K.DefaultKey.searchTerms {
            let newSearchTerm = searchTerm.update(value: defaults.bool(forKey: searchTerm.key))
            searchOptions.append(newSearchTerm)
        }
        return searchOptions
    }

}

extension UserDefaults {
    func setString(_ string:String, forKey:String) {
        set(string, forKey: forKey)
    }
}
