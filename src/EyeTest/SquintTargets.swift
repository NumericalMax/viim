import Foundation

struct SquintTargets: Equatable {
    let neutral: Float
    let light: Float
    let strong: Float

    func classify(intensity: Float) -> SquintIntensity {
        switch intensity {
        case ..<(neutral * 0.2 + light * 0.8):
            return .neutral
        case ..<((light + strong) / 2.0):
            return .light
        default:
            return .strong
        }
    }

    func isSquint(intensity: Double) -> Bool {
        Float(intensity) >= neutral * 0.2 + light * 0.8
    }
}

extension SquintTargets {
    init() {
        neutral = 0.0
        light = 0.5
        strong = 1.0
    }
}
