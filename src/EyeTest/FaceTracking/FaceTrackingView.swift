import ARKit
import SceneKit
import SwiftUI
import Combine

struct FaceTrackingView: UIViewRepresentable {
    @ObservedObject var viewModel: FaceTrackingViewModel

    func makeUIView(context: Context) -> some UIView {
        let faceTrackingARView = FaceTrackingARView(frame: .zero)
        faceTrackingARView.viewModel = viewModel
        faceTrackingARView.resetTracking()
        return faceTrackingARView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

class FaceTrackingARView: ARSCNView, ARSessionDelegate {
    var viewModel: FaceTrackingViewModel?

    override init(frame: CGRect, options: [String: Any]? = nil) {
        super.init(frame: frame, options: options)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didFailWithError error: Error) {
        print(error)
    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if let faceAnchor = anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor,
           let viewModel {
            DispatchQueue.main.async {
                viewModel.faceVertices = faceAnchor.geometry.vertices
                viewModel.isTrackingFace = faceAnchor.isTracked
                viewModel.blendShapes = faceAnchor.blendShapes.converted
            }
        }
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        if let faceAnchor = anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor,
           let viewModel {
            DispatchQueue.main.async {
                viewModel.faceVertices = faceAnchor.geometry.vertices
                viewModel.isTrackingFace = faceAnchor.isTracked
                viewModel.blendShapes = faceAnchor.blendShapes.converted
            }
        }
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        if anchors.first(where: { $0 is ARFaceAnchor }) != nil {
            DispatchQueue.main.async {
                self.viewModel?.faceVertices = []
                self.viewModel?.blendShapes = [:]
                self.viewModel?.isTrackingFace = false
            }
        }
    }

    /// - Tag: ARFaceTrackingSetup
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        if #available(iOS 13.0, *) {
            configuration.maximumNumberOfTrackedFaces = 1
        }
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension [ARFaceAnchor.BlendShapeLocation: NSNumber] {
    var converted: [String: Double] {
        var result = [String: Double]()
        for (key, value) in self {
            result[key.rawValue] = Double(value)
        }
        return result
    }
}
