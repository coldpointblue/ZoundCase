//  ----------------------------------------------------
//
//  ContentView.swift
//  Version 1.0
//
//  Unique ID:  7D65490D-9136-4D39-B042-6CA489AACAE2
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
/*  Goal explanation:  Show UI for values of cryptocurrencies. */
//  ----------------------------------------------------

import SwiftUI

struct ContentView: View {
    @State var jsonData: ExchangeRates = []
    @State var isSwedishMoney: Bool = false
    @State var exchangeRateDollarSEK: Double = 10.0

    @StateObject var centralBankUpdate = CentralBankDelegate()

    var body: some View {
        let network = NetworkService()

        VStack {
            Text("JSON has\n" + String(jsonData.count) + " prices listed.")
                .multilineTextAlignment(.center)
                .padding(.top)
            Group {
                HStack {
                    chartIcon()
                    moneyShownButton()
                }
            }
            listEveryCryptoPrice()
                .listStyle(.plain)
        }
        .onAppear(perform: {
            Task {
                jsonData = try await network.fetchSpecificJSON()
            } // Load JSON async one way.

            // Or load with another with XML async.
            centralBankUpdate.loadCentralBankRates()
        })
    }

    func moneyRate(_ isFromDollar: Bool) -> Double {
        if isFromDollar {
            return centralBankUpdate.currentSEK / centralBankUpdate.currentUSD
        } else {
            return centralBankUpdate.currentUSD / centralBankUpdate.currentSEK
        }
    }
}

// UI Presentation of Contents…
extension ContentView {
    var deviceWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    var deviceHeight: CGFloat {
        UIScreen.main.bounds.height
    }

    fileprivate func trendDirection(_ cryptoUpdate: CryptoValue) -> some View {
        let whichWay = (cryptoUpdate.lastPrice >= cryptoUpdate.openPrice)
        let perhapsIcon = (cryptoUpdate.lastPrice == cryptoUpdate.openPrice
                            ? "timelapse" : "chart.line.uptrend.xyaxis.circle")
        return Group {
            Image(systemName: whichWay ?
                    perhapsIcon : "arrow.down.forward")
                .foregroundColor(whichWay ? .red : .blue)
                .frame(height: .none)
            VStack {
                Text(cryptoUpdate.lastPrice)
                Text(cryptoUpdate.openPrice)
                    .font(SwiftUI.Font.footnote)
                    .foregroundColor(.blue)
            }
        }
    }

    fileprivate func leadingFigures(_ cryptoUpdate: CryptoValue) -> some View {
        return Group {
            Text(cryptoUpdate.symbol)
                .font(SwiftUI.Font.headline)
            Text(cryptoUpdate.baseAsset)
                .multilineTextAlignment(.trailing)
                .font(SwiftUI.Font.subheadline)
        }
    }

    fileprivate func listEveryCryptoPrice() -> some View {
        return List {
            ForEach(QuoteAsset.allCases, id: \.rawValue) { oneCurrency in

                Section(header: Text(oneCurrency.rawValue)) {
                    ForEach(jsonData) { (cryptoUpdate: CryptoValue) in
                        if cryptoUpdate.quoteAsset == oneCurrency {
                            HStack {
                                VStack.init(alignment: SwiftUI.HorizontalAlignment.center) {
                                    leadingFigures(cryptoUpdate)
                                }
                                trendDirection(cryptoUpdate)
                            }
                        }
                    }

                }
            }
        }
    }

    fileprivate func moneyShownButton() -> some View {
        return Button {
            isSwedishMoney.toggle()
        } label: {
            Text(isSwedishMoney ? "  SEK":"  USD")
                .font(Font.headline.weight(.bold))
                .foregroundColor(isSwedishMoney ? .blue : .blue)
                .padding(.horizontal)
                .frame(maxWidth: deviceWidth / 3)

        }
        .padding([.vertical], 8)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(isSwedishMoney ? .yellow : .white)
                .opacity(World.buttonTintAmount)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .strokeBorder(isSwedishMoney ? .blue : .red.opacity(World.buttonTintAmount), lineWidth: 4)
        )
    }

    fileprivate func chartIcon() -> some View {
        return Group {
            Text("CryptoValues")
                .font(Font.title.weight(.bold))
            Image(systemName: "chart.line.uptrend.xyaxis")
                .frame(height: .none)
        }
        .foregroundColor(.mint)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
