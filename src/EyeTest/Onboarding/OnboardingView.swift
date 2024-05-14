import Foundation
import SwiftUI

struct OnboardingView: View {
    let completion: (OnboardingResult) -> Void
    @StateObject var viewModel: OnboardingViewModel = OnboardingViewModel()

    private static let distanceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    var body: some View {
        Group {
            switch viewModel.currentStep {
            case .calibrationExplainer:
                calibrationExplainer
            case .testExplainer:
                testExplainer
            case let .calibration(mode):
                CalibrationView(onboarding: viewModel, mode: mode)
                    .id(mode)
            case .calibrationWrapUp:
                calibrationWrapUp
            }
        }
    }

    private var calibrationExplainer: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("Facial Calibration")
                .font(.title)
            Image(systemName: "person.and.background.dotted")
                .font(.system(size: 96))
            Spacer()
            VStack {
                Group {
                    Button {
                        viewModel.moveToNextStep()
                    } label: {
                        Text("Get Started")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    Button {
                        viewModel.moveToTestExplainerStep()
                    } label: {
                        Text("Use Defaults")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .controlSize(.large)
            }
        }
        .padding()
    }

    private var calibrationWrapUp: some View {
        VStack(alignment: .center, spacing: 8) {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                Text("Facial calibration completed")
                    .font(.title)
            }
            if let targets = viewModel.squintTargets {
                Grid(alignment: Alignment.leading, horizontalSpacing: 0) {
                    GridRow {
                        Text("\(SquintIntensity.neutral.label): ")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(String(format: "%.2f", targets.neutral))
                            .gridColumnAlignment(.trailing)
                    }
                    GridRow {
                        Text("\(SquintIntensity.light.label): ")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(String(format: "%.2f", targets.light))
                    }
                    GridRow {
                        Text("\(SquintIntensity.strong.label): ")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(String(format: "%.2f", targets.strong))
                    }
                }
            }
            Spacer()
            VStack {
                Group {
                    Button {
                        viewModel.moveToNextStep()
                    } label: {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.squintTargets == nil)
                    Button {
                        viewModel.restartOnboarding()
                    } label: {
                        Text("Restart")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .controlSize(.large)
            }
        }
        .padding()
    }

    private var testExplainer: some View {
        VStack(alignment: .center, spacing: 8) {
            Spacer()
            Text("Visual Acuity Test")
                .font(.title)
            Text("Enter your distance from the device")
            HStack {
                DecimalPicker(value: $viewModel.distance, signed: false)
                Text("m")
                    .foregroundColor(.secondary)
            }
            Spacer()
                .frame(height: 16)
            Text("""
                Position yourself \(viewModel.distance.formatted()) meters from your phone.
                Read the letters aloud from left to right.
                """)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            Spacer()
            Button {
                if let result = viewModel.result {
                    completion(result)
                }
            } label: {
                Text("Start the Test")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.result == nil)
        }
        .padding()
    }
}
