import Foundation
import ARKit

extension VisualAcuityTest {
    struct TrackingSample: Codable {
        /// Monotonic offset of this sample into the test
        let timestamp: Int64
        let state: TestPassState
        /// At index i, contains the value for blend shape at index i
        /// in ``VisualAcuityTest.TestOutput/blendShapes`` or `nil`.
        /// Not guaranteed to be the same length as ``VisualAcuityTest.TestOutput/blendShapes``.
        /// Any trailing indices in ``VisualAcuityTest.TestOutput/blendShapes`` do not have an
        /// associated value (i.e. implicitly `nil`).
        let blendShapeValues: [Decimal?]
        let isSquinting: Bool
        let faceVertices: [vector_float3]
        let distanceToFace: Double
    }
}
