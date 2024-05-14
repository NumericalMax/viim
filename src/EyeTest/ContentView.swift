import SwiftUI

struct ContentView: View {
    @State var onboardingResult: OnboardingResult?

    var body: some View {
        if let onboardingResult {
            VisualAcuityTestFlowView(onboardingResult: onboardingResult)
        } else {
            OnboardingView { result in
                self.onboardingResult = result
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
