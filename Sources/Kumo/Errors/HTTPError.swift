import Foundation

/// An enumeration of HTTP errors.
public enum HTTPError: Error {

    /// The URL / parameter list is invalid.
    case malformedURL(_ url: URL, parameters: [String: Any])

    /// The URL string / parameter list is invalid.
    case malformedURLString(_ urlString: String, parameters: [String: Any])

    /// The body of the request was unserializable.
    case unserializableRequestBody(object: Any?, originalError: Error)

    /// The response was corrupted.
    case corruptedResponse(object: Any)

    /// The response was empty.
    case emptyResponse

    /// The response was unsupported.
    case unsupportedResponse

    /// The error type could not be decoded.
    case corruptedError(Error.Type, decodingError: Error)

    /// An HTTP response status.
    case ambiguousError(HTTP.ResponseStatus)

    public var localizedDescription: String {
        switch self {
        case .malformedURL(let url, let parameters):
            return "A valid URL could not be created with the URL '\(url)' and the parameters '\(parameters))'."
        case .malformedURLString(let url, parameters: let parameters):
            return "A valid URL could not be created with the URL '\(url)' and the parameters '\(parameters))'."
        case .unserializableRequestBody(object: let object, originalError: let error):
            return "The following object cannot be serialized: \(String(describing: object)); reason: \(error)"
        case .corruptedResponse(object: let object):
            return "The response returned an unexpected object: \(object)"
        case .emptyResponse:
            return "The response included no information."
        case .unsupportedResponse:
            return "The response does not conform to HTTP."
        case .corruptedError(let type, decodingError: let error):
            return "The error response included a body but could not be decoded to type \(type); reason: \(error)"
        case .ambiguousError(let status):
            return "The response returned status code \(status.rawValue)"
        }
    }

}
