@testable import App
import Vapor
import XCTest
import PostgreSQL

final class AuthenticateUserUseCaseTests: AppTestCase {

    func testAuthentication() throws {
        let user = try UserTokenMock.userToken(db: try dbConnection()).user.get(on: try dbConnection()).wait()
        
        let useCase = AuthenticateUserUseCase(user: user, db: try dbConnection())
        let userToken = try useCase.authenticateUser().wait()
        XCTAssertNotNil(userToken.id)
    }
    
    func testAuthenticationFailed() throws {
        let user = User(id: 1, name: "Some", email: "mail@mail.com", passwordHash: "1222")
        let useCase = AuthenticateUserUseCase(user: user, db: try dbConnection())
        do {
            let _ = try useCase.authenticateUser().wait()
            XCTFail("User shouldn't authenticate")
        } catch let exception as PostgreSQLError {
            XCTAssertTrue(true, "Success - Authentication failed: \(exception.localizedDescription)")
        } catch let exception {
            XCTFail("Failed: \(exception.localizedDescription)")
        }
        
    }
}
