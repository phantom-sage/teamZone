@testable import App
import Fakery
import XCTVapor

final class CreateProjectTests: XCTestCase {
    private var app: Application!
    private var faker: Faker!

    private let deadlineAsString = "2022-12-31 14:29:00"

    override func setUp() async throws {
        app = Application(.testing)
        try configure(app)
        try await app.autoRevert()
        try await app.autoMigrate()
        faker = Faker(locale: "en")
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    func testCreateProject_nameNotLessThanThreeCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/projects", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "deadline": deadlineAsString
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            let projectFromApi = try res.content.decode(Project.self)
            guard let projectFromDatabase = try await Project.query(on: app.db).first() else { return }

            XCTAssertEqual(projectFromApi.name, projectFromDatabase.name)
            XCTAssertEqual(projectFromApi.deadline, projectFromDatabase.deadline)

            let projectsCount = try await Project.query(on: app.db).count()
            XCTAssertEqual(projectsCount, 1)
        })
    }

    func testCreateProject_nameNotGreaterThanOneHundredCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/projects", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "deadline": deadlineAsString
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            let projectFromApi = try res.content.decode(Project.self)
            guard let projectFromDatabase = try await Project.query(on: app.db).first() else { return }

            XCTAssertEqual(projectFromApi.name, projectFromDatabase.name)
            XCTAssertEqual(projectFromApi.deadline, projectFromDatabase.deadline)

            let projectsCount = try await Project.query(on: app.db).count()
            XCTAssertEqual(projectsCount, 1)
        })
    }
}