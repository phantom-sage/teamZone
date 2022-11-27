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
        validations.add("username", as: String.self, is: .ascii && !.empty && .count(3...100), required: true)
    }
}

func routes(_ app: Application) throws {
    app.post("clients") { req async throws -> Client in
        try CreateClientFromApi.validate(content: req)
        let clientData = try req.content.decode(CreateClientFromApi.self)


        // check username uniqueness
        let isUsernameUnique = try await Client.isUsernameUnique(clientData.username, on: req.db)
        if isUsernameUnique {
            throw Abort(.badRequest, reason: "Client with this '\(clientData.username)' username already taken.")
        }

        // check email address uniqueness
        let isEmailAddressUnique = try await Client.isEmailAddressUnique(clientData.email, on: req.db)
        if isEmailAddressUnique {
            throw Abort(.badRequest, reason: "Client with this '\(clientData.email)' Email-Address already taken.")
        }

        let newClient = Client(username: clientData.username, email: clientData.email)
        try await newClient.save(on: req.db)
        return newClient
    }
}
