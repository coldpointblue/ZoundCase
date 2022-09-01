//  ----------------------------------------------------
//
//  CurrencyModel.swift
//  Version 1.0
//
//  Unique ID:  4FE40B77-4F60-4E6B-A4F8-90D27B360236
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
/*  Goal explanation:  Define JSON data structure of price updates
 for cryptocurrencies. */
//  ----------------------------------------------------

import Foundation

typealias ExchangeRates = [CryptoValue]

// MARK: - CryptoValue
struct CryptoValue: Codable, Identifiable, Hashable {
    let id = UUID().uuidString

    let quoteAsset: QuoteAsset

    let symbol, baseAsset: String
    let openPrice, lowPrice, highPrice, lastPrice: String
    let volume, bidPrice, askPrice: String
    let pointInTime: Int

    enum CodingKeys: String, CodingKey {
        case quoteAsset
        case symbol, baseAsset
        case openPrice, lowPrice, highPrice, lastPrice
        case volume, bidPrice, askPrice
        case pointInTime = "at"
    }
}

enum QuoteAsset: String, Codable, CaseIterable {
    case btc
    case inr
    case usdt
    case wrx
}

/*  Example JSON item…
 {
 "symbol":"yggusdt",
 "baseAsset":"ygg",
 "quoteAsset":"usdt",
 "openPrice":"0.5275",
 "lowPrice":"0.5266",
 "highPrice":"0.5308",
 "lastPrice":"0.5266",
 "volume":"148.6",
 "bidPrice":"0.4992",
 "askPrice":"0.5151",
 "at":1661870066000
 }
 */
