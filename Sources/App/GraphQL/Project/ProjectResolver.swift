import Graphiti
import Vapor

final class ProjectResolver {
    struct ProjectIdGraphQLArgument: Codable {
        let id: UUID
    }

    func getAllProjects(request: Request, _: NoArguments) throws -> EventLoopFuture<[Project]> {
        Project.query(on: request.db).all()
    }

    func getProject(request: Request, arguments: ProjectIdGraphQLArgument) throws -> EventLoopFuture<Project> {
        Project.find(arguments.id, on: request.db)
        .unwrap(or: Abort(.notFound))
    }
}