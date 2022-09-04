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
import Combine

struct ContentView: View {
    @StateObject var wholeMarketViewModel: CryptoMarketViewModel = CryptoMarketViewModel()

    @State var timeLine: Double = 0

    @State var showCryptoDetailView = false
    @State private var selectedClient: CryptoValue?  // Tap choice detail.

    var body: some View {
        var bindingToTimeLine = $timeLine

        VStack {
            moneyRates()
            Text("  JSON has\n"
                    + String(wholeMarketViewModel.jsonDataTruthInstance.count)
                    + " prices listed.")
                .multilineTextAlignment(.center)
                .padding(.top)
            Group {
                HStack {
                    titleWithIcon()
                    moneyShownButton()
                }
            }
            tradingPeriodSlider(&bindingToTimeLine)
            listEveryCryptoPrice()
                .listStyle(.plain)
        }
        .onAppear(perform: {
            // Or load XML async with a different one.
            wholeMarketViewModel.centralBankUpdate.loadCentralBankRates()

            // Or use the Combine robust automatic way.
            wholeMarketViewModel.bindJSONData()
            wholeMarketViewModel.inputUpdateMessage.send(.viewDidAppear)
        })
        .sheet(isPresented: $showCryptoDetailView) {
            DetailView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
