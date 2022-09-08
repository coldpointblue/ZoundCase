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

    func moneyTradeRate(amount: String) -> String {
        // This needs to take into account the volume of the transaction to display? Cost per trade?
        let exchange = centralBankUpdate.eurosInExchange
        let liveMoney = isSwedishMoney ? "SEK" : "USD"
        let ratio = preciseRatio("\(exchange[liveMoney] ?? 0.0)", "\(exchange["INR"] ?? 0.0)")
        let mathDone = (Decimal(string: amount) ?? Decimal(0.0)) * ratio
        let result = (((mathDone * decimalPlaces()).wholePart) / decimalPlaces())
        return result.digitsSeen(World.fixedDecimals)
    }
}

extension String {
    func inXDigits(_ forcedDigits: Int) -> String {
        (Decimal(string: self) ?? Decimal(0.0)).digitsSeen(forcedDigits)
    }
}

extension Decimal {
    func digitsSeen(_ digits: Int) -> String {
        let  fixedNumberFormatter = NumberFormatter()
        fixedNumberFormatter.minimumFractionDigits = digits
        fixedNumberFormatter.maximumFractionDigits = digits
        return fixedNumberFormatter.string(from: self as NSNumber) ?? "_.__"
    }
}

extension Decimal {
    var wholePart: Self {
        var result = Decimal()
        var mutableSelf = self
        NSDecimalRound(&result, &mutableSelf, 0, self >= 0 ? .down : .up)
        return result
    }
}

func precisePercent(_ numerator: String, _ denominator: String) -> String {
    let calculation = (preciseRatio(numerator, denominator) * 100) - 100
    let result = ((calculation * 100).wholePart) / 100
    let symbolFront = result.isSignMinus ? "" : "+"
    return symbolFront + "\(result)"
}

func decimalPlaces() -> Decimal {
    return Decimal(sign: .plus, exponent: World.fixedDecimals, significand: Decimal(10))
}

func preciseRatio(_ numerator: String, _ denominator: String) -> Decimal {
    guard let firstNumber = Decimal(string: numerator),
          let secondNumber = Decimal(string: denominator) else {
        return Decimal(0)
    }
    let decimalPlaces = decimalPlaces()
    let calculation = ((decimalPlaces * firstNumber) / (secondNumber * decimalPlaces))
    return ((calculation * decimalPlaces).wholePart) / decimalPlaces
}
