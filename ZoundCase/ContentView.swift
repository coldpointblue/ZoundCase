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

    var body: some View {
        VStack {
            Text("JSON has\n" + String(jsonData.count) + " prices listed.")
                .padding()
                .multilineTextAlignment(.center)
            Spacer()
            Group {
                Text("CryptoValues")
                    .bold()
                    .foregroundColor(.red)
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.red)
                    .frame(height: .none)
            }

            List {
                ForEach(QuoteAsset.allCases, id: \.rawValue) { oneCurrency in

                    Section(header: Text(oneCurrency.rawValue)) {
                        ForEach(jsonData) { (cryptoUpdate: CryptoValue) in
                            if cryptoUpdate.quoteAsset == oneCurrency {
                                HStack {
                                    VStack.init(alignment: SwiftUI.HorizontalAlignment.leading) {
                                        Text(cryptoUpdate.symbol).font(SwiftUI.Font.headline)
                                        Text(cryptoUpdate.baseAsset).font(SwiftUI.Font.headline)
                                    }
                                    let whichWay = (cryptoUpdate.lastPrice >= cryptoUpdate.openPrice)
                                    Image(systemName: whichWay ?
                                            "chart.line.uptrend.xyaxis.circle" : "arrow.down.forward")
                                        .foregroundColor(whichWay ? .red : .blue)
                                        .frame(height: .none)
                                    Text(cryptoUpdate.lastPrice)
                                    Text(cryptoUpdate.openPrice).font(SwiftUI.Font.footnote)
                                }
                            }

                        }

                    }

                }
            }
            .listStyle(.plain)
        }
        .onAppear(perform: {
            Task {
                jsonData = try await NetworkService().fetchSpecificJSON()
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
