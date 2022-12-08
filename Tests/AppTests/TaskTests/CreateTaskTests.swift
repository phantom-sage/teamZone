@testable import App
import XCTVapor
import Fakery

final class CreateTaskTests: XCTestCase {
    private var app: Application!
    private var faker: Faker!
    private var project: Project!

    private let deadlineAsString = "2022-12-31 14:29:00"

    override func setUp() async throws {
        app = Application(.testing)
        try configure(app)
        try await app.autoRevert()
        try await app.autoMigrate()
        faker = Faker(locale: "en")

        try await Project.createProject(on: app.db)
        project = try await Project.query(on: app.db).first()
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    func testCreateTask_savedToDatabase() async throws {
        try await app.test(.POST, "/api/tasks", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "status": TaskStatus.completed.rawValue,
                "duration": "2022-12-05 12:00:00",
                "projectId": "\(project.id!)"
            ].self)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let tasksCount = try await Task.query(on: app.db).count()
            XCTAssertEqual(tasksCount, 1)

            let taskFromApi = try res.content.decode(TaskDataFromCreateHandler.self)
            guard let taskFromDatabase = try await Task.query(on: app.db).first() else { return }
            XCTAssertEqual(taskFromApi.name, taskFromDatabase.name)
            XCTAssertEqual(taskFromApi.duration, taskFromDatabase.duration)
            XCTAssertEqual(taskFromApi.status, taskFromDatabase.status)
            XCTAssertEqual(taskFromDatabase.$project.id, project.id)
        })
    }

    func testCreateTask_nameNotLessThanThreeCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/tasks", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "status": TaskStatus.completed.rawValue,
                "duration": deadlineAsString,
                "projectId": "\(project.id!)"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let tasksCount = try await Task.query(on: app.db).count()
            XCTAssertEqual(tasksCount, 1)

            let taskFromApi = try res.content.decode(TaskDataFromCreateHandler.self)
            guard let taskFromDatabase = try await Task.query(on: app.db).first() else { return }
            XCTAssertEqual(taskFromApi.name, taskFromDatabase.name)
            XCTAssertEqual(taskFromApi.duration, taskFromDatabase.duration)
            XCTAssertEqual(taskFromApi.status, taskFromDatabase.status)
        })
    }

    func testCreateTask_nameNotGreaterThanOneHundredFivityCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/tasks", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "status": TaskStatus.completed.rawValue,
                "duration": deadlineAsString,
                "projectId": "\(project.id!)"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let tasksCount = try await Task.query(on: app.db).count()
            XCTAssertEqual(tasksCount, 1)

            let taskFromApi = try res.content.decode(TaskDataFromCreateHandler.self)
            guard let taskFromDatabase = try await Task.query(on: app.db).first() else { return }
            XCTAssertEqual(taskFromApi.name, taskFromDatabase.name)
            XCTAssertEqual(taskFromApi.duration, taskFromDatabase.duration)
            XCTAssertEqual(taskFromApi.status, taskFromDatabase.status)
        })
    }

    func testCreateTask_durationIsValidDatatime_savedToDatabase() async throws {
        try await app.test(.POST, "/api/tasks", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "status": TaskStatus.completed.rawValue,
                "duration": deadlineAsString,
                "projectId": "\(project.id!)"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let tasksCount = try await Task.query(on: app.db).count()
            XCTAssertEqual(tasksCount, 1)

            let taskFromApi = try res.content.decode(TaskDataFromCreateHandler.self)
            guard let taskFromDatabase = try await Task.query(on: app.db).first() else { return }
            XCTAssertEqual(taskFromApi.name, taskFromDatabase.name)
            XCTAssertEqual(taskFromApi.duration, taskFromDatabase.duration)
            XCTAssertEqual(taskFromApi.status, taskFromDatabase.status)
        })
    }

    func testCreateTask_taskStatusIsValidTaskStatus_savedToDatabase() async throws {
        try await app.test(.POST, "/api/tasks", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "duration": deadlineAsString,
                "status": TaskStatus.completed.rawValue,
                "projectId": "\(project.id!)"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let tasksCount = try await Task.query(on: app.db).count()
            XCTAssertEqual(tasksCount, 1)

            let taskFromApi = try res.content.decode(TaskDataFromCreateHandler.self)
            guard let taskFromDatabase = try await Task.query(on: app.db).first() else { return }
            XCTAssertEqual(taskFromApi.name, taskFromDatabase.name)
            XCTAssertEqual(taskFromApi.duration, taskFromDatabase.duration)
            XCTAssertEqual(taskFromApi.status, taskFromDatabase.status)
        })
    }

    func testCreateTask_taskNameLessThanThreeCharacters_notSavedToDatabase() async throws {
        try await app.test(.POST, "/api/tasks", beforeRequest: { req async throws in
            try req.content.encode([
                "name": "1",
                "duration": deadlineAsString,
                "status": TaskStatus.completed.rawValue,
                "projectId": "\(project.id!)"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromCreateTaskApi.self)
            XCTAssertEqual(response.reason, "name is less than minimum of 3 character(s)")
            XCTAssertTrue(response.error)

            let tasksCount = try await Task.query(on: app.db).count()
            XCTAssertEqual(0, tasksCount)
        })
    }

    func testCreateTask_taskNameNotGreaterThanOneHundredFivityCharacters_notSavedToDatabase() async throws {
        try await app.test(.POST, "/api/tasks", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.lorem.words(amount: 200),
                "status": TaskStatus.completed.rawValue,
                "duration": deadlineAsString,
                "projectId": "\(project.id!)"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromCreateTaskApi.self)
            XCTAssertEqual(response.reason, "name is greater than maximum of 150 character(s)")
            XCTAssertTrue(response.error)
        })
    }

    func testCreateTask_incorrectTaskStatus_notSavedToDatabase() async throws {
        try await app.test(.POST, "/api/tasks", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "duration": deadlineAsString,
                "projectId": "\(project.id!)",
                "status": "invalid"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromCreateTaskApi.self)
            XCTAssertEqual(response.reason, "status is not completed, failed, or inProgress")
            XCTAssertTrue(response.error)
        })
    }

    func testCreateTask_incorrectDurationDate_notSavedToDatabase() async throws {
        try await app.test(.POST, "/api/tasks", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "status": TaskStatus.completed.rawValue,
                "projectId": "\(project.id!)",
                "duration": "invalid"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromCreateTaskApi.self)
            XCTAssertEqual(response.reason, "Date string does not match format expected by formatter. for key duration")
            XCTAssertTrue(response.error)
        })
    }

    func testCreateTask_emptyRequestBody_notSavedToDatabase() async throws  {
        try await app.test(.POST, "/api/tasks", beforeRequest: { req async throws in
            try req.content.encode("")
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .unprocessableEntity)

            let response = try res.content.decode(ErrorFromCreateTaskApi.self)
            XCTAssertEqual(response.reason, "Empty Body")
            XCTAssertTrue(response.error)
        })
    }

    func testCreateTask_projectIdNotExistsInDatabase_notSavedToDatabase() async throws {
        try await app.test(.POST, "/api/tasks", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "duration": deadlineAsString,
                "status": TaskStatus.completed.rawValue,
                "projectId": "12CB067F-B7BA-48D8-ACD9-69AA6DD03770"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)

            let response = try res.content.decode(ErrorFromCreateTaskApi.self)
            XCTAssertEqual(response.reason, "Project with this id: 12CB067F-B7BA-48D8-ACD9-69AA6DD03770 not exists.")
            XCTAssertTrue(response.error)
        })
    }
}

struct ErrorFromCreateTaskApi: Content {
    var reason: String
    var error: Bool
}