import Fluent

struct CreateTask: AsyncMigration {
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("tasks").delete()
    }

    func prepare(on database: FluentKit.Database) async throws {      
        let taskStatusDatabaseEnum = try await database.enum("task_status")
        .case(TaskStatus.completed.rawValue)
        .case(TaskStatus.failed.rawValue)
        .case(TaskStatus.inProgress.rawValue)
        .create()

        try await database.schema("tasks")
        .id()
        .field("name", .string, .required)
        .field("status", taskStatusDatabaseEnum, .required)
        .field("duration", .datetime, .required)
        .field("project_id", .uuid, .required, .references("projects", "id"))
        .create()
    }

    
}