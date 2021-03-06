@testable import App
import Crypto
import Vapor
import XCTest
import FluentPostgreSQL

extension Routes.Login: LoginEndpoint { }

extension CreateUserResponseContent {
    func belongsTo(request: CreateUserRequestContent) -> Bool {
        request.name == name
            && request.email == email
    }
}

final class LoginEndpointTests: AppTestCase {

    func testUserCreation() throws {
        // Boot
        let app = try AppMock.defaultTestApp()
        try App.boot(app)

        // Connect to DB
        let conn = try app.newConnection(to: .psql).wait()
        try deleteAllUsers()
        conn.close()

        // Request Body
        let newUserRequest = CreateUserRequestContent(name: "William", email: "mail@mail.com", password: "1234")
        
        // Enpoint Request
        let createUserEndpoint = API.User<Routes.Users>.createUser(newUserRequest)
        
        // Get Response
        let response = try app.getResponse(request: try createUserEndpoint.request())

        // Response Data
        guard let responseData = response.body.data else {
            return XCTFail("Data is nil")
        }
        do {
            switch try createUserEndpoint.parse(data: responseData) {
            case .createUser(let createUserResponse):
                XCTAssertTrue(createUserResponse.belongsTo(request: newUserRequest))
            }
        } catch let responseError as ResponseError {
           XCTFail("Failed creating user: \(responseError.reason)")
        } catch {
           XCTFail("Failed decoding data: \(String(data: responseData, encoding: .utf8)!)")
        }
    }
}
