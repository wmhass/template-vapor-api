@testable import App
import Vapor
import XCTest

final class CreateTodoUseCaseTests: AppTesCase {

    func testTodoCreation() throws {
        let createUseCase = CreateTodoUseCase(user: try user(), db: try dbConnection())
        let newTodo = try createUseCase.createTodo(Todo(title: "Homework")).wait()
        XCTAssertNotNil(newTodo.id)
    }
}
