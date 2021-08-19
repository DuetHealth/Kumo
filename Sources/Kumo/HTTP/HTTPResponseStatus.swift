import Foundation

public extension HTTP {

    /// The HTTP response status for a given request.
    /// - seealso: [Response Status Codes](https://httpwg.org/specs/rfc7231.html#status.codes)
    enum ResponseStatus: Int {

        case unknown = -1337

        case continue100 = 100
        case switchingProtocol101 = 101
        case processing102 = 102

        case ok200 = 200
        case created201 = 201
        case accepted202 = 202
        case nonAuthoritativeInformation203 = 203
        case noContent204 = 204
        case resetContent205 = 205
        case partialContent206 = 206
        case multiStatus207 = 207
        case multiStatus208 = 208
        case imUsed226 = 226

        case multipleChoice300 = 300
        case movedPermanently301 = 301
        case found302 = 302
        case seeOther303 = 303
        case notModified304 = 304
        case temporaryRedirect307 = 307
        case permanentRedirect308 = 308

        case badRequest400 = 400
        case unauthorized401 = 401
        case paymentRequired402 = 402
        case forbidden403 = 403
        case notFound404 = 404
        case methodNotAllowed405 = 405
        case notAcceptable406 = 406
        case proxyAuthenticationRequired407 = 407
        case requestTimeout408 = 408
        case conflict409 = 409
        case gone410 = 410
        case lengthRequired411 = 411
        case preconditionFailed412 = 412
        case payloadTooLarge413 = 413
        case uriTooLong414 = 414
        case unsupportedMediaType415 = 415
        case requestedRangeNotSatisfiable416 = 416
        case expectationFailed = 417
        case imATeapot418 = 418
        case misdirectedRequest421 = 421
        case unprocessableEntity422 = 422
        case locked423 = 423
        case failedDependency424 = 424
        case upgradeRequired426 = 426
        case preconditionRequired428 = 428
        case tooManyRequests429 = 429
        case requestHeaderFieldsTooLarge431 = 431
        case unavailableForLegalReasons451 = 451

        case internalServerError500 = 500
        case notImplemented501 = 501
        case badGateway502 = 502
        case serviceUnavailable503 = 503
        case gatewayTimeout504 = 504
        case httpVersionUnsupported505 = 505
        case variantAlsoNegotiates506 = 506
        case insufficientStorage507 = 507
        case loopDetected508 = 508
        case notExtended510 = 510
        case networkAuthenticationRequired511 = 511

        public var isInformation: Bool {
            return (100...199).contains(rawValue)
        }

        public var isSuccessful: Bool {
            return (200...299).contains(rawValue)
        }

        public var isRedirection: Bool {
            return (300...399).contains(rawValue)
        }

        public var isClientError: Bool {
            return (400...499).contains(rawValue)
        }

        public var isServerError: Bool {
            return (500...599).contains(rawValue)
        }

        public var isError: Bool {
            return isClientError || isServerError
        }

    }

}

extension HTTPURLResponse {
    
    var status: HTTP.ResponseStatus {
        return HTTP.ResponseStatus(rawValue: statusCode) ?? .unknown
    }
    
}
