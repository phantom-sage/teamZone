import Fluent

struct CreateTask: AsyncMigration {
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("tasks").delete()
    }

    func prepare(on database: FluentKit.Database) async throws {       
        try await database.schema("tasks")
        .id()
        .field("name", .string, .required)
        .field("status", .string, .required)
        .field("duration", .datetime, .required)
        .create()
    }

    
}