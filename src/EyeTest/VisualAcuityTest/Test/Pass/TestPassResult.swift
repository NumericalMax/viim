import Foundation

extension VisualAcuityTest {
    struct TestPassResult: Codable {
        let logMAR: LogMAR
        let characterRecognition: CharacterRecognition
        let characters: [CharacterRow]
    }
}
