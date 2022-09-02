//  ----------------------------------------------------
//
//  Network.swift
//  Version 1.0
//
//  Unique ID:  248D9683-704D-4ED7-BF7A-A02E1578E5C2
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
/*  Goal explanation:  Fetch cryptocurrency web prices
 from remote JSON file to use locally. */
//  ----------------------------------------------------

import Foundation

// MARK: - NetworkService
class NetworkService {
    // The more sensible way… Quick & easy code during prototyping.
    @MainActor
    func fetchSpecificJSON() async throws -> ExchangeRates {
        let validAddress = doubleCheckWebAddress(World.cryptoPriceUpdateURL)
        guard validAddress != "" else {
            return []
        }
        var remoteJSON: ExchangeRates
        do {
            remoteJSON = try await self.fetchGenericData(validAddress)
            // NetworkService().fetchGenericData(validAddress)
        } catch {
            throw NSError(domain: World.webDataDownloadErrorMessage, code: 0, userInfo: nil)
        }
        return remoteJSON
    }

    // Generic Fetch Query for Data
    private func fetchGenericData<YourType: Codable>(_ sourceURLString: String) async throws -> YourType {
        guard let sourceURL = URL(string: sourceURLString) else {
            throw NSError(domain: World.sourceURLInvalidErrorMessage, code: 0, userInfo: nil)
        }

        do {
            let (incomingData, webResponse) = try await URLSession.shared.data(from: sourceURL)
            guard let httpResponse = webResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                #if PRODUCTION
                #else
                debugPrintStatusCode(webResponse)
                #endif
                throw NSError(domain: World.webDataDownloadErrorMessage, code: 0, userInfo: nil)
            }
            #if PRODUCTION
            #else
            // debugPrintIncomingData(incomingData)
            #endif
            let rateUpdates = try JSONDecoder().decode(YourType.self, from: incomingData)
            return rateUpdates
        } catch {
            print(error, terminator: World.jsonErrorDecodingMessage)
            // swiftlint:disable:next force_cast
            return "" as! YourType
        }
    }
}

func doubleCheckWebAddress(_ givenAddress: String) -> String {
    guard let liveWebURL = URL(string: givenAddress),
          let validWebURL = URLRequest(url: liveWebURL).url?.absoluteString else {
        return ""
    }
    return validWebURL
}

class CentralBankDelegate: NSObject, XMLParserDelegate, ObservableObject {
    var eurosInExchange: [String: Double] = [:]
    var wantedCurrencies: Set<String> = ["SEK", "USD", "INR"]

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

#if PRODUCTION
#else
// MARK: - Debugging Helpers
// Debugging helpers to print fetched JSON data or response status code.
private func debugPrintIncomingData(_ incomingData: Data) {
    print("\r\r" + String(data: incomingData, encoding: .utf8)! +
            "\r——————————————>>>DOWNLOADED", terminator: "\r")
}

private func debugPrintStatusCode(_ webResponse: URLResponse) {
    print((webResponse as? HTTPURLResponse)?.statusCode as Any,
          terminator: " <<<——— RESPONSE statusCode\r\r")
}
#endif
