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
            as: String.self,
            is: .in(TaskStatus.completed.rawValue, TaskStatus.failed.rawValue, TaskStatus.inProgress.rawValue),
            required: true
        )
    }
}

//customFailureDescription: "Allowed values for TaskStatus: (completed, failed, inProgress)."