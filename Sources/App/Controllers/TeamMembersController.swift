import Vapor

struct TeamMembersController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let teamMembersRoutes = routes.grouped("api", "teamMembers")
        teamMembersRoutes.post(use: createHandler)
        teamMembersRoutes.put(":teamMemberId", use: updateHandler)
        teamMembersRoutes.delete(":teamMemberId", use: deleteHandler)       
    }

    func createHandler(_ req: Request) async throws -> TeamMember {
        try CreateTeamMemberDataFromApi.validate(content: req)
        let teamMemberData = try req.content.decode(CreateTeamMemberDataFromApi.self)
        let teamMember = TeamMember()
        teamMember.name = teamMemberData.name
        teamMember.email = teamMemberData.email
        let digest = try await req.password.async.hash(teamMemberData.password)
        teamMember.password = digest
        try await teamMember.save(on: req.db)
        return teamMember
    }

    func updateHandler(_ req: Request) async throws -> TeamMember {
        guard let teamMember = try await TeamMember.find(req.parameters.get("teamMemberId"), on: req.db) else {
            throw Abort(.notFound, reason: "Team Member with this id: \(req.parameters.get("teamMemberId")!) not exists.")
        }

        try UpdateTeamMemberDataFromApi.validate(content: req)

        let teamMemberData = try req.content.decode(UpdateTeamMemberDataFromApi.self)
        teamMember.name = teamMemberData.name
        teamMember.email = teamMemberData.email
        try await teamMember.save(on: req.db)
        return teamMember
    }

    func deleteHandler(_ req: Request) async throws -> HTTPStatus {
        guard let teamMember = try await TeamMember.find(req.parameters.get("teamMemberId"), on: req.db) else {
            throw Abort(.notFound, reason: "Team Member with this id: \(req.parameters.get("teamMemberId")!) not exists.")
        }

        try await teamMember.delete(on: req.db)
        return .noContent
    }
}

struct CreateTeamMemberDataFromApi: Content, Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("name", as: String.self, is: .ascii && !.empty && .count(3...100), required: true)
        validations.add("email", as: String.self, is: .email && !.empty, required: true)
        validations.add("password", as: String.self, is: .ascii && !.empty && .count(8...32), required: true)
    }

    var name: String
    var email: String
    var password: String
}

struct UpdateTeamMemberDataFromApi: Content, Validatable {
    var name: String
    var email: String

    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("email", as: String.self, is: .email && !.empty, required: true)
        validations.add("name", as: String.self, is: .ascii && !.empty && .count(3...100), required: true)
    }
}