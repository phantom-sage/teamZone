import Fluent

struct CreateClient: AsyncMigration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: Database) async throws {
        try await database.schema("clients")
            .id()
            .field("username", .string)
            .field("email", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema("clients").delete()
    }
}