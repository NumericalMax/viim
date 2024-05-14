import Foundation
import SwiftUI
import ARKit

struct DebugInfoView: View {
    @ObservedObject var viewModel: VisualAcuityTestViewModel

    var faceTracking: FaceTrackingViewModel {
        viewModel.faceTracking
    }

    var gridItemLayout = [GridItem(.flexible()),
                          GridItem(.flexible()),
                          GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: gridItemLayout, spacing: 20) {
            if let leftSquint = faceTracking.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeSquintLeft.rawValue] {
                HStack {
                    Text("Left squint:")
                    Text(String(format: "%.0f %%", leftSquint * 100))
                        .gridColumnAlignment(.trailing)
                }
            }
            if let rightSquint = faceTracking.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeSquintRight.rawValue] {
                HStack {
                    Text("Right squint:")
                    Text(String(format: "%.0f %%", rightSquint * 100))
                        .gridColumnAlignment(.trailing)
                }
            }
            if let (completed, total) = viewModel.test?.progress {
                HStack {
                    Text("Test pass:")
                    Text(String(format: "%d/%d", completed + 1, total))
                        .gridColumnAlignment(.trailing)
                }
            }
            if let state = viewModel.test?.currentTestPass?.currentState {
                HStack {
                    Text("LogMAR:")
                    Text(state.logMAR.value.formatted())
                        .gridColumnAlignment(.trailing)
                }
            }
            HStack {
                Text("Distance:")
                Text("\(viewModel.distance.formatted()) m")
                    .gridColumnAlignment(.trailing)
            }
            if let characterRow = viewModel.characters {
                HStack {
                    Text("Font height:")
                    Text(String(format: "%.2f mm", characterRow.fontHeightMetric * 1000))
                        .gridColumnAlignment(.trailing)
                }
            }
        }
    }
}
