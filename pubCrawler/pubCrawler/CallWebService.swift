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

// A factory class or struct will call MNWebService.
/* The factory is a WebServiceCallerType and therefore must have properties for:
 errorDelegate: i.e. the delegate for an error message, usually in the view controller that wants a new or updated model object
 serviceName: a string describing what the service does which is shown in the default error message
 
 WebServiceCallerType has default implentations for:
    call: this uses the getJson function within defaultWebService object, which is set to WebService()
    faledGettingJson: this is part of JSONResponseDelegate and calls the errorDelegate. Thid could be overwritten if the factory wants to return a bespoke error message.
 */

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
        errorDelegate.requestFailed(error:JSONError.ConversionFailed, errorText:errorText, errorTitle:"Could not " + serviceName)
    }

}


