import Graphiti
import Vapor

final class ProjectResolver {
    func getAllProjects(request: Request, _: NoArguments) throws -> EventLoopFuture<[Project]> {
        Project.query(on: request.db).all()
    }
}