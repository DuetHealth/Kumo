import Foundation

/// An upload error.
public enum UploadError: Error {

    /// The URL passed was not a file URL.
    case notAFileURL(URL)

    /// The file type of the file at the URL could not be determined.
    case unknownFileType(URL)

    /// The form data with the corresponding key could not be encoded.
    case cannotEncodeFormDataKey(String, encoding: String.Encoding)

    ///The MIME type could not be encoded in the `encoding`.
    case cannotEncodeMIMEType(String, encoding: String.Encoding)

    public var localizedDescription: String {
        switch self {
        case .notAFileURL(let url):
            return "Uploading expects a file URL, but was given \(url)."
        case .unknownFileType(let url):
            return "The type of the file located at path \(url) could not be determined."
        case .cannotEncodeFormDataKey(let key, encoding: let encoding):
            return "The key \(key) cannot be represented with \(encoding)."
        case .cannotEncodeMIMEType(let type, encoding: let encoding):
            return "The MIME type \(type) cannot be represented with \(encoding)."
        }
    }

}
