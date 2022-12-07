@testable import App
import XCTVapor
import Fakery

final class DeleteHrTests: XCTestCase {
    var app: Application!
    var faker: Faker!

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

    func testDeleteHr_deletedFromDatabase() async throws {
        try await Hr.createHr(on: app.db)
        guard let hr = try await Hr.query(on: app.db).first() else { return }
        try await app.test(.DELETE, "/api/hrs/\(hr.id!)", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .noContent)

            let hrCounts = try await Hr.query(on: app.db).count()
            XCTAssertEqual(0, hrCounts)
        })
    }

    func testDeleteHr_notFoundInDatabase_notFoundError() async throws {
        let randomId = faker.number.randomInt()
        try await app.test(.DELETE, "/api/hrs/\(randomId)", afterResponse: { res async throws in
        XCTAssertEqual(res.status, .notFound)
            let response = try res.content.decode(ErrorFromDeleteHrApi.self)
            XCTAssertEqual(response.reason, "Hr with this id: \(randomId) not found")
            XCTAssertTrue(response.error)

            let hrCounts = try await Hr.query(on: app.db).count()
            XCTAssertEqual(0, hrCounts)
        })
    }
}
struct ErrorFromDeleteHrApi: Content {
    var error: Bool
    var reason: String
}