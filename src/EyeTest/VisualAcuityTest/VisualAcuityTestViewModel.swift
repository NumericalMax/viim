import Foundation
import ARKit
import Combine
import SpriteKit

class VisualAcuityTestViewModel: ObservableObject {
    @Published private(set) var isSquinting: Bool = false
    @Published private(set) var showSquintWarning: Bool = false

    @Published private(set) var test: VisualAcuityTest?
    @Published var testOutput: VisualAcuityTest.TestOutput?

    var isTestActive: Bool {
        !(test?.isCompleted ?? true)
    }

    private let characterPool = Array(["A", "C", "D", "E", "F", "H", "L", "N", "O", "P", "R", "T", "V", "Y", "Z"])
    @Published private(set) var characters: CharacterRow?

    let faceTracking: FaceTrackingViewModel = FaceTrackingViewModel()
    private let squintTargets: SquintTargets
    let distance: Decimal

    private let interpretedBlendShapes = PassthroughSubject<InterpretedBlendShapes, Never>()
    private let faceVertices = PassthroughSubject<[vector_float3], Never>()
    private let distanceToFace = PassthroughSubject<Double, Never>()

    private var cancellables: [AnyCancellable] = []

    init(onboardingResult: OnboardingResult) {
        self.squintTargets = onboardingResult.squintTargets
        self.distance = onboardingResult.distance
        setupTrackingPublishers()
        setupTestPublishers()
    }

    private func setupTrackingPublishers() {
        faceTracking.$faceVertices
            .subscribe(self.faceVertices)
            .store(in: &cancellables)

        faceTracking.$distanceToFace
            .subscribe(self.distanceToFace)
            .store(in: &cancellables)

        let interpretedBlendShapes = faceTracking.$blendShapes
            .map { blendShapes in
                let (leftSquint, rightSquint) = (
                    blendShapes[ARFaceAnchor.BlendShapeLocation.eyeSquintLeft.rawValue] ?? 0,
                    blendShapes[ARFaceAnchor.BlendShapeLocation.eyeSquintRight.rawValue] ?? 0
                )
                let max = max(leftSquint, rightSquint)
                let isSquinting = self.squintTargets.isSquint(intensity: max)
                return InterpretedBlendShapes(
                    blendShapes: self.faceTracking.blendShapes,
                    isSquinting: isSquinting
                )
            }
            .share()

        interpretedBlendShapes
            .map { interpreted in interpreted.isSquinting }
            .assign(to: &$isSquinting)

        interpretedBlendShapes
            .subscribe(self.interpretedBlendShapes)
            .store(in: &cancellables)

    }

    private func setupTestPublishers() {
        let testChange = $test
            .compactMap { $0 }
            .flatMap { $0.objectWillChange }

        // Cancel test when completed
        testChange
            .sink {
                self.objectWillChange.send()

                // Called with willSet
                // isCompleted will only be true after didSet
                DispatchQueue.main.async {
                    if let test = self.test, test.isCompleted {
                        self.cancelTest()
                    }
                }
            }
            .store(in: &cancellables)

        let testPassChange = $test
            .compactMap { $0?.$currentTestPass }
            .flatMap { $0 }
            .eraseToAnyPublisher()
            .share()

        Publishers.CombineLatest(testPassChange, $isSquinting)
            .map { pass, isSquinting in
                (pass?.options.contains(.suppressSquinting) ?? false) && isSquinting
            }
            .assign(to: &$showSquintWarning)

        // For every change of state in the active test pass, update the character row
        testPassChange
            .compactMap { $0?.$currentState }
            .flatMap { $0 }
            .map { (state: VisualAcuityTest.TestPassState) in
                self.calculateCharacterRow(state: state)
            }
            .assign(to: &$characters)
    }

    private func calculateCharacterRow(state: VisualAcuityTest.TestPassState) -> CharacterRow {
        let baseTime = (test?.currentTestPass?.startedAtMonotonic) ?? .now
        if baseTime == .now {
            print("💥 Couldn't read the monotic start time from the current test pass.")
        }
        let (fontHeightMetric, fontSizeInPt) = state.logMAR.fontHeightMetricAndSizeInPt(
            atDistance: Double(truncating: distance as NSNumber)
        )

        let characterRow = CharacterRow(
            characters: characterPool[randomPick: 5],
            fontHeightMetric: fontHeightMetric,
            fontSizePt: fontSizeInPt,
            startedAt: (ContinuousClock.now - baseTime).inMilliseconds,
            logMAR: state.logMAR.value
        )
        return characterRow
    }

    func submitCharacterRecognition(recognized characterRecognition: VisualAcuityTest.CharacterRecognition) {
        if let characters {
            let output = test?.submitCharacterRecognition(
                recognized: characterRecognition,
                forCharacters: characters,
                availableSpaceInPt: availableSpaceInPt
            )
            if let output {
                testOutput = output
            }
        }
    }

    func undoTestAction() {
        test?.undoTestPassAction()
    }

    var availableSpaceInPt: CGSize = .zero
    func startTest() {
        testOutput = nil
        test = VisualAcuityTest(
            at: distance,
            with: interpretedBlendShapes.eraseToAnyPublisher(),
            andVertices: faceVertices.eraseToAnyPublisher(),
            andDistance: distanceToFace.eraseToAnyPublisher(),
            availableSpaceInPt: availableSpaceInPt
        )
    }

    func cancelTest() {
        test = nil
    }
}
