import Foundation
import Combine

class SurveyViewModel: ObservableObject {
    let submission = PassthroughSubject<Void, Never>()
    @Published var currentQuestion: VisualAcuityTest.QuestionWithAnswerType

    private var remainingQuestions: [VisualAcuityTest.QuestionWithAnswerType]
    private(set) var answers: [VisualAcuityTest.Question: String] = [:]

    init(questions: [VisualAcuityTest.QuestionWithAnswerType]) {
        remainingQuestions = questions
        currentQuestion = remainingQuestions.removeFirst()
    }

    func binaryAnswer(answer: Bool) {
        answers[currentQuestion.question] = String(answer)
        nextQuestion()
    }

    func decimalAnswer(answer: Decimal) {
        answers[currentQuestion.question] = answer.formatted()
        nextQuestion()
    }

    func nextQuestion() {
        guard !remainingQuestions.isEmpty else {
            submission.send()
            return
        }
        currentQuestion = remainingQuestions.removeFirst()
    }
}
