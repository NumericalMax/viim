import Foundation

struct CharacterRow: Codable {
    let characters: [String]
    let fontHeightMetric: Double
    let fontSizePt: Double
    let startedAt: Int64
    let logMAR: Decimal
}
