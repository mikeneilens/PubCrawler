//
//  File.swift
//  pubCrawler
//
//  Created by Michael Neilens on 05/03/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//
import Foundation

enum SearchOption {
    case realAle
    case pubs
    case memberDiscountScheme
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

            defaults.set(true, forKey: K.DefaultKey.SearchOption.onlyPubs)
            defaults.set(true, forKey: K.DefaultKey.SearchOption.onlyRealAle)
            defaults.set(false, forKey: K.DefaultKey.SearchOption.onlyMembersDiscount)
        }
        
    }
    
    var searchOptions:[SearchOption] {
        var searchOptions=[SearchOption]()
        let defaults: UserDefaults = UserDefaults.standard
        if (defaults.bool(forKey: K.DefaultKey.SearchOption.onlyPubs))  {
            searchOptions.append(SearchOption.pubs)
        }
        if (defaults.bool(forKey: K.DefaultKey.SearchOption.onlyRealAle))  {
            searchOptions.append(SearchOption.realAle)
        }
        if (defaults.bool(forKey: K.DefaultKey.SearchOption.onlyMembersDiscount))  {
            searchOptions.append(SearchOption.memberDiscountScheme)
        }
        return searchOptions
    }

}

extension UserDefaults {
    func setString(_ string:String, forKey:String) {
        set(string, forKey: forKey)
    }
}
