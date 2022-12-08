import Fluent
import Vapor
import Fakery

final class Manager: Model, Content {
    static var schema: String = "managers"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password")
    var password: String

    init() { }

    init(id: UUID? = nil, name: String, email: String, password: String) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
    }
}

extension Manager {
    static func isEmailUnique(_ value: String, on database: Database) async throws -> Bool {
        guard let _ = try await Manager.query(on: database).filter(\.$email == value).first() else {
            return false
        }
        return true
    }
}

extension Manager {
    static func createManager(on database: Database) async throws {
        let faker = Faker(locale: "en")
        let manager = Manager()
        manager.name = faker.name.name()
        manager.email = faker.internet.safeEmail()
        manager.password = faker.internet.password(minimumLength: 8, maximumLength: 32)
        try await manager.save(on: database)
    }
}
