import Foundation

enum VisualAcuityTestStep {
    case preTestSurvey
    case test
    case postTestSurvey
}

extension VisualAcuityTestStep {
    static let firstStep: VisualAcuityTestStep = .preTestSurvey

    var nextStep: VisualAcuityTestStep? {
        switch self {
        case .preTestSurvey:
            return .test
        case .test:
            return .postTestSurvey
        case .postTestSurvey:
            return nil
        }
    }
}
