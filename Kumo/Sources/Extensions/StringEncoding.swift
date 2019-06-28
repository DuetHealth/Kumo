import Foundation

public extension String.Encoding {
    
    var stringValue: String? {
        return CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(rawValue)) as String?
    }
    
}
