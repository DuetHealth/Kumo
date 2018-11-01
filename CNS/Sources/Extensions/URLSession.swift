//
//  URLSession.swift
//  CNS
//
//  Created by ライアン on 10/29/18.
//  Copyright © 2018 Duet Health. All rights reserved.
//

import Foundation

class URLSessionInvalidationDelegate: NSObject, URLSessionDelegate {
    
    fileprivate var invalidations = [URLSession: (URLSession, Error?) -> ()]()
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        invalidations[session]?(session, error)
        invalidations[session] = nil
    }
    
    override func conforms(to aProtocol: Protocol) -> Bool {
        return protocol_isEqual(aProtocol, URLSessionTaskDelegate.self) || super.conforms(to: aProtocol)
    }
    
}

fileprivate var temporaryDelegateKey = UInt8.max

extension URLSession {
    
    func finishTasksAndInvalidate(onInvalidation: @escaping (URLSession, Error?) -> ()) {
        guard let delegate = self.delegate as? URLSessionInvalidationDelegate else { return }
        delegate.invalidations[self] = onInvalidation
        finishTasksAndInvalidate()
    }
    
}
