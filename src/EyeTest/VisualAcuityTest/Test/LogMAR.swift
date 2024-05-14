import Foundation

/// Facade type for LogMAR logic
struct LogMAR {
    static let min: LogMAR = .init(value: -0.3)
    static let max: LogMAR = .init(value: 1.0)

    private(set) var value: Decimal

    var visualAngle: Float {
        5 * pow(10, Float(truncating: value as NSNumber))
    }

    init(value: Decimal) {
        self.value = value
    }

    init(angle visualAngle: Float) {
        self.init(value: Decimal(log10(Double(visualAngle)/5)))
    }

    mutating func stepIncrease() {
        guard value < Self.max.value else { return }
        value += 0.1
    }

    mutating func stepDecrease() {
        guard value > Self.min.value else { return }
        value -= 0.1
    }

    func fontHeightMetricAndSizeInPt(atDistance distance: Double) -> (Double, Double) {
        // font height [m] = tan(Visual angle  [°/60 = '] ) * Distance  [m]
        let fontHeightMetric = distance * tan((Double(visualAngle) * Double.pi) / (60 * 180))
        // font height [m] -> font size [pt]
        let meterToPtFactor = 2834.6
        let correctionFactor = 3 * 1.15
        let fontSizePt = fontHeightMetric * meterToPtFactor * correctionFactor

        return (fontHeightMetric, fontSizePt)
    }

    static func maxForDistance(_ distance: Double, availableSpaceInPt: CGSize) -> LogMAR {
        var result = LogMAR.max
        while result.fontHeightMetricAndSizeInPt(atDistance: distance).1 > (availableSpaceInPt.width / 5) + (16 * 4)
                || result.fontHeightMetricAndSizeInPt(atDistance: distance).1 > availableSpaceInPt.height {
            result.stepDecrease()
        }
        return result
    }
}

extension LogMAR {
    static func + (left: LogMAR, right: LogMAR) -> LogMAR {
        return LogMAR(value: Swift.min(LogMAR.max.value, left.value + right.value))
    }

    static func - (left: LogMAR, right: LogMAR) -> LogMAR {
        return LogMAR(value: Swift.max(LogMAR.min.value, left.value - right.value))
    }
}

extension LogMAR: Equatable {}

extension LogMAR: ExpressibleByFloatLiteral {
    init(floatLiteral value: FloatLiteralType) {
        self.value = Decimal(value)
        guard Self.max.value >= self.value && Self.min.value <= self.value else {
            assertionFailure("LogMAR value out of range")
            return
        }
    }
}

extension LogMAR: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }

    init(from decoder: Decoder) throws {
        fatalError("Not implemented!")
    }
}
