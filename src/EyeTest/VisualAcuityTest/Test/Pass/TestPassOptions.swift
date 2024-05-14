import Foundation

extension VisualAcuityTest {
    struct TestPassOptions: OptionSet {
        let rawValue: Int

        static let suppressSquinting = TestPassOptions(rawValue: 1 << 0)

        static let permissiveTestPass: TestPassOptions = []
        static let restrictiveTestPass: TestPassOptions = [.suppressSquinting]
    }
}

extension VisualAcuityTest.TestPassOptions: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        let optionsRaw: [String] = Self.mapping
            .compactMap { self.contains($0.value) ? $0.key : nil }
        try container.encode(contentsOf: optionsRaw)
    }

    init(from decoder: Decoder) throws {
        fatalError("Not implemented!")
    }

    private static let mapping: [String: VisualAcuityTest.TestPassOptions] = [
        "suppressSquinting": .suppressSquinting
    ]
}
