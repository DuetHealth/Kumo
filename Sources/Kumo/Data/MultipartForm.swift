import Foundation

fileprivate var crlf: String {
    return "\r\n"
}

fileprivate func crlf(_ encoding: String.Encoding, count: Int = 1) -> Data {
    return Data(Array(repeating: crlf.data(using: encoding)!, count: count).joined())
}

/// A structure representing form data that is divided into multiple parts
/// before being sent as a request to a server.
public struct MultipartForm {

    /// The string encoding used for the form data.
    public let encoding: String.Encoding

    let boundary = String(format: "----com.Duet.CNS\(UUID().uuidString)")

    /// The data representation of the multipart form.
    public var data: Data {
        return currentFormData
            + "--\(boundary)--".data(using: encoding)!
            + crlf(encoding)
    }
    
    private var currentFormData = Data()

    /// Creates an empty multipart form with the given `encoding`.
    /// - Parameter encoding: The encoding to use for the ``data`` of the
    /// multipart form.
    public init(encoding: String.Encoding) {
        self.encoding = encoding
    }

    /// Creates a multipart form with the given `file` and `encoding`.
    /// - Parameters:
    ///   - file: A file to be added to the multipart form.
    ///   - key: The name of the disposition the file will be keyed under.
    ///   - encoding: The encoding to use for the ``data`` of the
    /// multipart form.
    public init(file: URL, under key: String, encoding: String.Encoding) throws {
        self.encoding = encoding
        try addFile(from: file, under: key)
    }

    /// Creates a multipart form with the given `data` and `encoding`.
    /// - Parameters:
    ///   - data: A dictionary of data to be added to the multipart form.
    ///   - encoding: The encoding to use for the ``data`` of the
    /// multipart form.
    public init(data: [String: String], encoding: String.Encoding) throws {
        self.encoding = encoding
        try? addFormData(data: data)
    }

    /// Adds a `file` to the form.
    /// - Parameters:
    ///   - file: The file to be added to the multipart form.
    ///   - key: The name of the disposition the file will be keyed under.
    public mutating func addFile(from url: URL, under key: String) throws {
        guard let fileType = try? FileType(fileExtension: url.pathExtension) else {
            throw UploadError.unknownFileType(url)
        }
        let disposition = try self.disposition(key: key, fileName: url.lastPathComponent)
        let contentType = try self.contentType(mimeType: fileType.mimeType)
        let fileData = try Data(contentsOf: url)
        currentFormData += [
            "--\(boundary)\(crlf)".data(using: encoding)!,
            disposition,
            contentType,
            crlf(encoding, count: 2),
            fileData,
            crlf(encoding, count: 2)
        ].reduce(Data(), +)
    }

    /// Adds `fileData` to the form.
    /// - Parameters:
    ///   - fileData: The data of the file to be added to the multipart form.
    ///   - fileName: The name of the file to be added to the multipart form.
    ///   - key: The name of the disposition the file will be keyed under.
    ///   - mimeType: The MIME type of the file to be added.
    public mutating func addFile(from fileData: Data, withName fileName: String, key: String? = nil, mimeType: String? = nil) throws {
        let url = URL(fileURLWithPath: fileName)

        let contentType: Data
        if let mimeType = mimeType {
            contentType = try self.contentType(mimeType: mimeType)
        } else {
            guard let fileType = try? FileType(fileExtension: url.pathExtension) else {
                throw UploadError.unknownFileType(url)
            }
            contentType = try self.contentType(mimeType: fileType.mimeType)
        }

        let disposition = try self.disposition(key: key ?? fileName, fileName: url.lastPathComponent)
        currentFormData += [
            "--\(boundary)\(crlf)".data(using: encoding)!,
            disposition,
            contentType,
            crlf(encoding, count: 2),
            fileData,
            crlf(encoding, count: 2)
        ].reduce(Data(), +)
    }

    /// Adds `data` to the form.
    /// - Parameters:
    ///   - data: A dictionary of data to be added to the multipart form.
    public mutating func addFormData(data: [String : String]) throws {
        for (key, value) in data {
            let k = key
            let v = value
            let disposition = try self.disposition(key: k)
            let contentType = try self.contentType(mimeType: "application/json; charset=UTF-8")
            currentFormData += [
                "--\(boundary)\(crlf)".data(using: encoding)!,
                disposition,
                contentType,
                crlf(encoding, count: 2),
                v.data(using: encoding)!,
                crlf(encoding, count: 2)
            ].reduce(Data(), +)
        }

    }
    
    private func disposition(key: String, fileName: String) throws -> Data {
        guard let disposition = "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"\(crlf)".data(using: encoding) else {
            throw UploadError.cannotEncodeFormDataKey(key, encoding: encoding)
        }
        return disposition
    }

    private func disposition(key: String) throws -> Data {
        guard let disposition = "Content-Disposition: form-data; name=\"\(key)\"; \(crlf)".data(using: encoding) else {
            throw UploadError.cannotEncodeFormDataKey(key, encoding: encoding)
        }
        return disposition
    }

    private func contentType(mimeType: String) throws -> Data {
        guard let contentType = "Content-Type: \(mimeType)".data(using: encoding) else {
            throw UploadError.cannotEncodeMIMEType(mimeType, encoding: encoding)
        }
        return contentType
    }
    
}
