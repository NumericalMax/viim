import SwiftUI

struct ExportView: View {
    @ObservedObject var viewModel: VisualAcuityTestFlowViewModel

    var squintingResult: VisualAcuityTest.TestPassResult? {
        viewModel.output?.test.passes
            .first(where: { !$0.options.contains(.suppressSquinting) })?
            .result
    }

    var noSquintingResult: VisualAcuityTest.TestPassResult? {
        viewModel.output?.test.passes
            .first(where: { $0.options.contains(.suppressSquinting) })?
            .result
    }

    @State private var completedExport: Bool = false
    @State private var showExportIDAlert: Bool = false
    @State private var exportID: String = ""
    @State private var showNoIDAlert: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            Text("Test Results")
                .font(.title)
            Grid(alignment: .leading, horizontalSpacing: 16) {
                if let squintingResult {
                    GridRow {
                        Text("With Squinting")
                            .font(.headline)
                    }
                    resultRows(result: squintingResult)
                }
                Spacer()
                    .frame(width: 0, height: 16)
                if let noSquintingResult {
                    GridRow {
                        Text("Without Squinting")
                            .font(.headline)
                    }
                    resultRows(result: noSquintingResult)
                }
            }

            Spacer()

            Group {
                HStack {
                    Button {
                        viewModel.restartTestFlow()
                    } label: {
                        Label("Restart Test", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    if let output = viewModel.output {
                        Button {
                            showExportIDAlert = true
                        } label: {
                            Label("Save Data", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .controlSize(.large)
        }
        .padding()
        .onDisappear { viewModel.output = nil }
        .alert("Completed Export", isPresented: $completedExport) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text("The results were exported successfully.")
        }
        .alert("Enter ID", isPresented: $showExportIDAlert) {
            TextField("Identifier", text: $exportID)
                .keyboardType(.numberPad)

            Button("Export") {
                guard exportID.isEmpty == false, let output = viewModel.output else {
                    showExportIDAlert = false
                    showNoIDAlert = true
                    return
                }
                do {
                    try output.export(withIdentifier: exportID)
                    completedExport = true
                } catch {
                    print(error)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enter the participant ID.")
        }
        .alert("Error", isPresented: $showNoIDAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text("You didn't enter an ID. Please try again.")
        }
    }

    @ViewBuilder
    private func resultRows(result: VisualAcuityTest.TestPassResult) -> some View {
        Group {
            GridRow {
                Text("At LogMAR")
                Text(result.logMAR.value.formatted())
            }
            GridRow {
                Text("Recognized letters")
                Text(result.characterRecognition.rawValue)
            }
        }
    }
}

struct ExportView_Previews: PreviewProvider {
    @StateObject private static var viewModel = VisualAcuityTestFlowViewModel(onboardingResult: .init())

    static var previews: some View {
        ExportView(viewModel: viewModel)
    }
}
