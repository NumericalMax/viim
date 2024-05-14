import Foundation
import SwiftUI

struct SurveyBinaryInput: View {
    let submit: (Bool) -> Void

    var body: some View {
        VStack {
            Button {
                submit(true)
            } label: {
                Text("Yes")
                    .frame(maxWidth: .infinity)
            }
            Button {
                submit(false)
            } label: {
                Text("No")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.bordered)
    }
}
