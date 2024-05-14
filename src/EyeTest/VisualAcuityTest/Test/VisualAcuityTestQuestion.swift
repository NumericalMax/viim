import Foundation
import SwiftUI

extension VisualAcuityTest {
    enum Question: String, RawRepresentable, Codable {
        case hasVisualAid
        case usesVisualAid
        case visualAidDiopters
        case canReadSmartphoneScreen
        case canReadCinemaSubtitles
        case canReadRoadSigns
        case wasEasy
        case needsNewVisualAid
    }

    enum AnswerType: Codable {
        case binary
        case decimal
    }

    struct QuestionWithAnswerType {
        let question: Question
        let answerMode: AnswerType

        init(_ question: Question, answerMode: AnswerType) {
            self.question = question
            self.answerMode = answerMode
        }

        static let hasVisualAid = QuestionWithAnswerType(.hasVisualAid, answerMode: .binary)
        static let usesVisualAid = QuestionWithAnswerType(.usesVisualAid, answerMode: .binary)
        static let visualAidDiopters = QuestionWithAnswerType(.visualAidDiopters, answerMode: .decimal)
        static let canReadSmartphoneScreen = QuestionWithAnswerType(.canReadSmartphoneScreen, answerMode: .binary)
        static let canReadCinemaSubtitles = QuestionWithAnswerType(.canReadCinemaSubtitles, answerMode: .binary)
        static let canReadRoadSigns = QuestionWithAnswerType(.canReadRoadSigns, answerMode: .binary)

        static let wasEasy = QuestionWithAnswerType(.wasEasy, answerMode: .binary)
        static let needsNewVisualAid = QuestionWithAnswerType(.needsNewVisualAid, answerMode: .binary)
    }
}

extension VisualAcuityTest.Question {
    var description: LocalizedStringKey {
        switch self {
        case .hasVisualAid:
            return "Do you have a visual aid? (glasses/contact lenses)"
        case .usesVisualAid:
            return "Is this test being conducted with a visual aid?"
        case .visualAidDiopters:
            return "How many diopters (dpt) does your visual aid have?"
        case .canReadSmartphoneScreen:
            return "Do you have issues reading on smartphone screens?"
        case .canReadCinemaSubtitles:
            return "Do you have issues reading cinema subtitles or signs on the subway?"
        case .canReadRoadSigns:
            return "Do you have issues reading road signs?"
        case .wasEasy:
            return "Was reading the letters hard for you overall?"
        case .needsNewVisualAid:
            return "Do you think you need a (new) visual aid?"
        }
    }
}
