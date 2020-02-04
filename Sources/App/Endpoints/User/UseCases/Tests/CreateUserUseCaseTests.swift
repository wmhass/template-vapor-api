@testable import App
import Vapor
import XCTest

final class CreateUserUseCaseTests: AppTesCase {

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
}
