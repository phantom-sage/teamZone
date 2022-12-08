import Vapor

struct LoginManagerData: Content, Validatable {
    var email: String
    var password: String

    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("email", as: String.self, is: .email && !.empty && .count(..<100), required: true)
        validations.add("password", as: String.self, is: .ascii && !.empty && .count(8...32), required: true)
    }
}