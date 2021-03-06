@testable import App
import Vapor
import XCTest

final class DeleteTodoUseCaseTests: AppTestCase {
    func testDeleteTodo() throws {
        let userAuth = try user()
        let connection = try dbConnection()
        let createUseCase = CreateTodoUseCase(user: userAuth, db: connection)
        let newTodo = try createUseCase.createTodo(Todo(title: "Homework")).wait()
        
        let deleteUseCase = DeleteTodoUseCase(user: userAuth, db: connection)
        try deleteUseCase.deleteTodo(newTodo).wait()
        XCTAssertTrue(true, "Todo deleted")
    }
    
    func testDeleteTodoFailed() throws {
        let userAuth = try user()
        let connection = try dbConnection()
        let deleteUseCase = DeleteTodoUseCase(user: userAuth, db: connection)

        try deleteAllTodos()
        do {
            try deleteUseCase.deleteTodo(Todo(id: 1234, title: "Hello")).wait()
            XCTAssert(true, "Failed deleting innsexistent todo")
        } catch let exception as Abort {
            XCTAssertEqual(exception.status, .badRequest)
        } catch let exception {
            XCTFail("Failed: \(exception.localizedDescription)")
        }
    }
    
    func testDeleteTodoFailedNoId() throws {
        let userAuth = try user()
        let connection = try dbConnection()
        let deleteUseCase = DeleteTodoUseCase(user: userAuth, db: connection)

        do {
            try deleteUseCase.deleteTodo(Todo(id: nil, title: "Hello")).wait()
            XCTFail("Shouldnt have deleted")
        } catch let exception as Abort {
            XCTAssertEqual(exception.status, .badRequest)
        } catch let exception {
            XCTAssert(true, exception.localizedDescription)
        }
    }
}
