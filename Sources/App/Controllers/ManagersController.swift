import Fluent
import Vapor
import JWT

struct ManagersController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let managersRoutes = routes.grouped("api", "managers")
        managersRoutes.post(use: createHandler)
        managersRoutes.post("login", use: loginHandler)
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

    func loginHandler(_ req: Request) async throws -> [String: String] {
        try LoginManagerData.validate(content: req)
        let managerData = try req.content.decode(LoginManagerData.self)
        guard let _ = try await Manager.query(on: req.db).filter(\.$email == managerData.email).first() else {
            throw Abort(.notFound, reason: "Manager with this Email-Address: \(managerData.email) not found.")
        }

        let payload = ManagerLoginJWT(subject: "managerLogin", expiration: .init(value: .distantFuture))
        let token = try req.jwt.sign(payload)
        return [
            "token": token
        ]
    }
}