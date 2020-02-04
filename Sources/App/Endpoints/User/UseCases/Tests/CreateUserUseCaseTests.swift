@testable import App
import Vapor
import XCTest
import PostgreSQL

final class CreateUserUseCaseTests: AppTestCase {

    func testUserCreation() throws {
        try deleteAllUsers()
        let createUserRequest = App.CreateUserRequestContent(
            name: "Will Hass",
            email: "mail@mail.com",
            password: "1234",
            verifyPassword: "1234"
        )
        let createUserUseCase = CreateUserUseCase(user: createUserRequest, db: try dbConnection())
        let newUser = try createUserUseCase.createUser().wait()
        XCTAssertNotNil(newUser.id)
    }
    
    func testUserCreationFailed() throws {
        try deleteAllUsers()
        let createUserRequest = App.CreateUserRequestContent(
            name: "Will Hass",
            email: "mail@mail.com",
            password: "1234",
            verifyPassword: "1234"
        )
        let createUserUseCase = CreateUserUseCase(user: createUserRequest, db: try dbConnection())
        let newUser = try createUserUseCase.createUser().wait()
        do {
            XCTAssertNotNil(newUser.id)
            let result = try createUserUseCase.createUser().wait()
            XCTFail("Failed: Shouldn't have createad user \(result.email)")
        } catch _ as PostgreSQLError {
            XCTAssertTrue(true, "Success: User already exists")
        } catch let exception {
            XCTFail("Failed: \(exception.localizedDescription)")
        }
    }
}
