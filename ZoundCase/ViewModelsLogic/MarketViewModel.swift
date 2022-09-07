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

    @Published var selectedCurrency: CryptoValue?  // Tap choice detail.

    // Services…
    // Not used but left here for discussion.   @Published var network = NetworkService()
    @Published var centralBankUpdate = CentralBankDelegate()
    @Published var isSwedishMoney: Bool = false
    // NOTE: Cryptocurrencies in JSON are listed with INR (Indian Rupee).

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

    func moneyRate(amount: String) -> String {
        // This needs to take into account the volume of the transaction to display?
        let exchange = centralBankUpdate.eurosInExchange
        let liveMoney = isSwedishMoney ? "SEK" : "USD"
        let ratio = Decimal(exchange[liveMoney]!) / Decimal((exchange["INR"]!))
        return "\((Decimal(string: amount)!) * ratio)".inXDigits(World.fixedDecimals)
    }
}

extension String {
    func actualDouble() -> Double {
        Double(self) ?? 0.0
    }
    func inXDigits(_ forcedDigits: Int) -> String {
        self.actualDouble().digitsSeen(forcedDigits)
    }
}

extension Double {
    func digitsSeen(_ digits: Int) -> String {
        let  fixedNumberFormatter = NumberFormatter()
        fixedNumberFormatter.minimumFractionDigits = digits
        fixedNumberFormatter.maximumFractionDigits = digits
        return fixedNumberFormatter.string(from: self as NSNumber) ?? "_.__"
    }
}

func precisePercent(_ numerator: String, _ denominator: String) -> String {
    guard let firstNumber = Decimal(string: numerator),
          let secondNumber = Decimal(string: denominator) else {
        return "-.--"
    }
    let firstStep = (firstNumber / secondNumber)
    let secondStep = (firstStep * 100)
    let lastStep = (secondStep - 100)
    let symbolFront = lastStep.isSignMinus ? "" : "+"
    if lastStep.isLess(than: Decimal(0.5)) {
        return "≈0.00"
    }
    return symbolFront + "\(lastStep)".inXDigits(2)
}
