import Foundation

/// A percent value type.
public struct Percent: ExpressibleByFloatLiteral, Comparable, Equatable {

    public typealias FloatLiteralType = Float

    public static func <(lhs: Percent, rhs: Percent) -> Bool {
        return lhs.value < rhs.value
    }

    /// A value representing a quarter (25%).
    public static var oneQuarter: Percent {
        return 0.25
    }

    /// A value representing a half (50%).
    public static var half: Percent {
        return 0.5
    }

    /// A value representing three quarters (75%).
    public static var threeQuarters: Percent {
        return 0.75
    }

    private var value: Float

    /// Creates a percent from the given floating-point value, clamping from
    /// 0 to 1 (inclusive).
    public init(_ value: Float) {
        self.value = max(0, min(value, 1))
    }

    /// Creates a percent from the given double precision, floating-point value,
    /// clamping from 0 to 1 (inclusive).
    public init(_ value: Double) {
        self.init(Float(value))
    }

    public init(floatLiteral value: Float) {
        self.init(value)
    }

}

public extension Percent {

    /// A percent representing a resource with a nearly expired lifetime.
    static var nearlyExpired: Percent {
        return 0.05
    }

}
