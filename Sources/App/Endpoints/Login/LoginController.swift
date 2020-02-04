import Crypto
import Vapor
import FluentPostgreSQL

/// Creates new users and logs them in.
final class LoginController {
    /// Logs a user in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<UserToken> {
        // get user auth'd by basic auth middleware
        let user = try req.requireAuthenticated(User.self)
        
        let useCase = AuthenticateUserUseCase(user: user, db: req)
        return try useCase.authenticateUser()
    }
}
