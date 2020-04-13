import Foundation

public struct Percent: ExpressibleByFloatLiteral, Comparable, Equatable {
    public typealias FloatLiteralType = Float

    public static func <(lhs: Percent, rhs: Percent) -> Bool {
        return lhs.value < rhs.value
    }

    public static var oneQuarter: Percent {
        return 0.25
    }

    public static var half: Percent {
        return 0.5
    }

    public static var threeQuarters: Percent {
        return 0.75
    }


    private var value: Float

    public init(_ value: Float) {
        self.value = max(0, min(value, 1))
    }

    public init(_ value: Double) {
        self.init(Float(value))
    }

    public init(floatLiteral value: Float) {
        self.init(value)
    }

}

public extension Percent {

    static var nearlyExpired: Percent {
        return 0.05
    }

}
