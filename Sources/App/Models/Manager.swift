import Fluent
import Vapor

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

    init(id: UUID? = nil, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
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

extension Manager: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email && !.empty, required: true)
        validations.add("name", as: String.self, is: .ascii && !.empty && .count(3...100), required: true)
        validations.add("password", as: String.self, is: .alphanumeric && !.empty && .count(8...32), required: true)
    }
}