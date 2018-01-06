//
//  WebServiceCaller.swift
//  pubCrawler
//
//  Created by Michael Neilens on 06/01/2018.
//  Copyright © 2018 Michael Neilens. All rights reserved.
//

import Foundation
import MNWebServiceCall

var defaultWebService:MNWebService = WebService()

struct WebServieCaller {
    let webService:MNWebService
    init() {
        self.webService = defaultWebService
    }
    func call(withDelegate delegate:JSONResponseDelegate, url:String) {
        let request = Request(urlString: url)
        self.webService.getJson(forRequest:request, delegate:delegate)
    }
}

