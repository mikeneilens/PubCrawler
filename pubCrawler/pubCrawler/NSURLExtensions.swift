//
//  NSURLExtensions.swift
//  pubCrawler
//
//  Created by Michael Neilens on 21/07/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import Foundation

//This takes a URL containing a query string and converts the query string into a dictionary of key/value pairs
extension URL{
    var queryParams:[String:Any] {
                
        var info = [String:String]()
        if let query {
            for parameter in query.components(separatedBy: "&"){
                let parts = parameter.components(separatedBy: "=")
                if parts.count > 1{
                    if let key = (parts[0] ).removingPercentEncoding, let value = (parts[1] ).removingPercentEncoding
                    {
                        info[key] = value
                    }
                }
            }
        }
        return info
    }
}
