@testable import App
import XCTVapor
import Fakery

final class CreateTaskTests: XCTestCase {
    private var app: Application!
    private var faker: Faker!

    private let deadlineAsString = "2022-12-31 14:29:00"

    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        try app.autoRevert().wait()
        try app.autoMigrate().wait()
        faker = Faker(locale: "en")
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    func testCreateTask_savedToDatabase() async throws {
        try await app.test(.POST, "/api/tasks", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "status": TaskStatus.completed.rawValue,
                "duration": "2022-12-05 12:00:00"
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
        })
    }

    func testCreateTask_nameNotLessThanThreeCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/tasks", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "status": TaskStatus.completed.rawValue,
                "duration": deadlineAsString
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
                "duration": deadlineAsString
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
                "duration": deadlineAsString
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
                "status": TaskStatus.completed.rawValue
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
}