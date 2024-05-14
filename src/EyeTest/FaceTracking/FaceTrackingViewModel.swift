import Foundation
import Combine
import ARKit
import SpriteKit

class FaceTrackingViewModel: ObservableObject {
    @Published var isTrackingFace: Bool = false
    @Published var blendShapes: [String: Double] = [:]
    @Published var faceVertices: [vector_float3] = []
    @Published var distanceToFace: Double = 0
}
