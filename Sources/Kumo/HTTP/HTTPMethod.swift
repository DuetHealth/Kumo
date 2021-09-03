import Foundation

public extension HTTP {

    enum Method: String {

        /// Request data from a specified resource.
        case get = "GET"

        /// Submit data to a specified resource causing a state change / side
        /// effect on the server. Usually used for creation of content.
        case post = "POST"

        /// Submit data to replace existing data on the server. Usually used
        /// for updating content.
        case put = "PUT"

        /// Apply modifications to partially replace data on the server.
        case patch = "PATCH"

        /// Delete the specified resource.
        case delete = "DELETE"

        /// Request a ``get`` response without the response body.
        case head = "HEAD"

    }

}
