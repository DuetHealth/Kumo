import Foundation

func +(_ lhs: Date, _ rhs: DateComponents) -> Date {
    return (rhs.calendar ?? Calendar.autoupdatingCurrent).date(byAdding: rhs, to: lhs) ?? lhs
}

extension DateComponents {

    static func minutes(_ minutes: Int) -> DateComponents {
        return DateComponents(minute: minutes)
    }

    static func days(_ days: Int) -> DateComponents {
        return DateComponents(day: days)
    }

}

public class Storage: StoragePruningDelegate {

    public struct Heuristics {

        public static var inMemory: Heuristics {
            return Heuristics(initialCacheLifetime: .sometimeFromNow(.minutes(5)), lifetimeExtensionPolicy: .extendDuringLifetime(remaining: .half, by: .minutes(5)), cleansIndiscriminately: true)
        }

        public static var fileSystem: Heuristics {
            return Heuristics(initialCacheLifetime: .sometimeFromNow(.days(7)), lifetimeExtensionPolicy: .extendWhenNearlyExpired(by: .days(7)), cleansIndiscriminately: false)
        }

        public var initialCacheLifetime: CacheLifetime
        public var lifetimeExtensionPolicy: CacheLifetime.ExtensionPolicy?
        public var cleansIndiscriminately: Bool
    }

    private let location: StorageLocation

    var heuristics: Heuristics
    var fallback: Storage?

    init(location: StorageLocation, heuristics: Heuristics) {
        self.location = location
        self.heuristics = heuristics
        location.delegate = self
    }

    func fetch<D: _DataRepresentable & _DataConvertible>(for url: URL, convertWith conversionArguments: D._ConversionArguments, representWith representationArguments: D._RepresentationArguments) throws -> D? {
        if let immediate: D = try location.fetch(for: url, arguments: representationArguments) { return immediate }
        guard let secondary: D = try fallback?.fetch(for: url, convertWith: conversionArguments, representWith: representationArguments) else { return nil }
        try location.write(secondary, from: url, arguments: conversionArguments)
        return secondary
    }

    func acquire<D: _DataRepresentable & _DataConvertible>(fromPath path: URL, origin url: URL, convertWith conversionArguments: D._ConversionArguments, representWith representationArguments: D._RepresentationArguments) throws -> D? {
        if let immediate: D = try location.acquire(fromPath: path, origin: url, arguments: representationArguments) { return immediate }
        guard let secondary: D = try fallback?.acquire(fromPath: path, origin: url, convertWith: conversionArguments, representWith: representationArguments) else { return nil }
        try location.write(secondary, from: url, arguments: conversionArguments)
        return secondary
    }

    func newExpirationDate(given parameters: CachedObjectParameters) -> Date? {
        guard let currentExpirationDate = parameters.expirationDate else {
            return heuristics.initialCacheLifetime.expirationDate
        }
        if currentExpirationDate == .distantFuture { return currentExpirationDate }
        switch heuristics.lifetimeExtensionPolicy {
        case .none: return currentExpirationDate
        case .some(.extendImmediately(by: let components)):
            return currentExpirationDate + components
        case .some(.extendWhenNearlyExpired(by: let components)):
            let elapsed = currentExpirationDate.timeIntervalSinceNow
            let total = currentExpirationDate.timeIntervalSince(parameters.referenceDate)
            return Percent(1 - elapsed / total) <= Percent.nearlyExpired ? currentExpirationDate + components : currentExpirationDate
        case .some(.extendDuringLifetime(remaining: let percent, by: let components)):
            let elapsed = currentExpirationDate.timeIntervalSinceNow
            let total = currentExpirationDate.timeIntervalSince(parameters.referenceDate)
            return Percent(1 - elapsed / total) <= percent ? currentExpirationDate + components : currentExpirationDate
        }
    }
    
    func clean() {
        heuristics.cleansIndiscriminately ? location.removeAll() : location.pruneExpired()
    }

}
