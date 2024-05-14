import Foundation

enum SquintIntensity: Int {
    case neutral
    case light
    case strong
    case secondLight
}

extension SquintIntensity {
    var label: String {
        switch self {
        case .neutral:
            return "Not squinting"
        case .light:
            return "Lightly squinting"
        case .secondLight:
            return "Lightly squinting again"
        case .strong:
            return "Strongly squinting"
        }
    }
}
