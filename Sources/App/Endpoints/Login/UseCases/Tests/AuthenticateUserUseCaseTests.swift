@testable import App
import Vapor
import XCTest

final class AuthenticateUserUseCaseTests: AppTesCase {

    func testAuthentication() throws {
        let user = try UserTokenMock.userToken(db: try dbConnection()).user.get(on: try dbConnection()).wait()
        
        let useCase = AuthenticateUserUseCase(user: user, db: try dbConnection())
        let userToken = try useCase.authenticateUser().wait()
        XCTAssertNotNil(userToken.id)
    }
}
