//  ----------------------------------------------------
//
//  Constants.swift
//  Version 1.0
//
//  Unique ID:  2B9F256D-91BD-46B1-A488-F142F575D6D6
//
//  part of the ZoundCase™ product.
//
//  Written in Swift 5.0 on macOS 12.5
//
//  https://github.com/coldpointblue
//  Created by Hugo Diaz on 01/09/22.
//
//  ----------------------------------------------------

//  ----------------------------------------------------
/*  Goal explanation:  Keep prototyping constants in one place
 to alter easily. */
//  ----------------------------------------------------

import Foundation

struct World {
    static let cryptoPriceUpdateURL = "https://api.wazirx.com/sapi/v1/tickers/24hr"

    static let sourceURLInvalidErrorMessage: String = "\r—————— invalid URL\r"
    static let jsonNoDataErrorMessage: String = "Network Error:\n  Data\n      missing"
    static let webDataDownloadErrorMessage: String = "\r—————— data download ERROR\r"
    static let jsonErrorDecodingMessage: String = "\r—————— JSON Decoder ERROR\r"
}
