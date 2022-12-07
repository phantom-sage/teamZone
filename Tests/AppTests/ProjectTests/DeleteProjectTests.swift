@testable import App
import XCTVapor
import Fakery

final class DeleteProjectTests: XCTestCase {
    private var app: Application!
    private var faker: Faker!
    private let dateAsString = "2022-12-31 14:29:00"

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

    func testDeleteProject_deletedFromDatabase() async throws {
        try await Project.createProject(on: app.db)
        guard let project = try await Project.query(on: app.db).first() else { return }

        try await app.test(.DELETE, "/api/projects/\(project.id!)", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .noContent)

            let projectsCount = try await Project.query(on: app.db).count()
            XCTAssertEqual(projectsCount, 0)
        })
    }

    func testDeleteProject_notFoundInDatabase() async throws {
        try await app.test(.DELETE, "/api/projects/not-found", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)
            let response = try res.content.decode(ErrorFromDeleteProjectApi.self)
            XCTAssertEqual(response.reason, "Project with this id: not-found not found.")
            XCTAssertTrue(response.error)
        })
    }
}

struct ErrorFromDeleteProjectApi: Content {
    var reason: String
    var error: Bool
}