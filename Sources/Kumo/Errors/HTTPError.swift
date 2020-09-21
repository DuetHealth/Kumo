import Foundation

public enum HTTPError: Error {
    case malformedURL(_ url: URL, parameters: [String: Any])
    case malformedURLString(_ urlString: String, parameters: [String: Any])
    case unserializableRequestBody(object: Any?, originalError: Error)
    case corruptedResponse(object: Any)
    case emptyResponse
    case unsupportedResponse
    case corruptedError(Error.Type, decodingError: Error)
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
