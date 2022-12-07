import Vapor

struct CreateManagerFromApi: Content, Validatable {
    var name: String
    var email: String
    var password: String

    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("email", as: String.self, is: .email && !.empty, required: true)
        validations.add("name", as: String.self, is: .ascii && !.empty && .count(3...100), required: true)
        validations.add("password", as: String.self, is: .alphanumeric && !.empty && .count(8...32), required: true)
    }
}