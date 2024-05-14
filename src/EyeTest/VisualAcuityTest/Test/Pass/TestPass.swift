import Foundation
import ARKit
import os

extension VisualAcuityTest {
    class TestPass: ObservableObject {
        private static let logger = Logger(subsystem: "VisualAcuityTest", category: "TestPass")

        let options: TestPassOptions
        let startedAt: Date
        let startedAtMonotonic: ContinuousClock.Instant
        private(set) var previousStates: [TestPassState] = []
        @Published private(set) var currentState: TestPassState
        private(set) var samples: [TrackingSample] = []

        init(options: TestPassOptions, availableSpaceInPt: CGSize, distance: Double) {
            self.options = options
            startedAt = Date()
            startedAtMonotonic = ContinuousClock.now
            currentState = TestPassState(distance: distance, availableSpaceInPt: availableSpaceInPt)
        }

        func goBack() {
            guard let previousState = self.previousStates.popLast() else {
                Self.logger.warning("goBack() called but no previous state exists")
                return
            }
            currentState = previousState
        }

        func submitCharacterRecognition(
            recognizing characterRecognition: CharacterRecognition,
            forCharacters characterRow: CharacterRow
        ) -> TestPassOutput? {
            previousStates.append(currentState)
            let result = currentState.nextState(recognized: characterRecognition, forCharacters: characterRow)
            if let result {
                return TestPassOutput(
                    options: options,
                    result: result,
                    samples: samples
                )
            }
            return nil
        }

        func addSample(
            blendShapeKeys: [String],
            sample: InterpretedBlendShapes,
            faceVertices: [vector_float3],
            distanceToFace: Double
        ) {
            let milliPrecisionDecimal: (Double) -> Decimal = {
                Decimal(Int($0 * 1E3)) / 1E3
            }
            let blendShapes = blendShapeKeys
                .map { sample.blendShapes[$0].map(milliPrecisionDecimal) }
            let testPassSample = TrackingSample(
                timestamp: (ContinuousClock.now - startedAtMonotonic).inMilliseconds,
                state: currentState,
                blendShapeValues: blendShapes,
                isSquinting: sample.isSquinting,
                faceVertices: faceVertices,
                distanceToFace: distanceToFace
            )
            samples.append(testPassSample)
        }
    }
}

extension Duration {
    var inMilliseconds: Int64 {
        let (seconds, attoseconds) = components
        return seconds * 1000 + attoseconds / 1_000_000_000_000_000 // 1E15
    }
}
