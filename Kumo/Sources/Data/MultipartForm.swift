import Foundation

fileprivate var crlf: String {
    return "\r\n"
}

fileprivate func crlf(_ encoding: String.Encoding, count: Int = 1) -> Data {
    return Data(Array(repeating: crlf.data(using: encoding)!, count: count).joined())
}

public struct MultipartForm {
    
    public let encoding: String.Encoding
    let boundary = String(format: "----com.Duet.CNS\(UUID().uuidString)")
    
    public var data: Data {
        return currentFormData
            + "--\(boundary)--".data(using: .utf8)!
            + crlf(encoding)
    }
    
    private var currentFormData = Data()

    public init(encoding: String.Encoding) {
        self.encoding = encoding
    }

    public init(file: URL, under key: String, encoding: String.Encoding) throws {
        self.encoding = encoding
        try addFile(from: file, under: key)
    }

    public init(data: [String: Any], encoding: String.Encoding) throws {
        self.encoding = encoding
        try? addFormData(data: data)
    }

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

    public mutating func addFormData(data: [String : Any]) throws {
        for (key,value) in data {
            let k = key
            let v = value as! String
            let disposition = try self.disposition(key: k)
            let contentType = try self.contentType(mimeType: "application/json; charset=UTF-8")
            currentFormData += [
                "--\(boundary)\(crlf)".data(using: encoding)!,
                disposition,
                contentType,
                crlf(encoding, count: 2),
                v.data(using: .utf8)!,
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
