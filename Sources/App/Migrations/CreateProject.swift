import Fluent

struct CreateProject: AsyncMigration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: Database) async throws {
        try await database.schema("projects")
            .id()
            .field("name", .string, .required)
            .field("deadline", .datetime, .required)
            .unique(on: "name")
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema("projects").delete()
    }
}