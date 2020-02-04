@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

class AppTesCase: XCTestCase {

    lazy var app: Application = {
        let app = try! AppMock.defaultTestApp()
        try! App.boot(app)
        return app
    }()

    private var connection: PostgreSQLConnection?
    
    func user() throws -> User {
        try userToken().user.get(on: dbConnection()).wait()
    }
    
    func userToken() throws -> UserToken {
        try UserTokenMock.userToken(db: dbConnection())
    }
    
    func dbConnection() throws -> PostgreSQLConnection {
        if let connection = connection {
            return connection
        } else {
            let conn = try app.newConnection(to: .psql).wait()
            self.connection = conn
            return conn
        }
    }
}
