import Fluent
import Vapor

struct ManagersController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let managersRoutes = routes.grouped("api", "managers")
        managersRoutes.post(use: createHandler)
    }

    func createHandler(_ req: Request) async throws -> ManagerDataFromCreateHandler {
        try CreateManagerFromApi.validate(content: req)
        let data = try req.content.decode(CreateManagerFromApi.self)
        
        if try await Manager.isEmailUnique(data.email, on: req.db) {
            throw Abort(.badRequest, reason: "Manager with this '\(data.email)' Email-Address already taken.")
        }

        let manager = Manager()
        manager.name = data.name
        manager.email = data.email
        let digest = try await req.password.async.hash(data.password)
        manager.password = digest
        try await manager.save(on: req.db)

        return ManagerDataFromCreateHandler(name: manager.name, email: manager.email)
    }
}