//
//  SDSDecimalField.swift
//
//  Created by : Tomoaki Yagishita on 2021/04/11
//  © 2021  SmallDeskSoftware
//

import SwiftUI
import MathParser

public struct SDSDecimalField: View {
    @Binding var value: Decimal
    // formatter for display
    let formatter: NumberFormatter
    
    static public var defaultFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.generatesDecimalNumbers = true
        return formatter
    }
    
    public init(selection value: Binding<Decimal>, formatter: NumberFormatter = SDSDecimalField.defaultFormatter) {
        self._value = value
        self.formatter = formatter
    }
    
    public var body: some View {
        TextField("input here...", value: $value, formatter: CurrencyFormatter(formatter) )
            .multilineTextAlignment(.trailing)
    }
}

// Formatter for convert
class CurrencyFormatter: Formatter {
    static let digits = "0123456789+-*/()" + NumberFormatter().currencyDecimalSeparator

    static var displayFormatter:NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.generatesDecimalNumbers = true
        return formatter
    }
    let displayFormatter: NumberFormatter
    
    init(_ displayFormatter: NumberFormatter = CurrencyFormatter.displayFormatter) {
        self.displayFormatter = displayFormatter
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func string(for obj: Any?) -> String? {
        guard let decimal = obj as? Decimal else { return nil }                  // Decimal が渡されなかったら処理しない
        return displayFormatter.string(from: decimal as NSDecimalNumber)
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        let digitString = string.filter{CurrencyFormatter.digits.contains($0)}          // 渡された文字列から数字以外を外す
        guard let decimal = calcDecimalFromString(digitString) else { return false }
        obj?.pointee = decimal as AnyObject
        return true                                                   // 処理できたので、true を返す
    }
}

func calcDecimalFromString(_ str: String) -> Decimal? {
    // remove char except [0-9.,]
    let filterChar = "0123456789+-*/()" + NumberFormatter().currencyDecimalSeparator
    let pureNumericString = str.filter{ filterChar.contains($0)}
    //print("str: \(str) pure: \(pureNumericString)")
    guard let value = try? pureNumericString.evaluate() else { return nil }
    return Decimal(value)
}

struct SDSDecimalField_Previews: PreviewProvider {
    static var previews: some View {
        SDSDecimalField(selection: .constant(Decimal(100)))
    }
}
