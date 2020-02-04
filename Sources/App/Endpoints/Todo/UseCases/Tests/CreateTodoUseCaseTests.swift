@testable import App
import Vapor
import XCTest
import PostgreSQL

final class CreateTodoUseCaseTests: AppTesCase {

    func testTodoCreation() throws {
        let createUseCase = CreateTodoUseCase(user: try user(), db: try dbConnection())
        let newTodo = try createUseCase.createTodo(Todo(title: "Homework")).wait()
        XCTAssertNotNil(newTodo.id)
    }
    
    func testTodoCreationFail() throws {
        let createUseCase = CreateTodoUseCase(user: try user(), db: try dbConnection())

        do {
            let newTodo = try createUseCase.createTodo(Todo(title: "")).wait()
            XCTAssertNotNil(newTodo.id)
            XCTFail("Failed: Shouldn't have createad user \(newTodo.title)")
        } catch let exception as Abort {
            XCTAssertEqual(exception.status, .badRequest)
        } catch let exception {
            XCTFail("Failed: \(exception.localizedDescription)")
        }
    }
}
