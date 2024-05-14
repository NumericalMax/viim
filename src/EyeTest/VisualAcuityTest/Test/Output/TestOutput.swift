import Foundation
import ARKit

extension VisualAcuityTest {
    struct TestOutput: Codable {
        let startedAt: Date
        let distance: Decimal
        let blendShapes: [String]
        let passes: [TestPassOutput]
    }
}

extension ARFaceAnchor.BlendShapeLocation: Codable {}
