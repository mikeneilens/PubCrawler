//
//  WebService.swift
//  MNWebServiceCall
//
//  Created by Michael Neilens on 21/10/2017.
//  Copyright © 2017 Michael Neilens. All rights reserved.
//

import Foundation

public protocol MNWebService {
    func getJson(forRequest request:Request, delegate:JSONResponseDelegate)
}

public protocol JSONResponseDelegate  {
    func finishedGetting(json:[String:Any])
    func failedGettingJson(error:Error)
}

public struct WebService:MNWebService {
    
    public init(){}
    public func getJson(forRequest request:Request, delegate:JSONResponseDelegate) {
        
        guard let url = URL(string: request.urlString) else {
            print("urlString: " + request.urlString )
            self.returnFailure(error: JSONError.InvalidURL, delegate:delegate)
            return
        }
        
        let urlRequest = URLRequest(url: url, requestMethod: request.requestMethod, httpHeaders: request.httpHeaders, httpBody: request.httpBody)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let completion = {(data:Data?, response:URLResponse?, error:Error?) in
            self.dataHandler(data: data, response: response, error: error, delegate:delegate)
        }
        
        let dataTask = session.dataTask(with: urlRequest, completionHandler:completion)
        dataTask.resume()
    }
    
    func dataHandler(data:Data?, response:URLResponse?, error:Error?, delegate:JSONResponseDelegate) {
        if let error = error {
            print("URLSessionDataTask error \(error)")
            self.returnFailure(error: JSONError.ErrorWithData, delegate:delegate)
        }
        
        do {
            if let data = data {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.returnSuccess(json: json, delegate:delegate)
                }
            } else {
                self.returnFailure(error: JSONError.NoData, delegate:delegate)
            }
        } catch {
            print(error)
            self.returnFailure(error: JSONError.ConversionFailed, delegate:delegate)
        }
    }
    
    private func returnSuccess(json:NSDictionary, delegate:JSONResponseDelegate) {
        if let jsonDict = json as? [String:Any] {
            DispatchQueue.main.async {
                delegate.finishedGetting(json: jsonDict)
            }
        } else {
            print("Weird json serialisation error")
        }
    }
    private func returnFailure(error:Error, delegate:JSONResponseDelegate) {
        print("Error: \(error)")
        DispatchQueue.main.async {
            delegate.failedGettingJson(error:error)
        }
    }
}

extension URLRequest {
    init(url:URL, requestMethod:RequestMethod, httpHeaders:[String:String]?, httpBody:Data?) {
        self = URLRequest(url: url)
        self.httpMethod = requestMethod.asString
        self.allHTTPHeaderFields=httpHeaders
        self.httpBody = httpBody
    }
}
