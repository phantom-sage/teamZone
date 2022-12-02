import Foundation
import Graphiti
import Vapor

let projectSchema = try! Schema<ProjectResolver, Request> {
    Scalar(UUID.self)

    //Scalar(Date.self)
    DateScalar(formatter: ISO8601DateFormatter())

    Type(Project.self) {
        Field("id", at: \.id)
        Field("name", at: \.name)
        Field("deadline", at: \.deadline)
    }

    Query {
        Field("projects", at: ProjectResolver.getAllProjects)
    }
}