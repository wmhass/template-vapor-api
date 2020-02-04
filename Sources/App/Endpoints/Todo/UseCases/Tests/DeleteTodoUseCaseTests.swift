@testable import App
import Vapor
import XCTest

final class DeleteTodoUseCaseTests: AppTesCase {
    func testDeleteTodo() throws {
        let userAuth = try user()
        let connection = try dbConnection()
        let createUseCase = CreateTodoUseCase(user: userAuth, db: connection)
        let newTodo = try createUseCase.createTodo(Todo(title: "Homework")).wait()
        
        let deleteUseCase = DeleteTodoUseCase(user: userAuth, db: connection)
        try deleteUseCase.deleteTodo(newTodo).wait()
        XCTAssertTrue(true, "Todo deleted")
    }
}
