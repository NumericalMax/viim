import Foundation
import SwiftUI

struct DecimalPicker: View {
    @Binding var value: Decimal

    @State private var belowZero: Bool = true
    @State private var ones: Int = 0
    @State private var tenths: Int = 0

    let signed: Bool

    var body: some View {
        HStack {
            if signed {
                Picker("Sign", selection: $belowZero) {
                    Text("+")
                        .tag(false)
                    Text("-")
                        .tag(true)
                }
            }
            Picker("Ones", selection: $ones) {
                ForEach(0...9, id: \.self) {
                    Text(String($0))
                }
            }
            Text(",")
                .foregroundColor(.secondary)
            Picker("Decimals", selection: $tenths) {
                ForEach([0, 25, 50, 75], id: \.self) {
                    Text(String($0))
                }
            }
        }
        .pickerStyle(.wheel)
        .onChange(of: ones) { newValue in
            updateValue(ones: newValue, tenths: tenths, belowZero: belowZero)
        }
        .onChange(of: tenths) { newValue in
            updateValue(ones: ones, tenths: newValue, belowZero: belowZero)
        }
        .onChange(of: belowZero) { newValue in
            updateValue(ones: ones, tenths: tenths, belowZero: newValue)
        }
        .onAppear {
            if !signed {
                belowZero = false
            }
        }
    }

    private func updateValue(ones: Int, tenths: Int, belowZero: Bool) {
        let decimalOnes = Decimal(ones)
        let decimalTenths = Decimal(tenths)
        let signMultiplier: Decimal = belowZero ? -1 : 1
        value = (decimalOnes + (decimalTenths / 100.0)) * signMultiplier
    }
}
