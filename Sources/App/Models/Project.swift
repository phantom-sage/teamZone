import Fluent
import Vapor

final class Project: Model, Content {
    static var schema: String = "projects"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "deadline")
    var deadline: Date

    init() { }

    init(id: UUID? = nil, deadline: Date) {
        self.id = id
        self.deadline = deadline
    }
}