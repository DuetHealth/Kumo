import Foundation

public extension String.Encoding {
    
    public var stringValue: String? {
        return CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(rawValue)) as String?
    }
    
}
