import Vapor
import Fluent

struct HrsController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let hrsRoutes = routes.grouped("api", "hrs")
        hrsRoutes.post(use: createHandler)
        hrsRoutes.put(":hrId", use: updateHandler)
        hrsRoutes.delete(":hrId", use: deleteHandler)
    }

    func createHandler(_ req: Request) async throws -> HrResponse {
        try CreateHrDataFromApi.validate(content: req)
        let data = try req.content.decode(CreateHrDataFromApi.self)
        let hr = Hr()
        hr.name = data.name
        hr.email = data.email
        hr.password = try await req.password.async.hash(data.password)
        try await hr.save(on: req.db)

        return HrResponse(name: hr.name, email: hr.email)
    }

    func updateHandler(_ req: Request) async throws -> Hr {
        guard let hr = try await Hr.find(req.parameters.get("hrId"), on: req.db) else {
            throw Abort(.notFound, reason: "Hr with this id: \(req.parameters.get("hrId")!) not found")
        }

        try UpdateHrDataFromApi.validate(content: req)
        let hrData = try req.content.decode(UpdateHrDataFromApi.self)
        hr.name = hrData.name
        hr.email = hrData.email
        try await hr.update(on: req.db)
        return hr
    }

    func deleteHandler(_ req: Request) async throws -> HTTPStatus {
        guard let hr = try await Hr.find(req.parameters.get("hrId"), on: req.db) else {
            throw Abort(.notFound, reason: "Hr with this id: \(req.parameters.get("hrId")!) not found")
        }

        try await hr.delete(on: req.db)
        return .noContent
    }
}

struct UpdateHrDataFromApi: Content, Validatable {
    var name: String
    var email: String

    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("name", as: String.self, is: .ascii && !.empty && .count(3...100), required: true)
        validations.add("email", as: String.self, is: .ascii && !.empty && .email, required: true)
    }
}

struct CreateHrDataFromApi: Content, Validatable {
    var name: String
    var email: String
    var password: String

    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("email", as: String.self, is: .ascii && !.empty && .email, required: true)
        validations.add("name", as: String.self, is: .ascii && !.empty && .count(3...100), required: true)
        validations.add("password", as: String.self, is: .ascii && !.empty && .count(8...32), required: true)
    }
}

struct HrResponse: Content {
    var name: String
    var email: String
}
