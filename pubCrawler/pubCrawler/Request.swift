//
//  Request.swift
//  MNWebServiceCall
//
//  Created by Michael Neilens on 03/01/2018.
//  Copyright © 2018 Michael Neilens. All rights reserved.
//

import Foundation

struct Request {
    let urlString:String
    let requestMethod:RequestMethod
    let httpHeaders:[String:String]?
    let httpBody:Data?
    
    init(urlString:String, requestMethod:RequestMethod = .Get, httpHeaders:[String:String]?=nil, httpBody:Data?=nil) {
        self.urlString = urlString
        self.requestMethod = requestMethod
        self.httpHeaders = httpHeaders
        self.httpBody = httpBody
    }
    init(urlString:String, httpHeaders:[String:String]?=nil, httpBody:Data?=nil) {
        self = Request(urlString: urlString, requestMethod: RequestMethod.Get, httpHeaders: httpHeaders, httpBody: httpBody)
    }
}
