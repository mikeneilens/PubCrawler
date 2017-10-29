//
//  BoolExtensions.swift
//  pubCrawler
//
//  Created by Michael Neilens on 13/07/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import Foundation

extension Bool {
    func convertBool<U>(valueIfTrue trueValue:U, valueIfFalse falseValue:U) -> U   {
        //    This converts a true/false value to a generic value representing true or false, e.g. "Y"/"N" or 0/1
        if self == true  { return trueValue }
        else { return falseValue }
    }
}
