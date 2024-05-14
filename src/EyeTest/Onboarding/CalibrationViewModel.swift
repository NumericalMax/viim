import Foundation
import Combine
import ARKit

@MainActor
class CalibrationViewModel: ObservableObject {
    let mode: CalibrationMode
    @Published private(set) var countdownValue: Int?
    @Published private(set) var calibrationState: CalibrationState = .notStarted
    @Published private(set) var calibratedValue: Float?

    private weak var onboarding: OnboardingViewModel?
    let faceTracking: FaceTrackingViewModel = FaceTrackingViewModel()

    private var calibrationTask: Task<(), Error>?
    private var cancellables: [AnyCancellable] = []

    init(onboarding: OnboardingViewModel, mode: CalibrationMode) {
        self.onboarding = onboarding
        self.mode = mode

        faceTracking.$isTrackingFace
            .sink { _ in self.objectWillChange.send() }
            .store(in: &cancellables)
    }

    func startCalibrationSequence() {
        if let calibrationTask {
            calibrationTask.cancel()
        }

        calibrationTask = Task { @MainActor in
            do {
                self.calibrationState = .preparing

                let ensureFaceTrackingCancellable = ensureFaceTracking()

                // Allow 3s for preparation
                try await countDown(forSeconds: 3)
                try Task.checkCancellation()

                self.calibrationState = .calibrating

                var aggregate = AverageAggregate()
                let collectionCancellable = collectSquintValues { value in
                    aggregate.addValue(value)
                }

                // Aggregate for 2s
                try await countDown(forSeconds: 2)
                try Task.checkCancellation()

                // Cancel both publishers
                ensureFaceTrackingCancellable.cancel()
                collectionCancellable.cancel()

                self.calibrationState = .notStarted

                if case let .squinting(targetIntensity) = self.mode {
                    onboarding?.setCalibratedTarget(
                        for: targetIntensity,
                        value: aggregate.average()
                    )
                }
                onboarding?.moveToNextStep()
            } catch _ as CancellationError {
                self.calibrationState = .notStarted
            }
        }
    }

    private func stopCalibrationSequence() {
        if let calibrationTask {
            calibrationTask.cancel()
            self.calibrationTask = nil
        }
    }

    private func collectSquintValues(collect: @escaping (Double) -> Void) -> AnyCancellable {
        faceTracking.$blendShapes
        .map { blendShapes in
            let leftSquint = blendShapes[ARFaceAnchor.BlendShapeLocation.eyeSquintLeft.rawValue.description] ?? 0
            let rightSquint = blendShapes[ARFaceAnchor.BlendShapeLocation.eyeSquintRight.rawValue.description] ?? 0
            return Double(max(leftSquint, rightSquint))
        }
        .sink(receiveValue: collect)
    }

    private func ensureFaceTracking() -> AnyCancellable {
        faceTracking.$isTrackingFace
            .removeDuplicates()
            .sink { isTrackingface in
                if !isTrackingface {
                    self.stopCalibrationSequence()
                }
            }
    }

    private func countDown(forSeconds seconds: Int) async throws {
        defer { self.countdownValue = nil }
        self.countdownValue = seconds

        let countdown = makeCountdownStream()
        for await _ in countdown {
            try Task.checkCancellation()
            self.countdownValue! -= 1
            if self.countdownValue == 0 {
                break
            }
        }
    }

    private func makeCountdownStream() -> AsyncStream<()> {
        AsyncStream { (continuation: AsyncStream<()>.Continuation) in
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                continuation.yield()
            }

            struct TimerWrapper: @unchecked Sendable {
                let timer: Timer
            }
            let wrapper = TimerWrapper(timer: timer)

            continuation.onTermination = { _ in
                wrapper.timer.invalidate()
            }
        }
    }
}
