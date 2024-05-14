import Foundation
import SwiftUI

struct SurveyView: View {
    let submit: (_ answers: [VisualAcuityTest.Question: String]) -> Void
    @StateObject private var viewModel: SurveyViewModel

    init(
        questions: [VisualAcuityTest.QuestionWithAnswerType],
        submit: @escaping (_ answers: [VisualAcuityTest.Question: String]) -> Void
    ) {
        self.submit = submit
        _viewModel = StateObject(wrappedValue: SurveyViewModel(questions: questions))
    }

    var body: some View {
        VStack {
            Text(viewModel.currentQuestion.question.description)
                .font(.title)
            Spacer()
            switch viewModel.currentQuestion.answerMode {
            case .binary:
                SurveyBinaryInput { answer in
                    viewModel.binaryAnswer(answer: answer)
                }
            case .decimal:
                SurveyDecimalInput { answer in
                    viewModel.decimalAnswer(answer: answer)
                }
            }
            Button {
                viewModel.nextQuestion()
            } label: {
                Text("Skip")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .controlSize(.large)
        .padding()
        .onReceive(viewModel.submission) {
            submit(viewModel.answers)
        }
    }
}
