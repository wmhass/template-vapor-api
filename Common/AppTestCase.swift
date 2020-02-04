@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

class AppTestCase: XCTestCase {

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

extension AppTestCase {
    func deleteAllUsers() throws {
        let conn = try dbConnection()
        try UserToken.query(on: conn, withSoftDeleted: true).delete(force: true).wait()
        let users = User.query(on: conn).all()
        try users.wait().forEach { user in
            try user.delete(on: conn).wait()
        }
    }
}

extension AppTestCase {
    func deleteAllTodos() throws {
        let todos = Todo.query(on: try dbConnection()).all()
        try todos.wait().forEach { todo in
            try todo.delete(on: dbConnection()).wait()
        }
    }
}
