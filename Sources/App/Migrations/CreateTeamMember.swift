import Fluent

struct CreateTeamMember: AsyncMigration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: Database) async throws {
        try await database.schema("team_members")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("password", .string, .required)
            .unique(on: "email")
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema("team_members").delete()
    }
}