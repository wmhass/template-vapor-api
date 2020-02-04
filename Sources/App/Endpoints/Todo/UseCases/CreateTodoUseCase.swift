import Vapor

struct CreateTodoUseCase {
    let user: User
    let db: DatabaseConnectable

    func createTodo(_ todo: Todo) throws -> Future<Todo> {
        guard !todo.title.isEmpty else {
            throw Abort(.badRequest, reason: "Title should not be empty")
        }
        return todo.save(on: db)
    }
}


// MARK: - Helper
extension CreateTodoUseCase {
    func createTodo(_ request: Request) throws -> Future<Todo> {
        try request.content.decode(Todo.self).flatMap({ todo in
            return try self.createTodo(todo)
        })
    }
}
