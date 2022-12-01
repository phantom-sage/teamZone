import Fluent

struct CreateHr: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema("hrs")
        .id()
        .field("name", .string, .required)
        .field("email", .string, .required)
        .field("password", .string, .required)
        .unique(on: "email")
        .create()
    }

    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("hrs").delete()
    }
}