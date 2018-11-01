//
//  APIError.swift
//  DHKApi
//
//  Created by Ryan Wachowski on 8/7/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

public enum HTTPError: Error {
    case malformedURL(baseURL: URL, endpoint: String)
    case unserializableRequestBody(object: Any?, originalError: Error)
    case corruptedResponse(object: Any)
    case emptyResponse
    case unsupportedResponse
    case corruptedError(Error.Type, decodingError: Error)
    case ambiguousError(HTTPResponseStatus)

    public var localizedDescription: String {
        switch self {
        case .malformedURL(let baseURL, let endpoint):
            return "The URL formed by appending the path component '\(endpoint)' to '\(baseURL)' is malformed: \(baseURL.appendingPathComponent(endpoint))"
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

public enum UploadError: Error {
    case notAFileURL(URL)
    case unknownFileType(URL)
    case cannotEncodeFormData(name: String, encoding: String.Encoding)
    
    public var localizedDescription: String {
        switch self {
        case .notAFileURL(let url):
            return "Uploading expects a file URL, but was given \(url)."
        case .unknownFileType(let url):
            return "The type of the file located at path \(url) could not be determined."
        case .cannotEncodeFormData(name: let name, encoding: let encoding):
            return "The name \(name) cannot be represented with \(encoding)."
        }
    }
    
}
