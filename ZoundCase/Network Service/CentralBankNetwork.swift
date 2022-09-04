//  ----------------------------------------------------
//
//  CentralBankNetwork.swift
//  Version 1.0
//
//  Unique ID:  2465F806-8597-4873-B3B2-A69602B4E7D8
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
/*  Goal explanation:  Fetch official money exchange rates
 to calculate prices for UI display. */
//  ----------------------------------------------------

import Foundation

// MARK: - Central Bank to fetch money XML data.
class CentralBankDelegate: NSObject, XMLParserDelegate, ObservableObject {
    @Published var eurosInExchange: [String: Double] = [:]
    @Published var wantedCurrencies: Set<String> = ["SEK", "USD", "INR"]

    // EU Central Bank has XML published every day with money rates.
    func loadCentralBankRates() {
        let validAddress = doubleCheckWebAddress(World.euCentralBankExchangeRateURL)
        guard validAddress != "" else {
            return
        }
        let url = URL(string: validAddress)!
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error in dataTaskWithRequest: \(error)")
                return
            }
            guard let data = data else {
                print("dataTaskWithRequest has nil data")
                return
            }

            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }

    // Extract current SEK and USD rates of exchange from official EU Central Bank data.
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        if elementName == "Cube" {
            var targetCurrency: String { attributeDict["currency"] ?? "" }
            var amount: String { attributeDict["rate"] ?? "" }

            if wantedCurrencies.allSatisfy(eurosInExchange.keys.contains) {
                return
            }

            if wantedCurrencies.contains(targetCurrency) {
                guard amount != "" else {
                    fatalError(" Fail fetching money rates.")
                }
                eurosInExchange[targetCurrency] = (amount as NSString).doubleValue
            }
        }
    }
}
