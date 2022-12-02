@testable import App
import XCTVapor
import Fakery

final class UpdateProjectTests: XCTestCase {
    private var app: Application!
    private var faker: Faker!
    private let dateAsString = "2022-12-31 14:29:00"

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

    func testUpdateProject_nameNotLessThanThreeCharacters_updatedDatabase() async throws {
        try await Project.createProject(on: app.db)
        guard let project = try await Project.query(on: app.db).first() else { return }
        try await app.test(.PUT, "/api/projects/\(project.id!)", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "deadline": dateAsString
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            let projectFromApi = try res.content.decode(UpdateProjectDataFromApi.self)
            let projectFromDatabase = try await Project.query(on: app.db).first()
            XCTAssertEqual(projectFromApi.name, projectFromDatabase?.name)
            XCTAssertEqual(projectFromApi.deadline, projectFromDatabase?.deadline)

            let projectsCount = try await Project.query(on: app.db).count()
            XCTAssertEqual(1, projectsCount)
        })
    }

    func testUpdateProject_nameNotGreaterThanOneHundredCharacters_updateDatabase() async throws {
        try await Project.createProject(on: app.db)
        guard let project = try await Project.query(on: app.db).first() else { return }
        try await app.test(.PUT, "/api/projects/\(project.id!)", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "deadline": dateAsString
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            let projectFromApi = try res.content.decode(UpdateProjectDataFromApi.self)
            let projectFromDatabase = try await Project.query(on: app.db).first()
            XCTAssertEqual(projectFromApi.name, projectFromDatabase?.name)
            XCTAssertEqual(projectFromApi.deadline, projectFromDatabase?.deadline)

            let projectsCount = try await Project.query(on: app.db).count()
            XCTAssertEqual(1, projectsCount)
        })
    }

    func testUpdateProject_deadlineIsInCorrectFormat_updateDatabase() async throws {
        try await Project.createProject(on: app.db)
        guard let project = try await Project.query(on: app.db).first() else { return }
        try await app.test(.PUT, "/api/projects/\(project.id!)", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "deadline": dateAsString
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            let projectFromApi = try res.content.decode(UpdateProjectDataFromApi.self)
            let projectFromDatabase = try await Project.query(on: app.db).first()
            XCTAssertEqual(projectFromApi.name, projectFromDatabase?.name)
            XCTAssertEqual(projectFromApi.deadline, projectFromDatabase?.deadline)

            let projectsCount = try await Project.query(on: app.db).count()
            XCTAssertEqual(1, projectsCount)
        })
    }
}