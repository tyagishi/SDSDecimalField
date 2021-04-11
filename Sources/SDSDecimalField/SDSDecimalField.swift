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
    let formatter: NumberFormatter
    @State private var editingText: String = ""
    @State private var underEditing = false
    @State private var error = false
    @State private var check:String = "a"
    
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
        HStack {
            if underEditing {
                Button(action: { self.editingText = "" },
                       label: { Image(systemName: "xmark.circle").foregroundColor(.secondary)})
            }
            TextField("input here...", text: $editingText, onEditingChanged:{ bEditing in
                underEditing = bEditing
            }, onCommit: {
                if let valueCheck = calcDecimalFromString(editingText) {
                    editingText = formattedString(valueCheck) ?? "0"
                    value = valueCheck
                    underEditing = false
                } else {
                    editingText = formattedString(value) ?? "0"
                }
            })
            .multilineTextAlignment(.trailing)
            .overlay(
                Text(formattedString(value) ?? "0")
                .frame(maxWidth:.infinity, alignment: .leading)
                .foregroundColor(.secondary)
                .font(.footnote)
                .padding(.leading, 5)
                .opacity(underEditing ? 1.0 : 0.0)
            )
        }
        .onAppear {
            editingText = formattedString(value) ?? ""
        }
    }
    
    func formattedString(_ value: Decimal) -> String?{
        self.formatter.string(from: value as NSDecimalNumber) ?? "0"
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
