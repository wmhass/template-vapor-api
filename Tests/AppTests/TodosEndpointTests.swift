@testable import App
import Crypto
import Vapor
import XCTest
import FluentPostgreSQL

extension Routes.Todos: TodosEndpoint { }

final class TodosEndpointTests: AppTesCase {

    private func deleteAllTodos() throws {
        let todos = Todo.query(on: try dbConnection()).all()
        try todos.wait().forEach { todo in
            try todo.delete(on: dbConnection()).wait()
        }
    }
    
    func testFetchTodo() throws {
        try deleteAllTodos()

        let createUseCase = CreateTodoUseCase(user: try user(), db: try dbConnection())
        let _ = try createUseCase.createTodo(Todo(title: "Homework")).wait()
        
        let getTodosRequestContent = GetTodosRequestContent(token: try userToken().string)
        let todoRequest = API.Todos<Routes.Todos>.get(getTodosRequestContent)
        let response = try app.getResponse(request: try todoRequest.request())

        do {
            switch try todoRequest.parse(data: response.body.data) {
            case .get(let responseContent):
                //XCTAssert(responseContent.todos.count)
                XCTAssertGreaterThan(responseContent.todos.count, 0)
            default:
                XCTFail("Failed parsing response")
            }
        } catch let responseError as ResponseError {
            XCTFail("Failed creating todo: \(responseError.reason)")
        } catch {
            XCTFail("Failed decoding data: \(String(data: response.body.data ?? Data(), encoding: .utf8)!)")
        }
    }
    
    func testTodoDeletion() throws {
        try deleteAllTodos()
        let authObject = try userToken()

        let createUseCase = CreateTodoUseCase(user: try user(), db: try dbConnection())
        let newTodo = try createUseCase.createTodo(Todo(title: "Homework")).wait()

        let deleteTodoRequestContent = DeleteTodoRequestContent(
            token: authObject.string,
            body: DeleteTodoRequestBody(id: newTodo.id!)
        )
        let todoRequest = API.Todos<Routes.Todos>.delete(deleteTodoRequestContent)

        let response = try app.getResponse(request: try todoRequest.request())

        XCTAssertEqual(response.status.code, HTTPResponseStatus.ok.code)
    }

    func testTodoCreation() throws {
        try deleteAllTodos()
        
        let authObject = try UserTokenMock.userToken(db: try dbConnection())

        let createTodoRequestBody = CreateTodoRequestBody(title: "")
        let createTodoRequestContent = CreateTodoRequestContent(
            token: authObject.string,
            body: createTodoRequestBody
        )
        let todoRequest = API.Todos<Routes.Todos>.create(createTodoRequestContent)

        let response = try app.getResponse(request: try todoRequest.request())

        do {
            switch try todoRequest.parse(data: response.body.data) {
            case .create(let responseContent):
                XCTAssertGreaterThan(responseContent.id, 0)
            default:
                XCTFail("Failed parsing response")
            }
        } catch let responseError as ResponseError {
            XCTFail("Failed creating todo: \(responseError.reason)")
        } catch {
            XCTFail("Failed decoding data: \(String(data: response.body.data ?? Data(), encoding: .utf8)!)")
        }
    }
}
