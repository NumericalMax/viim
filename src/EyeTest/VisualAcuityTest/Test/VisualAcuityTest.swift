import Foundation
import Combine
import ARKit
import os

class VisualAcuityTest: ObservableObject {
    private static let defaultTestOptions: [TestPassOptions] = [
        .permissiveTestPass,
        .restrictiveTestPass
    ]
    private static let logger = Logger(subsystem: "VisualAcuityTest", category: "Test")

    let startedAt: Date = Date()
    let distance: Decimal
    private let passOptions: [TestPassOptions]

    private(set) var completedTestPasses: [TestPassOutput] = []
    @Published private(set) var currentTestPass: TestPass?

    private var blendShapeKeys: [String] = []
    private var cancellables: [AnyCancellable] = []

    var progress: (Int, Int) {
        (completedTestPasses.count, passOptions.count)
    }

    var isCompleted: Bool {
        completedTestPasses.count == passOptions.count
    }

    init(
        at distance: Decimal,
        passOptions: [TestPassOptions] = defaultTestOptions,
        with blendShapes: AnyPublisher<InterpretedBlendShapes, Never>,
        andVertices faceVertices: AnyPublisher<[vector_float3], Never>,
        andDistance distanceToFace: AnyPublisher<Double, Never>,
        availableSpaceInPt: CGSize
    ) {
        self.distance = distance
        self.passOptions = passOptions

        blendShapes
            .combineLatest(faceVertices, distanceToFace)
            .sink { (sample, vertices, distance) in
                // Compare count first as performance optimization
                if self.blendShapeKeys.count < sample.blendShapes.count {
                    let newKeys = sample.blendShapes.keys.filter { !self.blendShapeKeys.contains($0) }
                    self.blendShapeKeys.append(contentsOf: newKeys)
                }
                if let currentTestPass = self.currentTestPass {
                    currentTestPass.addSample(
                        blendShapeKeys: self.blendShapeKeys,
                        sample: sample,
                        faceVertices: vertices,
                        distanceToFace: distance
                    )
                }
            }
            .store(in: &cancellables)

        // Trigger change of test when test pass internals change
        $currentTestPass
            .compactMap { $0 }
            .flatMap { $0.objectWillChange }
            .sink { self.objectWillChange.send() }
            .store(in: &cancellables)

        startTestPass(
            availableSpaceInPt: availableSpaceInPt,
            distance: Double(truncating: distance as NSNumber)
        )
    }

    private func startTestPass(availableSpaceInPt: CGSize, distance: Double) {
        guard completedTestPasses.count < passOptions.count else {
            Self.logger.error("startTestPass() but no outstanding test pass")
            return
        }
        let testPassOptions = passOptions[completedTestPasses.count]
        currentTestPass = TestPass(
            options: testPassOptions,
            availableSpaceInPt: availableSpaceInPt,
            distance: distance
        )
    }

    private func stopTestPass() {
        currentTestPass = nil
    }

    func submitCharacterRecognition(
        recognized characterRecognition: CharacterRecognition,
        forCharacters characterRow: CharacterRow,
        availableSpaceInPt: CGSize
    ) -> TestOutput? {
        guard let currentTestPass = self.currentTestPass else {
            Self.logger.warning("submitCharacterRecognition() but test already completed")
            return nil
        }

        let result = currentTestPass.submitCharacterRecognition(
            recognizing: characterRecognition,
            forCharacters: characterRow
        )
        Self.logger.debug("""
                            Test pass \(self.completedTestPasses.count)/\(self.passOptions.count): \
                            logMAR: \(currentTestPass.currentState.logMAR.value), \
                            returned: \(currentTestPass.currentState.returned), \
                            confirming: \(currentTestPass.currentState.confirming)
                            """)

        if let result {
            stopTestPass()
            completedTestPasses.append(result)

            if !isCompleted {
                startTestPass(
                    availableSpaceInPt: availableSpaceInPt,
                    distance: Double(truncating: distance as NSNumber)
                )
            } else {
                return stop()
            }
        }
        return nil
    }

    func undoTestPassAction() {
        currentTestPass?.goBack()
    }

    private func stop() -> TestOutput {
        cancellables.removeAll()
        if completedTestPasses.isEmpty {
            assertionFailure("stop() with no test pass outputs")
        }
        return TestOutput(
            startedAt: startedAt,
            distance: distance,
            blendShapes: blendShapeKeys,
            passes: completedTestPasses
        )
    }
}
