@testable import App
import XCTVapor
import Fakery

final class DeleteTeamMemberTests: XCTestCase {
    var app: Application!
    var faker: Faker!

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

    func testDeleteTeamMember_deletedFromDatabase() async throws {
        try await TeamMember.createTeamMember(on: app.db)
        guard let teamMember = try await TeamMember.query(on: app.db).first() else { return }
        try await app.test(.DELETE, "/api/teamMembers/\(teamMember.id!)", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .noContent)

            let teamMembersCount = try await TeamMember.query(on: app.db).count()
            XCTAssertEqual(teamMembersCount, 0)
        })
    }

    func testDeleteTeamMember_notFoundInDatabase() async throws {
        try await app.test(.DELETE, "/api/teamMembers/not-found", afterResponse: { res async throws in
            let response = try res.content.decode(ErrorFromDeleteTeamMemberApi.self)
            XCTAssertEqual(response.reason, "Team Member with this id: not-found not exists.")
            XCTAssertTrue(response.error)
        })
    }
}

struct ErrorFromDeleteTeamMemberApi: Content {
    var reason: String
    var error: Bool
}