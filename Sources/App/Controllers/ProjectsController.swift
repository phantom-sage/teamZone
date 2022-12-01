import Vapor
import Fluent

struct ProjectsController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let projectsRoutes = routes.grouped("api", "projects")
        projectsRoutes.post(use: createHandler)
    }

    func createHandler(_ req: Request) async throws -> Project {
        try CreateProjectDataFromApi.validate(content: req)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 7200)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)

        let projectData = try req.content.decode(Project.self, using: decoder)
        let project = Project()
        project.name = projectData.name
        project.deadline = projectData.deadline
        try await project.save(on: req.db)
        return project
    }
}

struct CreateProjectDataFromApi: Content, Validatable {
    var name: String
    var deadlineAsString: String

    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("name", as: String.self, is: .ascii && !.empty && .count(3...100), required: true)
    }
}