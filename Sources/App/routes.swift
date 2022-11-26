import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.post("clients") { req async throws -> Client in
        let clientData = try req.content.decode(Client.self)
        let newClient = Client(username: clientData.username, email: clientData.email)
        try await newClient.save(on: req.db)
        return newClient
    }
}
