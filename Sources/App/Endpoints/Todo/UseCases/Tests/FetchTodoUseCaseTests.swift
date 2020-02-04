@testable import App
import Vapor
import XCTest

final class FetchTodoUseCaseTests: AppTestCase {
    
    func testFetchEmpty() throws {
        try deleteAllTodos()
 
        let fetchTodoUseCase = FetchTodoUseCase(user: try user(), db: try dbConnection())
        let todos = try fetchTodoUseCase.fetch().wait()
        XCTAssertTrue(todos.isEmpty)
    }
    
    func testFetchTodoNonEmpty() throws {
        let createUseCase = CreateTodoUseCase(user: try user(), db: try dbConnection())
        let newTodo = try createUseCase.createTodo(Todo(title: "Homework")).wait()
        
        let fetchTodoUseCase = FetchTodoUseCase(user: try user(), db: try dbConnection())
        let todos = try fetchTodoUseCase.fetch().wait()
        XCTAssertTrue(todos.contains(where: { $0.id == newTodo.id }))
    }
    
    func testFetchTodoFailed() throws {
        // TODO: Implement tests
    }
}
