//
//  DictionaryExtensions.swift
//  pubCrawler
//
//  Created by Michael Neilens on 11/07/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {
    
    //Returns an array of values for a particular key
    //e.g. json = {"a":["xx","yy","zz"],"b":["jjj","kkk","lll"]}
    //x=getValues(json,"a","default")
    //Thus gives x a value of ["xx","yy","zz"]
    func getValues <U>(forKey:String, withDefault:U) -> [U]
    {
        guard let values = self[forKey] as? [U] else {
            
            return [U]()
        }
        return values
    }
    
    //returns a true if the value of a json element is the same as a specified value/. e.g.for json {"trueValue":"y"} if trueValue="y" then function returns true.
    func getBoolValue <U:Equatable> (forKey:String, trueIfValueIs trueValue:U)->Bool {
        guard let value = self[forKey] as? U else { return false }
        
        return (value == trueValue) 
    }
    // returns the status and text of a Json message with format "{Message:{Status:<int>,Text:<string>},.....}"
    var errorStatus: (Int, String) {
        let message =  self[K.message]           as? [String:Any] ?? [String:Any]()
        let status  =  message[K.Message.status] as? Int          ?? -999
        let text    =  message[K.Message.text]   as? String       ?? "No message"
        
        return (status, text)
    }
    
    //converts a dictionary into a list of URL query parameters, e.g. ["key":"val","key2":"val2"]= is converted to &key=val&key2=val2
    //the value in the key/value pair has space replaced by +.
    var paramList:String {
        var paramList = ""
        for (key, value) in self {
            let paramKey = key
            let paramValue = value as! String
            paramList = paramList + "&\(paramKey)=\(paramValue.cleanQString)"
        }
        return paramList
    }
}
