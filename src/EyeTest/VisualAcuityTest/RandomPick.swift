import Foundation

extension Array {
    /// Picks `n` random elements (partial Fisher-Yates shuffle approach)
    subscript (randomPick num: Int) -> [Element] {
        var copy = self
        for integ in stride(from: count - 1, to: count - num - 1, by: -1) {
            copy.swapAt(integ, Int.random(in: 0...integ))
        }
        return Array(copy.suffix(num))
    }
}
