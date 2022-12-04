import Fluent
import Vapor
import Fakery

final class TeamMember: Model, Content {
    static var schema: String = "team_members"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password")
    var password: String

    init() {}

    init(id: UUID? = nil, name: String, email: String, password: String) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
    }
}

extension TeamMember {
    static func createTeamMember(on database: Database) async throws {
        let faker = Faker(locale: "en")
        let teamMember = TeamMember()
        teamMember.name = faker.name.name()
        teamMember.email = faker.internet.safeEmail()
        teamMember.password = faker.internet.password(minimumLength: 8, maximumLength: 32)
        try await teamMember.save(on: database)
    }
}