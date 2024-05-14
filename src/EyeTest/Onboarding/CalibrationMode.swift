import Foundation

enum CalibrationMode: Equatable, Hashable {
    case squinting(targetIntensity: SquintIntensity)
    case confusion(type: ConfusionType)
}

extension CalibrationMode {
    static let firstMode: CalibrationMode = .squinting(targetIntensity: .neutral)

    /// Calibration flow:
    /// 1. Squinting: Neutral
    /// 2. Confusion: Look to left
    /// 3. Confusion: Look to right
    /// 4. Squinting: Light
    /// 5. Confusion: Smile
    /// 6. Squinting: Strong
    /// 7. Squinting: Light (again)
    var nextMode: CalibrationMode? {
        switch self {
        case .squinting(targetIntensity: .neutral):
            return .confusion(type: .lookToLeft)
        case .confusion(type: .lookToLeft):
            return .confusion(type: .lookToRight)
        case .confusion(type: .lookToRight):
            return .squinting(targetIntensity: .light)
        case .squinting(targetIntensity: .light):
            return .confusion(type: .smile)
        case .confusion(type: .smile):
            return .squinting(targetIntensity: .strong)
        case .squinting(targetIntensity: .strong):
            return .squinting(targetIntensity: .secondLight)
        case .squinting(targetIntensity: .secondLight):
            return nil
        }
    }
}
