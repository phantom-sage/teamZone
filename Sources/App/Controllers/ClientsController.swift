import Vapor
import Fluent


struct ClientsController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let clientsRoutes = routes.grouped("api", "clients")
        clientsRoutes.post(use: createHandler)
    }

    func createHandler(_ req: Request) async throws -> Client {
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
