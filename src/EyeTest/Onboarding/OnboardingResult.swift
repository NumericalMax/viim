import Foundation

struct OnboardingResult {
    let squintTargets: SquintTargets
    let distance: Decimal
}

extension OnboardingResult {
    init() {
        squintTargets = .init()
        distance = 5
    }
}
