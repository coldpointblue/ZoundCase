//  ----------------------------------------------------
//
//  CryptoNetwork.swift
//  Version 1.0
//
//  Unique ID:  7B2F6E53-7FCE-4AAF-B057-9B78868D79DD
//
//  part of the ZoundCase™ product.
//
//  Written in Swift 5.0 on macOS 12.5
//
//  https://github.com/coldpointblue
//  Created by Hugo Diaz on 04/09/22.
//
//  ----------------------------------------------------

//  ----------------------------------------------------
/*  Goal explanation:  Fetch cryptocurrency JSON prices
 automatically updating UI using Combine.   */
//  ----------------------------------------------------

import Foundation
import Combine

// MARK: - Combine Network Service to download crypto numbers JSON data.
protocol CryptoMarketQuoteProtocolType {
    func downloadCryptoMarketQuotes() -> AnyPublisher<ExchangeRates, Error>
}

class CryptoMarketQuoteService: CryptoMarketQuoteProtocolType {

    func downloadCryptoMarketQuotes() -> AnyPublisher<ExchangeRates, Error> {
        let validAddress = doubleCheckWebAddress(World.cryptoPriceUpdateURL)
        let url = URL(string: validAddress)!
        let request = URLRequest(url: url)
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }.map({
                $0.data
            })
            .decode(type: ExchangeRates.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
