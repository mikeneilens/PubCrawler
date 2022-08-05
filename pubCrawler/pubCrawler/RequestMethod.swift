//
//  RequestMethod.swift
//  MNWebServiceCall
//
//  Created by Michael Neilens on 03/12/2017.
//  Copyright © 2017 Michael Neilens. All rights reserved.
//

import Foundation

public enum RequestMethod {
    case Get
    case Post
    case Put
    case Patch
    case Delete
    
    var asString:String {
        switch self {
        case .Get: return "GET"
        case .Post: return "POST"
        case .Put: return "PUT"
        case .Patch: return "PATCH"
        case .Delete: return "DELETE"
        }
    }
}

