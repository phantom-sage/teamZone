import Fluent
import Vapor


// For create new client from api
struct CreateClientFromApi: Content {
    var username: String
    var email: String
}

extension CreateClientFromApi: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email && !.empty, required: true)
        validations.add("username", as: String.self, is: .ascii && !.empty, required: true)
    }
}

func routes(_ app: Application) throws {
    app.post("clients") { req async throws -> Client in
        try CreateClientFromApi.validate(content: req)
        let clientData = try req.content.decode(CreateClientFromApi.self)
        let newClient = Client(username: clientData.username, email: clientData.email)
        try await newClient.save(on: req.db)
        return newClient
    }
}
