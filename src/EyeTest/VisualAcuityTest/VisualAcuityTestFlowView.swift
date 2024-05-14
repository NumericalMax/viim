import Foundation
import SwiftUI

struct VisualAcuityTestFlowView: View {
    @StateObject var viewModel: VisualAcuityTestFlowViewModel

    init(onboardingResult: OnboardingResult) {
        _viewModel = StateObject(
            wrappedValue: VisualAcuityTestFlowViewModel(onboardingResult: onboardingResult)
        )
    }

    private var isExportViewPresented: Binding<Bool> {
        Binding(
            get: { viewModel.output != nil },
            set: { value in if !value { viewModel.output = nil } }
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.step {
                case .preTestSurvey:
                    SurveyView(questions: VisualAcuityTestFlowViewModel.preTestQuestions) { answers in
                        viewModel.submitAnswers(answers: answers)
                    }
                case .test:
                    VisualAcuityTestView(viewModel: viewModel.testViewModel)
                case .postTestSurvey:
                    SurveyView(questions: VisualAcuityTestFlowViewModel.postTestQuestions) { answers in
                        viewModel.submitAnswers(answers: answers)
                    }
                }
            }
            .persistentSystemOverlays(.hidden)
            .navigationDestination(isPresented: isExportViewPresented) {
                ExportView(viewModel: viewModel)
                    .persistentSystemOverlays(.visible)
            }
        }
    }
}
