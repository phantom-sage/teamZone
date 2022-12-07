import Vapor

struct TaskDataFromCreateHandler: Content, Validatable {
    var name: String
    var status: TaskStatus
    var duration: Date
    var projectId: UUID

    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("name", as: String.self, is: .ascii && !.empty && .count(3...150), required: true)
        validations.add(
            "status",
            as: TaskStatus.self,
            is: .in(TaskStatus.completed, TaskStatus.failed, TaskStatus.inProgress),
            required: true,
            customFailureDescription: "Allowed values for TaskStatus: (completed, failed, inProgress)."
        )
    }
}