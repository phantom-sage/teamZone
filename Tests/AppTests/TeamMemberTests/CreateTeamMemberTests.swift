@testable import App
import XCTVapor
import Fakery

final class CreateTeamMemberTests: XCTestCase {
    var app: Application!
    var faker: Faker!

    // fakeData
    var fakePassword: String!

    override func setUp() async throws {
        app = Application(.testing)
        try configure(app)
        try await app.autoRevert()
        try await app.autoMigrate()
        faker = Faker(locale: "en")

        fakePassword = faker.internet.password(minimumLength: 8, maximumLength: 32)
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    func testCreateTeamMember_savedToDatabase() async throws {
        try await app.test(.POST, "/api/teamMembers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": fakePassword
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let teamMemberFromDatabase = try await TeamMember.query(on: app.db).first() else { return }
            let teamMemberFroomApi = try res.content.decode(CreateTeamMemberDataFromApi.self)
            XCTAssertEqual(teamMemberFromDatabase.name, teamMemberFroomApi.name)
            XCTAssertEqual(teamMemberFromDatabase.email, teamMemberFroomApi.email)
            XCTAssertNotEqual(teamMemberFromDatabase.password, fakePassword)

            let teamMembersCount = try await TeamMember.query(on: app.db).count()
            XCTAssertEqual(teamMembersCount, 1)
        })
    }

    func testCreateTeamMember_passwordIsHashed_savedToDatabase() async throws {
        try await app.test(.POST, "/api/teamMembers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": fakePassword
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let teamMemberFromDatabase = try await TeamMember.query(on: app.db).first() else { return }
            let teamMemberFroomApi = try res.content.decode(CreateTeamMemberDataFromApi.self)
            XCTAssertEqual(teamMemberFromDatabase.name, teamMemberFroomApi.name)
            XCTAssertEqual(teamMemberFromDatabase.email, teamMemberFroomApi.email)
            XCTAssertNotEqual(teamMemberFromDatabase.password, fakePassword)

            let teamMembersCount = try await TeamMember.query(on: app.db).count()
            XCTAssertEqual(teamMembersCount, 1)
        })
    }

    func testCreateTeamMember_nameIsNotLessThanThreeCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/teamMembers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": fakePassword
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let teamMemberFromDatabase = try await TeamMember.query(on: app.db).first() else { return }
            let teamMemberFroomApi = try res.content.decode(CreateTeamMemberDataFromApi.self)
            XCTAssertEqual(teamMemberFromDatabase.name, teamMemberFroomApi.name)
            XCTAssertEqual(teamMemberFromDatabase.email, teamMemberFroomApi.email)
            XCTAssertNotEqual(teamMemberFromDatabase.password, fakePassword)

            let teamMembersCount = try await TeamMember.query(on: app.db).count()
            XCTAssertEqual(teamMembersCount, 1)
        })
    }

    func testCreateTeamMember_nameIsNotGreaterThanOneHundredCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/teamMembers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": fakePassword
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let teamMemberFromDatabase = try await TeamMember.query(on: app.db).first() else { return }
            let teamMemberFroomApi = try res.content.decode(CreateTeamMemberDataFromApi.self)
            XCTAssertEqual(teamMemberFromDatabase.name, teamMemberFroomApi.name)
            XCTAssertEqual(teamMemberFromDatabase.email, teamMemberFroomApi.email)
            XCTAssertNotEqual(teamMemberFromDatabase.password, fakePassword)

            let teamMembersCount = try await TeamMember.query(on: app.db).count()
            XCTAssertEqual(teamMembersCount, 1)
        })
    }

    func testCreateTeamMember_emailAddressIsValid_savedToDatabase() async throws {
        try await app.test(.POST, "/api/teamMembers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": fakePassword
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let teamMemberFromDatabase = try await TeamMember.query(on: app.db).first() else { return }
            let teamMemberFroomApi = try res.content.decode(CreateTeamMemberDataFromApi.self)
            XCTAssertEqual(teamMemberFromDatabase.name, teamMemberFroomApi.name)
            XCTAssertEqual(teamMemberFromDatabase.email, teamMemberFroomApi.email)
            XCTAssertNotEqual(teamMemberFromDatabase.password, fakePassword)

            let teamMembersCount = try await TeamMember.query(on: app.db).count()
            XCTAssertEqual(teamMembersCount, 1)
        })
    }

    func testCreateTeamMember_paswordIsNotLessThanEightCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/teamMembers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let teamMemberFromDatabase = try await TeamMember.query(on: app.db).first() else { return }
            let teamMemberFroomApi = try res.content.decode(CreateTeamMemberDataFromApi.self)
            XCTAssertEqual(teamMemberFromDatabase.name, teamMemberFroomApi.name)
            XCTAssertEqual(teamMemberFromDatabase.email, teamMemberFroomApi.email)
            XCTAssertNotEqual(teamMemberFromDatabase.password, fakePassword)

            let teamMembersCount = try await TeamMember.query(on: app.db).count()
            XCTAssertEqual(teamMembersCount, 1)
        })
    }

    func testCreateTeamMember_passwordNotGreaterThanThirtyTwoCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/teamMembers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let teamMemberFromDatabase = try await TeamMember.query(on: app.db).first() else { return }
            let teamMemberFroomApi = try res.content.decode(CreateTeamMemberDataFromApi.self)
            XCTAssertEqual(teamMemberFromDatabase.name, teamMemberFroomApi.name)
            XCTAssertEqual(teamMemberFromDatabase.email, teamMemberFroomApi.email)
            XCTAssertNotEqual(teamMemberFromDatabase.password, fakePassword)

            let teamMembersCount = try await TeamMember.query(on: app.db).count()
            XCTAssertEqual(teamMembersCount, 1)
        })
    }
}