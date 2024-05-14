import Foundation

enum OnboardingStep: Equatable {
    case calibrationExplainer
    case calibration(mode: CalibrationMode)
    case calibrationWrapUp
    case testExplainer
}

// calibrationExplainer -> calibration(mode: CalibrationMode) -> calibrationWrapUp -> testExplainer
extension OnboardingStep {
    static let firstStep: OnboardingStep = .calibrationExplainer

    var nextStep: OnboardingStep? {
        switch self {
        case .calibrationExplainer:
            return .calibration(mode: .firstMode)
        case .calibration(mode: let mode) where mode.nextMode != nil:
            guard let nextMode = mode.nextMode else {
                fatalError("Illegal state!")
            }
            return .calibration(mode: nextMode)
        case .calibration:
            return .calibrationWrapUp
        case .calibrationWrapUp:
            return .testExplainer
        case .testExplainer:
            return nil
        }
    }
}
