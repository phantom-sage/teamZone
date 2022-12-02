import Vapor
import Fluent

struct ProjectsController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let projectsRoutes = routes.grouped("api", "projects")
        projectsRoutes.post(use: createHandler)
        projectsRoutes.put(":projectId", use: updateHandler)
        projectsRoutes.delete(":projectId", use: deleteHandler)
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

    func updateHandler(_ req: Request) async throws -> Project {
        guard let project = try await Project.find(req.parameters.get("projectId"), on: req.db) else {
            throw Abort(.notFound, reason: "Project with this id: \(req.parameters.get("projectId")!) not found.")
        }


        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 7200)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)

        try UpdateProjectDataFromApi.validate(content: req)
        let projectData = try req.content.decode(UpdateProjectDataFromApi.self, using: decoder)
        project.name = projectData.name
        project.deadline = projectData.deadline
        try await project.save(on: req.db)
        return project
    }

    func deleteHandler(_ req: Request) async throws -> HTTPStatus {
        guard let project = try await Project.query(on: req.db).first() else {
            throw Abort(.notFound, reason: "Project with this id: \(req.parameters.get("projectId")!) not found.")
        }

        try await project.delete(on: req.db)
        return .noContent
    }
}

struct CreateProjectDataFromApi: Content, Validatable {
    var name: String
    var deadlineAsString: String

    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("name", as: String.self, is: .ascii && !.empty && .count(3...100), required: true)
    }
}

struct UpdateProjectDataFromApi: Content, Validatable {
    var name: String
    var deadline: Date

    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("name", as: String.self, is: .ascii && !.empty && .count(3...100), required: true)
    }
}