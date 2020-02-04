import Foundation
import HTTP

protocol TodosEndpoint: APIEndpoint {
    static var todos: String { get }
    static func todo(with id: Int) -> String
}

extension TodosEndpoint {
    static func todo(with id: Int) -> String {
        "\(todos)/\(id)"
    }
}

extension API {
    enum Todos<Endpoint: TodosEndpoint> {
        case create(CreateTodoRequestContent)
        case delete(DeleteTodoRequestContent)
        case get(GetTodosRequestContent)
    }
}

extension API.Todos: APIRequest {

    enum Parser: APIResponseParser {
        case create(CreateTodoResponseContent)
        case get(GetTodosResponseContent)
    }

    func request() throws -> HTTPRequest {
        switch self {
        case .get(let getTodosRequestContent):
            return try .get(url: Endpoint.todos,
                            authToken: getTodosRequestContent.token)
        case .create(let createTodoRequestContent):
            return try .jsonPost(url: Endpoint.todos,
                                 body: createTodoRequestContent.body,
                                 authToken: createTodoRequestContent.token)
        case .delete(let deleteTodoRequestContent):
            return try .delete(url: Endpoint.todo(with: deleteTodoRequestContent.body.id),
                               authToken: deleteTodoRequestContent.token)
        }
    }

    func parseObject(data: Data) throws -> Parser {
        switch self {
        case .get:
            return Parser.get(try JSONEnvelope<GetTodosResponseContent>.envelope(data))
        case .create:
            return Parser.create(try JSONEnvelope<CreateTodoResponseContent>.envelope(data))
        case .delete:
            throw ParseError.notImplemented
        }
    }
}

// MARK: - Request Content
struct CreateTodoRequestBody: Codable {
    let title: String
}

struct CreateTodoRequestContent: Codable, RequestWithToken {
    let token: String
    let body: CreateTodoRequestBody
}

struct DeleteTodoRequestBody: Codable {
    let id: Int
}

struct DeleteTodoRequestContent: Codable, RequestWithToken {
    let token: String
    let body: DeleteTodoRequestBody
}

struct GetTodosRequestContent: Codable, RequestWithToken {
    let token: String
}

// MARK: - Response Content
struct CreateTodoResponseContent: Codable {
    let id: Int
}

struct GetTodosResponseContent: Codable {
    struct Todo: Codable {
        let id: Int
        let title: String
    }
    let todos: [Todo]
    
    func encode(to encoder: Encoder) throws {
        var single = encoder.unkeyedContainer()
        try single.encode(todos)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.todos = try container.decode([Todo].self)
    }
}
