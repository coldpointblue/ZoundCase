//  ----------------------------------------------------
//
//  CryptoValueModel.swift
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

    let pointInTime: Int
    let symbol, baseAsset: String
    let quoteAsset: QuoteAsset
    let lastPrice, highPrice, lowPrice: String
    let openPrice: String
    let bidPrice, askPrice: String
    let volume: String

    enum CodingKeys: String, CodingKey {
        case pointInTime = "at"
        case symbol, baseAsset
        case quoteAsset
        case lastPrice, highPrice, lowPrice
        case openPrice
        case bidPrice, askPrice
        case volume
    }

    static var exampleCryptoValue = CryptoValue(pointInTime: 1661870066000,
                                                symbol: "yggusdt", baseAsset: "ygg",
                                                quoteAsset: QuoteAsset.usdt,
                                                lastPrice: "0.5266", highPrice: "0.5308", lowPrice: "0.5266",
                                                openPrice: "0.5275",
                                                bidPrice: "0.4992", askPrice: "0.5151",
                                                volume: "148.6"
    )
}

enum QuoteAsset: String, Codable, CaseIterable {
    case btc
    case inr
    case usdt
    case wrx
}
