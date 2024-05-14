import Foundation
import Combine

class VisualAcuityTestFlowViewModel: ObservableObject {
    static let preTestQuestions: [VisualAcuityTest.QuestionWithAnswerType] = [
        .hasVisualAid,
        .usesVisualAid,
        .visualAidDiopters,
        .canReadSmartphoneScreen,
        .canReadCinemaSubtitles,
        .canReadRoadSigns
    ]
    static let postTestQuestions: [VisualAcuityTest.QuestionWithAnswerType] = [
        .wasEasy,
        .needsNewVisualAid
    ]

    let testViewModel: VisualAcuityTestViewModel

    @Published private var testOutput: VisualAcuityTest.TestOutput?
    @Published private var surveyAnswers: [VisualAcuityTest.Question: String] = [:]

    @Published var step: VisualAcuityTestStep = .preTestSurvey
    @Published var output: VisualAcuityTest.TestOutputWithSurvey?

    private var cancellables: [AnyCancellable] = []

    init(onboardingResult: OnboardingResult) {
        testViewModel = VisualAcuityTestViewModel(onboardingResult: onboardingResult)

        testViewModel.$testOutput
            .filter { $0 != nil }
            .sink {
                self.testOutput = $0
                self.step = .postTestSurvey
            }
            .store(in: &cancellables)
    }

    func submitAnswers(answers: [VisualAcuityTest.Question: String]) {
        guard step != .test else {
            assertionFailure("Cannot submit answers during test step")
            return
        }
        surveyAnswers = surveyAnswers.merging(answers) { first, _ in first }
        if let nextStep = step.nextStep {
            step = nextStep
        } else if step == .postTestSurvey {
            guard let testOutput = testOutput else {
                assertionFailure("Should have test output in postTestSurvey step!")
                return
            }
            output = VisualAcuityTest.TestOutputWithSurvey(
                test: testOutput,
                survey: Dictionary(
                    surveyAnswers.map { ($0.key.rawValue, $0.value) },
                    uniquingKeysWith: { first, _ in first }
                )
            )
        }
    }

    func restartTestFlow() {
        output = nil
        step = .preTestSurvey
        testViewModel.cancelTest()
    }
}
