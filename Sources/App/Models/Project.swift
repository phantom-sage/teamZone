import Fluent
import Vapor
import Fakery

final class Project: Model, Content {
    static var schema: String = "projects"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "deadline")
    var deadline: Date

    @Children(for: \.$project)
    var tasks: [Task]

    init() { }

    init(id: UUID? = nil, deadline: Date) {
        self.id = id
        self.deadline = deadline
    }
}

extension Project {
    static func createProject(on database: Database) async throws {
        let faker = Faker(locale: "en")
        let project = Project()
        project.name = faker.name.name()
        project.deadline = Date()
        try await project.save(on: database)
    }
}