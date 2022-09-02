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
/*  Goal explanation:  Show main UI for values of cryptocurrencies. */
//  ----------------------------------------------------

import SwiftUI

struct ContentView: View {
    @State var network = NetworkService()
    @State var jsonData: ExchangeRates = []
    @StateObject var centralBankUpdate = CentralBankDelegate()
    @State var isSwedishMoney: Bool = false
    @State var exchangeRateDollarSEK: Double = 10.0
    // NOTE: Cryptocurrencies in JSON are listed with INR (Indian Rupee).

    var body: some View {
        VStack {
            Text("JSON has\n" + String(jsonData.count) + " prices listed.")
                .multilineTextAlignment(.center)
                .padding(.top)
            Group {
                HStack {
                    titleWithIcon()
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

            // Or load XML async with a different one.
            centralBankUpdate.loadCentralBankRates()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
