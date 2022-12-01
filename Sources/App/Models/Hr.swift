import Fluent
import Vapor
import Fakery

final class Hr: Model, Content {
    static var schema: String = "hrs"

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

extension Hr {
    static func createHr(on database: Database) async throws {
        let faker = Faker(locale: "en")
        let hr = Hr()
        hr.name = faker.name.name()
        hr.email = faker.internet.email()
        hr.password = faker.internet.password(minimumLength: 8, maximumLength: 32)
        try await hr.save(on: database)
    }
}
