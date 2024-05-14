import Foundation

struct AverageAggregate {
    private var sum: Double = 0.0
    private var count: Int = 0

    mutating func addValue(_ value: Double) {
        sum += value
        count += 1
    }

    func average() -> Float {
        return Float(sum / Double(count))
    }
}
