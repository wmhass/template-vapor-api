import Crypto
import Vapor
import FluentPostgreSQL

/// Creates new users and logs them in.
final class UserController {
    /// Creates a new user.
    func create(_ req: Request) throws -> Future<CreateUserResponseContent> {
        // decode request content
        return try req.content.decode(CreateUserRequestContent.self).flatMap { user -> Future<User> in
            let useCase = CreateUserUseCase(user: user,
                                            db: req)
            return try useCase.createUser()
        }.map { user in
            // map to public user response (omits password hash)
            return try CreateUserResponseContent(id: user.requireID(), name: user.name, email: user.email)
        }
    }
}

// MARK: Content

/// Data required to create a user.
struct CreateUserRequestContent: Content {
    /// User's full name.
    var name: String
    
    /// User's email address.
    var email: String
    
    /// User's desired password.
    var password: String
    
    /// User's password repeated to ensure they typed it correctly.
    var verifyPassword: String
}

/// Public representation of user data.
struct CreateUserResponseContent: Content {
    /// User's unique identifier.
    /// Not optional since we only return users that exist in the DB.
    var id: Int
    
    /// User's full name.
    var name: String
    
    /// User's email address.
    var email: String
}
