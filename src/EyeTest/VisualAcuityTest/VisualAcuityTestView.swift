import Foundation
import SwiftUI
import FTKit

let leonsVertexList: [Int] = {
    var vertices = [Int]()
    vertices.append(contentsOf: FTConstants.FaceGeometry.edgeFaceGeometryVertices)
    vertices.append(contentsOf: FTConstants.FaceGeometry.mouthTopLeftVertices)
    vertices.append(contentsOf: FTConstants.FaceGeometry.mouthTopCenterVertices)
    vertices.append(contentsOf: FTConstants.FaceGeometry.mouthTopRightVertices)
    vertices.append(contentsOf: FTConstants.FaceGeometry.mouthRightVertices)
    vertices.append(contentsOf: FTConstants.FaceGeometry.mouthBottomRightVertices)
    vertices.append(contentsOf: FTConstants.FaceGeometry.mouthBottomCenterVertices)
    vertices.append(contentsOf: FTConstants.FaceGeometry.mouthBottomLeftVertices)
    vertices.append(contentsOf: FTConstants.FaceGeometry.mouthLeftVertices)
    vertices.append(contentsOf: FTConstants.FaceGeometry.eyeTopLeftVertices)
    vertices.append(contentsOf: FTConstants.FaceGeometry.eyeBottomLeftVertices)
    vertices.append(contentsOf: FTConstants.FaceGeometry.eyeTopRightVertices)
    vertices.append(contentsOf: FTConstants.FaceGeometry.eyeBottomRightVertices)
    return vertices
}()

struct VisualAcuityTestView: View {
    @ObservedObject var viewModel: VisualAcuityTestViewModel
    @AppStorage("debugToggle") private var debugToggle = false

    @Environment(\.scenePhase) var scenePhase: ScenePhase
    @State private var memorizedBrightness: CGFloat?

    var screenSize: CGRect {
        UIScreen.main.bounds
    }

    private var faceTracking: FaceTrackingViewModel {
        viewModel.faceTracking
    }

    private var isExportViewPresented: Binding<Bool> {
        Binding(
            get: { viewModel.testOutput != nil },
            set: { value in if !value { viewModel.testOutput = nil } }
        )
    }

    var body: some View {
        Group {
            if viewModel.showSquintWarning {
                squintWarning
            } else {
                test
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    viewModel.availableSpaceInPt = proxy.size
                                }
                        }
                    }
            }
        }
        .trackingFace(
            showVerticiesInARView: false,
            enableLightEstimate: true,
            captureBlendShapes: true,
            captureLookAtPoint: false,
            captureDepthMap: false,
            captureDistanceToScreen: true,
            captureFaceVertices: true,
            faceGeometryVerticesIndexs: nil,
            faceGeometryVerticesEveryXIndex: 1,
            numberOfTrackedFaces: 1
        ) { ftData in
            DispatchQueue.main.async {
                faceTracking.blendShapes = ftData.blendShapes ?? [:]
                faceTracking.faceVertices = ftData.faceGeometryVertices ?? []
                faceTracking.isTrackingFace = ftData.isTrackingFace ?? false
                faceTracking.distanceToFace = ftData.distanceToScreen ?? 0
            }
        }
        .persistentSystemOverlays(.hidden)
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                forceMaxBrightness()
            case .background, .inactive:
                restoreUserBrightness()
            @unknown default:
                print("new scene phase")
            }
        }
        .onAppear {
            forceMaxBrightness()
            viewModel.startTest()
        }
        .onDisappear {
            restoreUserBrightness()
        }
    }

    private var squintWarning: some View {
        Text("STOP SQUINTING")
            .font(.system(size: 50))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(.red)
    }

    private var test: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                HStack(spacing: 16) {
                    if let characterRow = viewModel.characters {
                        ForEach(characterRow.characters, id: \.self) { item in
                            Text(item)
                                .frame(maxWidth: .infinity)
                                .font(.custom("Optician Sans", size: CGFloat(characterRow.fontSizePt)))
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .preferredColorScheme(.light)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(faceTracking.isTrackingFace ? Color(UIColor.systemBackground) : Color(UIColor.gray))

            VStack {
                HStack {
                    Spacer()
                        .frame(width: screenSize.width / 3, height: screenSize.height)
                        .contentShape(Rectangle())
                        .allowsHitTesting(faceTracking.isTrackingFace)
                        .onTapGesture {
                            viewModel.submitCharacterRecognition(recognized: .none)
                        }
                    Spacer()
                        .frame(width: screenSize.width / 3, height: screenSize.height)
                        .contentShape(Rectangle())
                        .allowsHitTesting(faceTracking.isTrackingFace)
                        .onTapGesture {
                            viewModel.submitCharacterRecognition(recognized: .some)
                        }
                    Spacer()
                        .frame(width: screenSize.width / 3, height: screenSize.height)
                        .contentShape(Rectangle())
                        .allowsHitTesting(faceTracking.isTrackingFace)
                        .onTapGesture {
                            viewModel.submitCharacterRecognition(recognized: .all)
                        }
                }
            }

            VStack(spacing: 8) {
                HStack(spacing: .none) {
                    Toggle(isOn: $debugToggle) {}
                        .padding(.top)
                        .padding(.horizontal)
                        .disabled(!faceTracking.isTrackingFace)
                }

                Spacer()

                HStack {
                    if debugToggle {
                        DebugInfoView(viewModel: viewModel)
                    }
                }

                HStack {
                    HStack {
                        Group {
                            Button {
                                if viewModel.isTestActive {
                                    viewModel.undoTestAction()
                                } else {
                                    viewModel.startTest()
                                }
                            } label: {
                                Group {
                                    if viewModel.isTestActive {
                                        Text("Undo")
                                    } else {
                                        Text("Start test")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .disabled(!faceTracking.isTrackingFace)
                            .padding(.horizontal)

                            if viewModel.isTestActive {
                                Button {
                                    viewModel.cancelTest()
                                } label: {
                                    Text("Cancel test")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .disabled(!faceTracking.isTrackingFace)
                                .padding(.horizontal)
                            }
                        }
                        .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func forceMaxBrightness() {
        memorizedBrightness = UIScreen.main.brightness
        // Set the screen brightness to 1.0
        UIScreen.main.brightness = 1.0
        // Disable the idle timer to prevent the screen from dimming
        UIApplication.shared.isIdleTimerDisabled = true
    }

    private func restoreUserBrightness() {
        if let memorizedBrightness,
           UIScreen.main.brightness == 1.0 {
            UIScreen.main.brightness = memorizedBrightness
        }
        memorizedBrightness = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
