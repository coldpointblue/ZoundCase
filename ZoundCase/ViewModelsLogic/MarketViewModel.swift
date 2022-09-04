//  ----------------------------------------------------
//
//  MarketViewModel.swift
//  Version 1.0
//
//  Unique ID:  2A0F5B77-494F-41E9-BD1F-AC6AE6E9F9E1
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
/*  Goal explanation:  Connect market data business logic
 and UI needs.  */
//  ----------------------------------------------------

import SwiftUI
import Combine

class CryptoMarketViewModel: ObservableObject {
    @Published var jsonDataTruthInstance: ExchangeRates = []

    // Services…
    @Published var network = NetworkService()
    @Published var centralBankUpdate = CentralBankDelegate()

    // Vars used in business logic.
    @Published var exchangeRateDollarSEK: Double = 0.0

    // Vars used in UI…
    @Published var statusFlash: String = ""
    @Published var totalShown: String = ""
    @Published var searchQueryTyped: String = ""
    var searchFilterMatches: ExchangeRates {
        return searchQueryTyped == "" ? jsonDataTruthInstance : jsonDataTruthInstance.filter {
            $0.baseAsset.contains(searchQueryTyped.lowercased())
        }
    }

    // Init…
    private let webSourceCryptoMarket: CryptoMarketQuoteProtocolType
    private var cancellables = Set<AnyCancellable>()

    init(cryptoMarketQuoteType: CryptoMarketQuoteProtocolType = CryptoMarketQuoteService()) {
        self.webSourceCryptoMarket = cryptoMarketQuoteType

        $searchQueryTyped
            .map { $0.isEmpty ? "∅" : "🌈 \(self.searchQueryTyped) shown." }
            .assign(to: &$totalShown)
    }

    // Messages as specific Input & Output triggers…
    enum SpecificInput {
        case viewDidAppear
        case refreshButtonTapped
    }
    let inputUpdateMessage: PassthroughSubject<CryptoMarketViewModel.SpecificInput, Never> = .init()

    enum SpecificOutput {
        case downloadFailed(error: Error)
        case downloadMarketSuccess(entireMarketQuote: ExchangeRates)
        case toggleButton(isEnabled: Bool)
    }
    private let outputUpdateMessage: PassthroughSubject<SpecificOutput, Never> = .init()

    // Moving data through…
    func transform(inputTrigger: AnyPublisher<SpecificInput, Never>) -> AnyPublisher<SpecificOutput, Never> {
        inputTrigger.sink { [weak self] event in
            switch event {
            case .viewDidAppear, .refreshButtonTapped:
                self?.nowGetMarketQuotesJSON()
            }
        }.store(in: &cancellables)
        return outputUpdateMessage.eraseToAnyPublisher()
    }

    fileprivate func nowGetMarketQuotesJSON() {
        outputUpdateMessage.send(.toggleButton(isEnabled: false))
        webSourceCryptoMarket.downloadCryptoMarketQuotes()
            .sink { [weak self] completion in
                self?.outputUpdateMessage.send(.toggleButton(isEnabled: true))
                if case .failure(let error) = completion {
                    self?.outputUpdateMessage.send(.downloadFailed(error: error))
                }
            } receiveValue: { [weak self] everyCurrentQuote in
                self?.outputUpdateMessage.send(.downloadMarketSuccess(entireMarketQuote: everyCurrentQuote))
            }.store(in: &cancellables)
    }

    func bindJSONData() {
        let output = self.transform(inputTrigger: inputUpdateMessage.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .downloadMarketSuccess(let everyQuoteInMarket):
                    self?.jsonDataTruthInstance = everyQuoteInMarket
                case .downloadFailed(let error):
                    self?.statusFlash = error.localizedDescription
                case .toggleButton(let isEnabled):
                    print("isEnabled \(isEnabled)")
                }
            }
            .store(in: &cancellables)
    }
}
