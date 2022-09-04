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

// MARK: - Network helpers.
func doubleCheckWebAddress(_ givenAddress: String) -> String {
    // In Production this would be actual verification for source address parts.
    guard let liveWebURL = URL(string: givenAddress),
          let validWebURL = URLRequest(url: liveWebURL).url?.absoluteString else {
        return ""
    }
    return validWebURL
}

#if PRODUCTION
#else
// MARK: - Debugging helpers to print fetched JSON data or response status code.
private func debugPrintIncomingData(_ incomingData: Data) {
    print("\r\r" + String(data: incomingData, encoding: .utf8)! +
            "\r——————————————>>>DOWNLOADED", terminator: "\r")
}

private func debugPrintStatusCode(_ webResponse: URLResponse) {
    print((webResponse as? HTTPURLResponse)?.statusCode as Any,
          terminator: " <<<——— RESPONSE statusCode\r\r")
}
#endif

// MARK: - Network Service to fetch crypto numbers JSON data.
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
        } catch {
            throw NSError(domain: World.webDataDownloadErrorMessage, code: 0, userInfo: nil)
        }
        return remoteJSON
    }
    // Disabled this in favor of Combine auto-load.
    //    Task {
    //        wholeMarketViewModel.jsonDataTruthInstance = try await wholeMarketViewModel.network.fetchSpecificJSON()
    //    } // Load JSON async one way.

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
            let jsonUpdates = try JSONDecoder().decode(YourType.self, from: incomingData)
            return jsonUpdates
        } catch {
            print(error, terminator: World.jsonErrorDecodingMessage)
            // swiftlint:disable:next force_cast
            return "" as! YourType
        }
    }
}
