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

protocol WebServiceDelegate {
    func requestFailed(error:JSONError, errorText:String, errorTitle:String)
}

protocol WebServiceCallerType:JSONResponseDelegate {
    var errorDelegate:WebServiceDelegate {get} 
    var serviceName:String {get}
}

extension WebServiceCallerType {
    func call(withDelegate delegate:JSONResponseDelegate, url:String) {
        let request = Request(urlString: url)
        defaultWebService.getJson(forRequest:request, delegate:delegate)
    }
    func failedGettingJson(error:Error) {
        errorDelegate.requestFailed(error:JSONError.ConversionFailed, errorText:"Error connecting to internet", errorTitle:"Could not " + serviceName)
    }
    func failedGettingJson(error:JSONError, errorText:String) {
        errorDelegate.requestFailed(error:JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not" + serviceName)
    }

}


