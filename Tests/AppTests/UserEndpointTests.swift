@testable import App
import Crypto
import Vapor
import XCTest
import FluentPostgreSQL

extension Routes.Users: UserEndpoint { }

final class UserEndpointTests: AppTesCase {

    private func deleteAllUsers() throws {
        let conn = try dbConnection()
        try UserToken.query(on: conn, withSoftDeleted: true).delete(force: true).wait()
        let users = User.query(on: conn).all()
        try users.wait().forEach { user in
            try user.delete(on: conn).wait()
        }
    }
    
    func testUserLogin() throws {
        try deleteAllUsers()

        let conn = try dbConnection()
        let userPassword = "1234"
        let user = User(id: nil, name: "William", email: "mail@mail.com", passwordHash: try BCrypt.hash(userPassword))
        let savedUser = try user.save(on: conn).wait()
        guard let savedUserId = savedUser.id else {
            return XCTFail("Failed creating user")
        }
        let loginRequest = LoginRequestContent(email: user.email, password: userPassword)
        let loginEndpoint = API.Login<Routes.Login>.login(loginRequest)
        // Get Response
        let response = try app.getResponse(request: try loginEndpoint.request())
        // Response Data
        guard let responseData = response.body.data else {
            return XCTFail("Data is nil")
        }
        
        do {
            switch try loginEndpoint.parse(data: responseData) {
            case .login(let loginResponse):
                XCTAssertEqual(loginResponse.userID, savedUserId)
            }
        } catch let responseError as ResponseError {
            XCTFail("Failed creating user: \(responseError.reason)")
        } catch {
            XCTFail("Failed decoding data: \(String(data: responseData, encoding: .utf8)!)")
        }
    }
}

