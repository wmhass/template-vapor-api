@testable import App
import Vapor
import XCTest

final class FetchTodoUseCaseTests: AppTesCase {
    
    func testFetchTodo() throws {
        let createUseCase = CreateTodoUseCase(user: try user(), db: try dbConnection())
        let newTodo = try createUseCase.createTodo(Todo(title: "Homework")).wait()
        
        let fetchTodoUseCase = FetchTodoUseCase(user: try user(), db: try dbConnection())
        let todos = try fetchTodoUseCase.fetch().wait()
        XCTAssertTrue(todos.contains(where: { $0.id == newTodo.id }))
    }
}
