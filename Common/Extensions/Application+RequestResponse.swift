import Vapor

struct EmptyContent: Content {}
// MARK: - Application Request
extension Application {

    func sendRequest<T>(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(),
                        body: T? = nil) throws -> Response where T: Content {
        let responder = try self.make(Responder.self)
        let request = HTTPRequest(method: method, url: URL(string: path)!,
                                headers: headers)
        let wrappedRequest = Request(http: request, using: self)
        if let body = body {
            try wrappedRequest.content.encode(body)
        }
        return try responder.respond(to: wrappedRequest).wait()
    }

    func sendRequest(to path: String, method: HTTPMethod,
                     headers: HTTPHeaders = .init()) throws -> Response {
        let emptyContent: EmptyContent? = nil
        return try sendRequest(to: path,
                               method: method,
                               headers: headers,
                               body: emptyContent)
    }

    func sendRequest<T>(to path: String, method: HTTPMethod, headers: HTTPHeaders,
                        data: T) throws where T: Content {
        _ = try self.sendRequest(to: path,
                                 method: method,
                                 headers: headers,
                                 body: data)
    }
}

// MARK: - Application Response
extension Application {
    
    func getResponse(request: HTTPRequest) throws -> HTTPResponse {
        let request = Request(http: request, using: self)
        let responder = try make(Responder.self)
        let response = try responder.respond(to: request).wait()
        return response.http
    }

    func getResponse<C,T>(to path: String, method: HTTPMethod = .GET,
                          headers: HTTPHeaders = .init(), data: C? = nil,
                          decodeTo type: T.Type) throws -> T where C: Content, T: Decodable {
        let response = try self.sendRequest(
            to: path, method: method,
            headers: headers, body: data
        )
        return try response.content.decode(type).wait()
    }

    func getResponse<T>(to path: String, method: HTTPMethod = .GET,
                        headers: HTTPHeaders = .init(),
                        decodeTo type: T.Type) throws -> T where T: Decodable {
        let emptyContent: EmptyContent? = nil
        return try self.getResponse(to: path, method: method, headers: headers,
                                    data: emptyContent, decodeTo: type)
    }
}

