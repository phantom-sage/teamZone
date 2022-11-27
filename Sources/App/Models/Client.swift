import Fluent
import Vapor

final class Client: Model, Content {
    static let schema = "clients"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "email")
    var email: String

    init() { }

    init(id: UUID? = nil, username: String, email: String) {
        self.id = id
        self.username = username
        self.email = email
    }
}

extension Client {
    static func isUsernameUnique(_ value: String, on database: Database) async throws -> Bool {
        guard let _ = try await Client.query(on: database).filter(\.$username == value).first() else {
            return false
        }
        return true
    }

    static func isEmailAddressUnique(_ value: String, on database: Database) async throws -> Bool {
        guard let _ = try await Client.query(on: database).filter(\.$email == value).first() else {
            return false
        }
        return true
    }
}