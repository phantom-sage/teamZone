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

    init() { }

    init(
        id: UUID? = nil,
        name: String,
        status: TaskStatus,
        duration: Date
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.duration = duration
    }
}

enum TaskStatus: String, Codable {
    case inProgress
    case failed
    case completed
}