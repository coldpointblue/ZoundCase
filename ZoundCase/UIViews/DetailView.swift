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
    @EnvironmentObject var cryptoMktViewModel: CryptoMarketViewModel

    var chosenSymbolID: String = ""
    static var favouriteSymbolsSet: Set<String> = []
    @State private var isFavourite = false

    private let inputUpdate: PassthroughSubject<CryptoMarketViewModel.SpecificInput, Never> = .init()

    var body: some View {
        VStack {
            VStack {
                HStack {
                    refreshButton()
                    Text("Cryptocurrency Details")
                }
                whichCurrency()
            }
            Spacer()

            VStack {
                HStack {
                    Spacer()
                    comparisonSection()
                    wantSection()
                    Spacer()
                }
                .padding(.horizontal)
                Text("Volume…\((((cryptoMktViewModel.selectedCurrency?.volume)!)))")
            }

            ZStack {
                Color.blue.ignoresSafeArea().opacity(0.2)

                VStack {
                    Spacer()
                    Group {
                        Text("Recent Trend")
                    }.multilineTextAlignment(.leading)

                    trendGraph()
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
            isFavourite = DetailView.favouriteSymbolsSet.contains(chosenSymbolID)
        }
    }
}

extension DetailView {
    fileprivate func refreshButton() -> some View {
        return Button {
            cryptoMktViewModel.bindJSONData()
            inputUpdate.send(.refreshButtonTapped)
        } label: {
            Text("Refresh")
        }
        .padding([.vertical])
        .buttonStyle(.bordered)
    }
}

extension DetailView {
    // Displays the specific numbers for this currency.
    fileprivate func whichCurrency() -> some View {
        let currency = cryptoMktViewModel.selectedCurrency
        return Group {
            Text("Symbol:  " + (currency?.symbol)!
                    + ("     +\((Double((currency!.askPrice))!/Double((currency!.openPrice))!).format(2))" + "%")
            )
            Text("Base Asset  " + (cryptoMktViewModel.selectedCurrency!.baseAsset))
            Text("Quote Asset  " + (cryptoMktViewModel.selectedCurrency!.quoteAsset).rawValue)
        }
    }

    fileprivate func comparisonSection() -> some View {
        let detailInfo = cryptoMktViewModel.selectedCurrency
        return HStack {
            VStack {
                Text("Last  " + detailInfo!.lastPrice)
                Text("High  " + detailInfo!.highPrice)
                Text("Low  " + detailInfo!.lowPrice)
            }
        }
    }
    fileprivate func wantSection() -> some View {
        let detailInfo = cryptoMktViewModel.selectedCurrency
        return HStack {
            Spacer()
            VStack {
                Group {
                    Text(detailInfo!.openPrice + " Open")
                    Text(detailInfo!.bidPrice + " Bid")
                    Text(detailInfo!.askPrice + " Ask")
                }
                .multilineTextAlignment(.leading)
            }
        }
    }
}

extension DetailView {
    // Not yet implemented… This is just mock visual.
    fileprivate func trendGraph() -> some View {
        let wide = 24.0
        return ZStack {
            Rectangle()
                .fill(.mint)
                .frame(width: 200, height: 200)
            HStack {
                Spacer()
                Group {
                    Rectangle()
                        .frame(width: wide, height: 55)
                    Rectangle()
                        .frame(width: wide, height: 22)
                    Rectangle()
                        .frame(width: wide, height: 37)
                }
                Spacer()
            }
        }
    }
}

extension DetailView {
    fileprivate func toggleFavouriteButton() -> some View {
        return Button {
            isFavourite.toggle()
            if isFavourite {
                DetailView.favouriteSymbolsSet.insert(chosenSymbolID)
            } else {
                DetailView.favouriteSymbolsSet.remove(chosenSymbolID)
            }
        } label: {
            Image(systemName: (isFavourite ? "heart.fill" : "heart"))
                .foregroundColor(isFavourite ? .red : .blue)
        }
        .padding(.leading)
    }
}

struct DetailView_Previews: PreviewProvider {
    @EnvironmentObject var cryptoMktViewModel: CryptoMarketViewModel

    static var previews: some View {
        DetailView()
    }
}
