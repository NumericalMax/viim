import Foundation

extension VisualAcuityTest {
    struct TestPassOutput: Codable {
        let options: TestPassOptions
        let result: TestPassResult
        let samples: [TrackingSample]
    }
}
