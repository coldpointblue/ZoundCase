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
