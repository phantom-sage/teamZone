@testable import App
import XCTVapor
import Fakery

final class UpdateTeamMemberTests: XCTestCase {
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

    func testUpdateTeamMember_updateDatabase() async throws {
        try await TeamMember.createTeamMember(on: app.db)
        guard let teamMember = try await TeamMember.query(on: app.db).first() else { return }
        
        try await app.test(.PUT, "/api/teamMembers/\(teamMember.id!)", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail()
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let teamMemberFromDatabase = try await TeamMember.query(on: app.db).first() else { return }
            let teamMemberFromApi = try res.content.decode(UpdateTeamMemberDataFromApi.self)

            XCTAssertEqual(teamMemberFromDatabase.name, teamMemberFromApi.name)
            XCTAssertEqual(teamMemberFromDatabase.email, teamMemberFromApi.email)

            let teamMembersCount = try await TeamMember.query(on: app.db).count()
            XCTAssertEqual(teamMembersCount, 1)
        })
    }

    func testUpdateTeamMember_emailAddressIsValid_updateDatabase() async throws {
        try await TeamMember.createTeamMember(on: app.db)
        guard let teamMember = try await TeamMember.query(on: app.db).first() else { return }
        try await app.test(.PUT, "/api/teamMembers/\(teamMember.id!)", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail()
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            let teamMemberFromApi = try res.content.decode(UpdateTeamMemberDataFromApi.self)
            guard let teamMemberFromDatabase = try await TeamMember.query(on: app.db).first() else { return }
            XCTAssertEqual(teamMemberFromApi.name, teamMemberFromDatabase.name)
            XCTAssertEqual(teamMemberFromApi.email, teamMemberFromDatabase.email)

            let teamMembersCount = try await TeamMember.query(on: app.db).count()
            XCTAssertEqual(teamMembersCount, 1)
        })
    }

    func testUpdateTeamMember_notFoundInDatabase() async throws {
        try await app.test(.PUT, "/api/teamMembers/not-found", afterResponse: { res async throws in
            let response = try res.content.decode(ErrorFromApi.self)
            XCTAssertEqual(response.reason, "Team Member with this id: not-found not exists.")
            XCTAssertTrue(response.error)

            let teamMembersCount = try await TeamMember.query(on: app.db).count()
            XCTAssertEqual(teamMembersCount, 0)
        })
    }

    func testUpdateTeamMember_nameNotLessThanThreeCharacters_updateDatabase() async throws {
        try await TeamMember.createTeamMember(on: app.db)
        guard let teamMember = try await TeamMember.query(on: app.db).first() else { return }
        try await app.test(.PUT, "/api/teamMembers/\(teamMember.id!)", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail()
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let teamMemberFromDatabase = try await TeamMember.query(on: app.db).first() else { return }
            let teamMemberFromApi = try res.content.decode(UpdateTeamMemberDataFromApi.self)

            XCTAssertEqual(teamMemberFromDatabase.name, teamMemberFromApi.name)
            XCTAssertEqual(teamMemberFromDatabase.email, teamMemberFromApi.email)

            let teamMembersCount = try await TeamMember.query(on: app.db).count()
            XCTAssertEqual(teamMembersCount, 1)
        })
    }

    func testUpdateTeamMember_nameNotGreaterThanThirtyTwo_updateDatabase() async throws {
        try await TeamMember.createTeamMember(on: app.db)
        guard let teamMember = try await TeamMember.query(on: app.db).first() else { return }
        try await app.test(.PUT, "/api/teamMembers/\(teamMember.id!)", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail()
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let teamMemberFromDatabase = try await TeamMember.query(on: app.db).first() else { return }
            let teamMemberFromApi = try res.content.decode(UpdateTeamMemberDataFromApi.self)

            XCTAssertEqual(teamMemberFromDatabase.name, teamMemberFromApi.name)
            XCTAssertEqual(teamMemberFromDatabase.email, teamMemberFromApi.email)

            let teamMembersCount = try await TeamMember.query(on: app.db).count()
            XCTAssertEqual(teamMembersCount, 1)
        })
    }
}

struct ErrorFromApi: Content {
    var reason: String
    var error: Bool
}