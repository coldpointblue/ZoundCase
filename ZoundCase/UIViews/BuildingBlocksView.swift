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
            isSwedishMoney.toggle()
        } label: {
            Label((isSwedishMoney ? "  SEK" : "  USD"), systemImage: "arrow.left.arrow.right")
                .font(Font.headline.weight(.bold))
                .foregroundColor(.blue)
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

// MARK: - Slider to modify the Trading Period for trend calculations.
extension ContentView {
    func tradingPeriodSlider(_ keepEyeOn: inout Binding<Double>) -> some View {
        return Group {
            // swiftlint:disable:next line_length
            Text("Trading Period is \((keepEyeOn.wrappedValue == 0) ? 0 : -keepEyeOn.wrappedValue, specifier: "%.1f") elapsed time.")
            HStack {
                Text("Before")  // Text outside Slider to keep without shadow for now.
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

// MARK: - Content list with cryptocurrencies and their numbers.
extension ContentView {
    func listEveryCryptoPrice() -> some View {
        return List {
            ForEach(QuoteAsset.allCases, id: \.rawValue) { oneCurrency in

                Section(header: Text(oneCurrency.rawValue)) {
                    ForEach(jsonData) { (cryptoUpdate: CryptoValue) in
                        if cryptoUpdate.quoteAsset == oneCurrency {
                            HStack {
                                HStack {
                                    Spacer()
                                    VStack.init(alignment: SwiftUI.HorizontalAlignment.center) {
                                        leadingFigures(cryptoUpdate)
                                    }
                                }
                                HStack {
                                    trendDirection(cryptoUpdate)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Show details of tapped selection.
                    }
                }

            }

        }
        .listStyle(SidebarListStyle())
    }
}

// MARK: - Numbers Row UI Presentation of Contents.
extension ContentView {
    fileprivate func leadingFigures(_ cryptoUpdate: CryptoValue) -> some View {
        return Group {
            Text(cryptoUpdate.symbol)
                .font(SwiftUI.Font.headline)
            Text(cryptoUpdate.baseAsset)
                .multilineTextAlignment(.trailing)
                .font(SwiftUI.Font.subheadline)
        }
        .padding(.horizontal)
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
}
