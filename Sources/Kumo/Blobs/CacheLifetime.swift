import Foundation

/// An enumeration representing the initial lifetime of a blob cache object.
public enum CacheLifetime {

    /// An enumeration representing the policy for extending the lifetime
    /// of an existing blob cache object.
    public enum ExtensionPolicy {

        /// Extends the lifetime of the cached object immediately regardless
        /// of how much time that object has left.
        case extendImmediately(by: DateComponents)

        /// Extends the lifetime of the cached object by the given time if
        /// the percent-remaining lifetime is less than or equal to the
        /// argument value.
        case extendDuringLifetime(remaining: Percent, by: DateComponents)

        /// Extends the lifetime of the cached object by the given time if
        /// the current lifetime has almost expired.
        case extendWhenNearlyExpired(by: DateComponents)

    }

    /// A cache lifetime that never expires.
    case forever

    /// A cache lifetime that initially expires a given length of time from now.
    case sometimeFromNow(DateComponents)

    /// A cache lifetime that initially expires a given length of time from a
    /// referece date.
    case sometimeFromReferenceDate(Date, DateComponents)

    var expirationDate: Date {
        // If for whatever reason an expiration date can't be calculated, the current time
        // is provided. This could result in thrashing, so we may need to be mindful of this.
        switch self {
        case .forever: return .distantFuture
        case .sometimeFromNow(let components):
            return (components.calendar ?? Calendar.current).date(byAdding: components, to: Date()) ?? Date()
        case .sometimeFromReferenceDate(let date, let components):
            return (components.calendar ?? Calendar.current).date(byAdding: components, to: date) ?? Date()
        }
    }

}
