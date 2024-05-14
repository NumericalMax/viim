import Foundation
import SwiftUI
import FTKit

struct CalibrationView: View {
    @StateObject private var viewModel: CalibrationViewModel

    init(onboarding: OnboardingViewModel, mode: CalibrationMode) {
        self._viewModel = StateObject(
            wrappedValue: CalibrationViewModel(
                onboarding: onboarding,
                mode: mode
            )
        )
    }

    private var isTrackingFace: Bool {
        viewModel.faceTracking.isTrackingFace
    }

    var body: some View {
        tutorial
            .background(
                FaceTrackingView(viewModel: viewModel.faceTracking)
                    .opacity(viewModel.calibrationState.cameraOpacity)
            )
    }

    private var tutorial: some View {
        VStack(alignment: .center, spacing: 32) {
            Spacer()
            Text(viewModel.mode.tutorial)
                .font(.title)
            if let countdown = viewModel.countdownValue {
                Text(String(countdown))
                    .font(.system(size: 128))
                    .foregroundColor(.red)
            }
            Spacer()
            if !isTrackingFace {
                Text("No face detected")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            Button {
                viewModel.startCalibrationSequence()
            } label: {
                Text("Start (3)")
                    .frame(maxWidth: .infinity)
            }
            .disabled(!isTrackingFace)
            .opacity(viewModel.calibrationState != .calibrating ? 1 : 0)
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding()
    }
}

extension CalibrationMode {
    var tutorial: LocalizedStringKey {
        switch self {
        case let .confusion(type):
            return type.tutorial
        case let .squinting(targetIntensity):
            return targetIntensity.tutorial
        }
    }
}

extension SquintIntensity {
    var tutorial: LocalizedStringKey {
        switch self {
        case .neutral:
            return "Look into the camera with **neutral** eyes."
        case .light:
            return "Look into the camera while squinting your eyes **slightly**."
        case .strong:
            return "Look into the camera while squinting your eyes **strongly**."
        case .secondLight:
            return "Look into the camera while squinting your eyes **slightly** again."
        }
    }
}

extension ConfusionType {
    var tutorial: LocalizedStringKey {
        switch self {
        case .lookToLeft:
            return "Look to the **left**."
        case .lookToRight:
            return "Look to the **right**."
        case .smile:
            return "Try to **smile**."
        }
    }
}

extension CalibrationState {
    var cameraOpacity: Double {
        switch self {
        case .notStarted:
            return 0
        case .preparing:
            return 0.33
        case .calibrating:
            return 1
        }
    }
}
