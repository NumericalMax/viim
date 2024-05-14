import Foundation
import ARKit

struct VisualAcuityTestResult: Encodable {
    let passes: [VisualAcuityTestPass]
}

struct VisualAcuityTestPass: Encodable {
    let faceTrackingSamples: [FaceTrackingSample]
}

struct FaceTrackingSample: Encodable {
    /// Relative offset of this sample into the test
    let timestamp: Int
    let blendShapes: [ARFaceAnchor.BlendShapeLocation: Float]
    let isSquinting: Bool
}
