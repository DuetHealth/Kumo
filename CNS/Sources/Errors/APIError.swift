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
    case unserializableRequestBody(object: Any, originalError: Error)
    case corruptedResponse(object: Any)

    public var localizedDescription: String {
        switch self {
        case .malformedURL(let baseURL, let endpoint):
            return "The URL formed by appending the path component '\(endpoint)' to '\(baseURL)' is malformed: \(baseURL.appendingPathComponent(endpoint))"
        case .unserializableRequestBody(object: let object):
            return "The following object cannot be serialized: \(object)"
        case .corruptedResponse(object: let object):
            return "The response returned an unexpected object: \(object)"
        }
    }
}
