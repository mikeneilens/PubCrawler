//
//  JSONError.swift
//  MNWebServiceCall
//
//  Created by Michael Neilens on 03/12/2017.
//  Copyright © 2017 Michael Neilens. All rights reserved.
//

import Foundation

enum JSONError: String, Error {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
    case ErrorWithData = "ERROR: Non-zero response from service"
    case InvalidURL = "ERROR: invalid URL"
}
