import Foundation

infix operator <| : BackwardPipePrecedence

precedencegroup BackwardPipePrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
}

func <|<T1, T2>(_ lhs: (T1) -> T2, _ rhs: T1) -> T2 {
    return lhs(rhs)
}

/// Completion of the test is sufficient for success.
func always<T>() -> (T) -> Bool {
    return { _ in true }
}
