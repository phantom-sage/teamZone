import Vapor
import Fluent

struct TasksController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let tasksRoute = routes.grouped("api", "tasks")
        tasksRoute.post(use: createHandler)
    }

    func createHandler(_ req: Request) async throws -> TaskDataFromCreateHandler {
        try TaskDataFromCreateHandler.validate(content: req)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 7200)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)


        let taskData = try req.content.decode(TaskDataFromCreateHandler.self, using: decoder)
        guard let _ = try await Project.find(taskData.projectId, on: req.db) else {
            throw Abort(.notFound, reason: "Project with this id: \(taskData.projectId) not exists.")
        }
        let task = Task()
        task.name = taskData.name
        task.status = taskData.status
        task.duration = taskData.duration
        task.$project.id = taskData.projectId
        try await task.save(on: req.db)

        return TaskDataFromCreateHandler(
            name: task.name,
            status: task.status,
            duration: task.duration,
            projectId: taskData.projectId
        )
    }
}