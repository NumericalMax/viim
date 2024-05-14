import Foundation
import SwiftUI

struct SurveyDecimalInput: View {
    let submit: (Decimal) -> Void
    @State private var answer: Decimal = 0.0

    var body: some View {
        VStack {
            DecimalPicker(value: $answer, signed: true)
            Button {
                submit(answer)
            } label: {
                Text("Submit")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
