import Foundation

extension VisualAcuityTest {
    struct TestPassState: Codable {
        private(set) var logMAR: LogMAR
        private(set) var returned: Bool
        private(set) var confirming: Bool

        init(distance: Double, availableSpaceInPt: CGSize) {
            logMAR = .maxForDistance(distance, availableSpaceInPt: availableSpaceInPt)
            returned = false
            confirming = false
        }

        init(logMAR: LogMAR, confirming: Bool, returned: Bool) {
            self.logMAR = logMAR
            self.confirming = confirming
            self.returned = returned
        }

        init(from previousState: TestPassState,
             logMAR: LogMAR? = nil,
             returned: Bool? = nil,
             confirming: Bool? = nil) {
            self.logMAR = logMAR ?? previousState.logMAR
            self.returned = returned ?? previousState.returned
            self.confirming = confirming ?? previousState.confirming
        }

        var charactersInCurrentPass: [CharacterRow] = []
        mutating func nextState(
            recognized characterRecognition: CharacterRecognition,
            forCharacters characterRow: CharacterRow
        ) -> TestPassResult? {
            charactersInCurrentPass.append(characterRow)
            switch characterRecognition {
            case .all:
                if returned || logMAR == .min {
                    let result = TestPassResult(
                        logMAR: logMAR,
                        characterRecognition: .all,
                        characters: charactersInCurrentPass
                    )
                    charactersInCurrentPass.removeAll()
                    return result
                } else if confirming {
                    confirming = false
                }
                logMAR.stepDecrease()
            case .some:
                if confirming || returned {
                    let result = TestPassResult(
                        logMAR: logMAR,
                        characterRecognition: .some,
                        characters: charactersInCurrentPass
                    )
                    charactersInCurrentPass.removeAll()
                    return result
                }
                confirming = true
            case .none:
                if logMAR == .max {
                    let result = TestPassResult(
                        logMAR: logMAR,
                        characterRecognition: .none,
                        characters: charactersInCurrentPass
                    )
                    charactersInCurrentPass.removeAll()
                    return result
                }
                logMAR.stepIncrease()
                confirming = false
                returned = true
            }
            return nil
        }

        enum CodingKeys: CodingKey {
            case logMAR
            case returned
            case confirming
        }
    }
}
