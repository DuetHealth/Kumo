//
//  Service+Upload.swift
//  CNS
//
//  Created by ライアン on 3/1/19.
//

import Foundation
import RxSwift

public extension Service {
    
    /// Uploads to an endpoint the provided file. The file is uploaded as form data
    /// under the supplied key.
    ///
    /// - Parameters:
    ///   - endpoint: the path extension corresponding to the endpoint
    ///   - file: the URL of the file to upload
    ///   - key: the name of form part under which to embed the file's data
    /// - Returns: an `Observable` which emits a single empty element upon success.
    public func upload(_ endpoint: String, parameters: [String: Any] = [:], file: URL, under key: String) -> Observable<Void> {
        return Observable.create { [self] observer in
            do {
                var request = try self.createRequest(method: .post, endpoint: endpoint, queryParameters: parameters)
                guard file.isFileURL else { throw UploadError.notAFileURL(file) }
                let form = try MultipartForm(file: file, under: key, encoding: .utf8)
                request.set(contentType: .multipartFormData(boundary: form.boundary))
                let task = self.session.uploadTask(with: request, from: form.data) {
                    observer.on(self.resultToEvent(data: $0, response: $1, error: $2))
                    observer.onCompleted()
                }
                task.resume()
                return Disposables.create(with: task.cancel)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
            .observeOn(operationScheduler)
    }
    
    /// Uploads to an endpoint the provided file. The file is uploaded as form data
    /// under the supplied key.
    ///
    /// - Parameters:
    ///   - endpoint: the path extension corresponding to the endpoint
    ///   - file: the URL of the file to upload
    ///   - key: the name of form part under which to embed the file's data
    /// - Returns: an `Observable` which emits the progress of the upload.
    public func upload(_ endpoint: String, parameters: [String: Any] = [:], file: URL, under key: String) -> Observable<Double> {
        return Observable.create { [self] observer in
            do {
                var request = try self.createRequest(method: .post, endpoint: endpoint, queryParameters: parameters)
                guard file.isFileURL else { throw UploadError.notAFileURL(file) }
                let form = try MultipartForm(file: file, under: key, encoding: .utf8)
                request.set(contentType: .multipartFormData(boundary: form.boundary))
                let task = self.session.uploadTask(with: request, from: form.data) {
                    guard let error = self.resultToEvent(data: $0, response: $1, error: $2).error else {
                        return observer.onCompleted()
                    }
                    observer.onError(error)
                }
                task.resume()
                observer.onNext(task)
                return Disposables.create(with: task.cancel)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
            .observeOn(operationScheduler)
            .flatMap { (task: URLSessionUploadTask) in
                task.progress.rx.fractionComplete
                    .takeWhile { $0 < 1 }
            }
    }
    
}
