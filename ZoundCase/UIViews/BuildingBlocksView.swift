//  ----------------------------------------------------
//
//  BuildingBlocksView.swift
//  Version 1.0
//
//  Unique ID:  690EAB92-49F3-4FA3-8460-8F1CC1182DF0
//
//  part of the ZoundCase™ product.
//
//  Written in Swift 5.0 on macOS 12.5
//
//  https://github.com/coldpointblue
//  Created by Hugo Diaz on 02/09/22.
//
//  ----------------------------------------------------

//  ----------------------------------------------------
/*  Goal explanation:  Useful info building blocks for main UI.  */
//  ----------------------------------------------------

import SwiftUI

// MARK: - Top banner, title and button.
extension ContentView {
    var deviceWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    func titleWithIcon() -> some View {
        return Group {
            Text("CryptoValues")
                .font(Font.title.weight(.bold))
            Image(systemName: "chart.line.uptrend.xyaxis")
                .frame(height: .none)
        }
        .foregroundColor(.mint)
    }

    func moneyShownButton() -> some View {
        return Button {
            wholeMarketViewModel.isSwedishMoney.toggle()
        } label: {
            Label((wholeMarketViewModel.isSwedishMoney ? "  SEK" : "  USD"), systemImage: "arrow.left.arrow.right")
                .font(Font.headline.weight(.bold))
                .foregroundColor(.blue)
                .padding(.horizontal)
                .frame(maxWidth: deviceWidth / 3)
        }
        .padding([.vertical], 8)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(wholeMarketViewModel.isSwedishMoney ? .yellow : .white)
                .opacity(World.buttonTintAmount)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .strokeBorder(wholeMarketViewModel.isSwedishMoney ? .blue :
                                .red.opacity(World.buttonTintAmount), lineWidth: 4)
        )
        .buttonStyle(PressScale())
    }

    struct PressScale: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 1.2 : 1)
                .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
        }
    }
}

// MARK: - Slider to modify the Trading Time Period for trend calculations.
extension ContentView {
    func tradingPeriodSlider(_ keepEyeOn: inout Binding<Double>) -> some View {
        return Group {
            // swiftlint:disable:next line_length
            Text("Trading Period is \((keepEyeOn.wrappedValue == 0) ? 0 : -keepEyeOn.wrappedValue, specifier: "%.1f") hours elapsed time.")
            HStack {
                Text("Before")  // Text outside Slider, to keep without shadow for now.
                Slider(value: keepEyeOn, in: -200 ... 0, step: 0.5) {  } // Use the numbers here later.
                    .cornerRadius(13)
                    .shadow(color: .purple, radius: 2, x: -2, y: 1)
                    .padding(.horizontal)
                    .accentColor(Color.primary.opacity(0.03))
                Text("Now")
            }
            .padding([.horizontal])
        }
    }
}

// MARK: - Line specifying money being displayed within list.
extension ContentView {
    func moneyLine() -> some View {
        return HStack {
            Group {
                HStack {
                    Text("Trade…")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                HStack {
                    Spacer()
                    Text(" …in " +
                            "\(wholeMarketViewModel.isSwedishMoney ? "SEK" : "USD")"
                            + ":")
                }
                Spacer()
            }
            .padding(.bottom, 3)
        }
    }
}

// MARK: - Content list with cryptocurrencies and their numbers.
extension ContentView {
    func listEveryCryptoPrice() -> some View {
        return List {
            ForEach(QuoteAsset.allCases, id: \.rawValue) { oneCurrency in

                Section(header: Text(oneCurrency.rawValue)) {
                    ForEach(wholeMarketViewModel.jsonDataTruthInstance) { (cryptoUpdate: CryptoValue) in
                        if cryptoUpdate.quoteAsset == oneCurrency {
                            HStack {
                                Text("\u{00a0}\u{00a0}\u{00a0}")
                                HStack {
                                    VStack.init(alignment: SwiftUI.HorizontalAlignment.center) {
                                        leadingFigures(cryptoUpdate)
                                    }
                                }
                                HStack {
                                    trendDirection(cryptoUpdate)
                                    Spacer()
                                }
                            }
                            .contentShape(Rectangle())
                            .font(.system(.callout, design: .monospaced))
                            .onTapGesture {
                                wholeMarketViewModel.selectedCurrency = cryptoUpdate
                                showCryptoDetailView.toggle()
                            }
                        }
                    }
                }

            }

        }
        .searchable(text: $wholeMarketViewModel.searchQueryTyped, prompt: "Search Cryptocurrency Symbol")
        .listStyle(SidebarListStyle())
    }
}

// MARK: - Numbers Row UI Presentation of Contents.
extension ContentView {
    fileprivate func leadingFigures(_ cryptoUpdate: CryptoValue) -> some View {
        return Group {
            Text(cryptoUpdate.baseAsset)
                .multilineTextAlignment(.trailing)
                .font(SwiftUI.Font.subheadline)
            Text(cryptoUpdate.symbol)
                .font(SwiftUI.Font.headline)
        }
        .padding(.horizontal)
    }

    fileprivate func trendDirection(_ cryptoUpdate: CryptoValue) -> some View {
        let openPrice = Decimal(string: cryptoUpdate.openPrice)!
        let lastPrice = Decimal(string: cryptoUpdate.lastPrice)!
        let isLessThanZero = (lastPrice - openPrice).isLess(than: 0)
        let perhapsIcon =  (lastPrice.isEqual(to: openPrice)
                                ? "timelapse" : "arrowtriangle.up.fill")
        return Group {
            Image(systemName: isLessThanZero ?
                    "arrow.down.forward" : perhapsIcon)
                .foregroundColor(isLessThanZero ? .blue : .red)
                .frame(height: .none)
            VStack {
                Group {
                    Text(wholeMarketViewModel.moneyRate(amount: cryptoUpdate.lastPrice))
                    Text(wholeMarketViewModel.moneyRate(amount: cryptoUpdate.openPrice))
                        .font(SwiftUI.Font.footnote)
                        .foregroundColor(.blue)
                }
                .multilineTextAlignment(.trailing)
            }
        }
    }
}

extension ContentView {
    func moneyRates() -> Text {
        let moneyRate = wholeMarketViewModel.centralBankUpdate.eurosInExchange
        return Text("\(moneyRate["SEK"] ?? 0)🇸🇪 … " + "\(moneyRate["USD"] ?? 0)🇺🇸 … "
                        + "\(moneyRate["INR"] ?? 0)🇮🇳")
    }
}
