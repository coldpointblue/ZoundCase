//  ----------------------------------------------------
//
//  DetailView.swift
//  Version 1.0
//
//  Unique ID:  907EF3A0-C273-416A-9069-41881C85E069
//
//  part of the ZoundCase™ product.
//
//  Written in Swift 5.0 on macOS 12.5
//
//  https://github.com/coldpointblue
//  Created by Hugo Diaz on 03/09/22.
//
//  ----------------------------------------------------

//  ----------------------------------------------------
/*  Goal explanation:  See one cryptocurrency in detail.   */
//  ----------------------------------------------------

import SwiftUI
import Combine

struct DetailView: View {
    @StateObject private var cryptoMktViewModel = CryptoMarketViewModel()

    var chosenIndexSymbol: String = ""
    static var favouriteSymbolsSet: Set<String> = []
    @State private var isFavourite = false

    private let inputUpdate: PassthroughSubject<CryptoMarketViewModel.SpecificInput, Never> = .init()

    var body: some View {
        VStack {

            HStack {
                Button {
                    cryptoMktViewModel.bindJSONData()
                    inputUpdate.send(.refreshButtonTapped)
                    // Dismiss from here as well.
                } label: {
                    Text("Refresh")
                }
                .padding([.vertical])
                .buttonStyle(.bordered)
            }

            ZStack {
                Color.blue.ignoresSafeArea().opacity(0.2)

                VStack {
                    Spacer()
                    HStack {
                        Group {
                            Text("Cryptocurrency Details")
                        }.multilineTextAlignment(.leading)
                    }
                    Spacer()
                    VStack {
                        Text("Fine print goes here. =P")
                    }
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .shadow(radius: 3)
                }
            }
            HStack {
                toggleFavouriteButton()
                Spacer()
            }
            Spacer()
        }
        .onAppear {
            isFavourite = DetailView.favouriteSymbolsSet.contains(chosenIndexSymbol)
        }
        .navigationBarTitle("Client", displayMode: .inline)
    }

}

extension DetailView {
    fileprivate func toggleFavouriteButton() -> some View {
        return Button {
            isFavourite.toggle()
            if isFavourite {
                DetailView.favouriteSymbolsSet.insert(chosenIndexSymbol)
            } else {
                DetailView.favouriteSymbolsSet.remove(chosenIndexSymbol)
            }
        } label: {
            Image(systemName: (isFavourite ? "heart.fill" : "heart"))
                .foregroundColor(isFavourite ? .red : .blue)
        }
        .padding(.leading)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
