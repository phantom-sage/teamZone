import Vapor

struct TeamMembersController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let teamMembersRoutes = routes.grouped("api", "teamMembers")
        teamMembersRoutes.post(use: createHandler)       
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