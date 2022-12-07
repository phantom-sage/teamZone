import Vapor

struct CreateClientFromApi: Content {
    var username: String
    var email: String
}

extension CreateClientFromApi: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email && !.empty, required: true)
        validations.add("username", as: String.self, is: .ascii && !.empty && .count(3...100), required: true)
    }
}