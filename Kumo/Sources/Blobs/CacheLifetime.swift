import Foundation

public enum CacheLifetime {

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

    case forever
    case sometimeFromNow(DateComponents)
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
