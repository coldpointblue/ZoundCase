//  ----------------------------------------------------
//
//  PrecisionMathHelp.swift
//  Version 1.0
//
//  Unique ID:  F8E29E0C-B704-430A-9CF7-9F8EAC1FA408
//
//  part of the ZoundCase™ product.
//
//  Written in Swift 5.0 on macOS 12.5
//
//  https://github.com/coldpointblue
//  Created by Hugo Diaz on 08/09/22.
//
//  ----------------------------------------------------

//  ----------------------------------------------------
/*  Goal explanation:  Helper functions for precision math with
 small fractions in currency exchanges. Accurate without skewing. */
//  ----------------------------------------------------

import Foundation

extension String {
    func keepXDigits(_ forcedDigits: Int) -> String {
        let digitsKept = (Decimal(string: self) ?? Decimal(0.0)).digitsSeen(forcedDigits)
        if self.hasPrefix("+") {
            return "+" + digitsKept
        }
        return digitsKept
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
