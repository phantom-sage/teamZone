import Fluent

final class Task: Model {
    static var schema: String = "tasks"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "status")
    var status: TaskStatus

    @Field(key: "duration")
    var duration: Date

    @Parent(key: "project_id")
    var project: Project

    init() { }

    init(
        id: UUID? = nil,
        name: String,
        status: TaskStatus,
        duration: Date,
        projectId: Project.IDValue
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.duration = duration
        self.$project.id = projectId
    }
}

enum TaskStatus: String, Codable, CustomStringConvertible {
    var description: String {
        get { "TaskStatus" }
    }

    case inProgress
    case failed
    case completed
}