import Foundation
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published private(set) var currentStep: OnboardingStep = .firstStep
    @Published private(set) var squintTargets: SquintTargets?
    @Published var distance: Decimal = 3
    @Published private(set) var result: OnboardingResult?

    private var calibratedTargets: [SquintIntensity: Float] = [:]

    init() {
        Publishers.CombineLatest($squintTargets, $distance)
            .map { (squintTargets, distance) in
                guard let squintTargets else {
                    return nil
                }
                return OnboardingResult(squintTargets: squintTargets, distance: distance)
            }
            .assign(to: &$result)
    }

    func setCalibratedTarget(for mode: SquintIntensity, value: Float) {
        self.calibratedTargets[mode] = value
    }

    private func submitCalibratedTargets() {
        guard let neutral = calibratedTargets[.neutral],
              let light = calibratedTargets[.light],
              let strong = calibratedTargets[.strong],
              let secondLight = calibratedTargets[.secondLight] else {
            assertionFailure("Call to submitCalibratedTargets() but some are missing")
            return
        }
        self.squintTargets = SquintTargets(
            neutral: neutral,
            light: (light + secondLight) / 2,
            strong: strong
        )
    }

    func submitDefaultTargets() {
        self.squintTargets = SquintTargets()
    }

    func moveToNextStep() {
        let nextStep = currentStep.nextStep
        let currentStep = currentStep
        if let nextStep {
            self.currentStep = nextStep
            if nextStep == .calibrationWrapUp && currentStep != .testExplainer {
                submitCalibratedTargets()
            }
        }
    }

    func moveToTestExplainerStep() {
        self.currentStep = .testExplainer
        submitDefaultTargets()
    }

    func restartOnboarding() {
        self.squintTargets = nil
        self.currentStep = .calibrationExplainer
    }
}
