@testable import App
import XCTVapor
import Fakery

final class LoginManagerTests: XCTestCase {
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

    func testLoginManager_getTokenFromApi() async throws {
        try await Manager.createManager(on: app.db)
        guard let manager = try await Manager.query(on: app.db).first() else { return }

        try await app.test(.POST, "/api/managers/login", beforeRequest: { req async throws in
            try req.content.encode([
                "email": manager.email,
                "password": manager.password
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            
            let response = try res.content.decode(ManagerLoginDataFromApi.self)
            XCTAssertFalse(response.token.isEmpty)

            let managersCount = try await Manager.query(on: app.db).count()
            XCTAssertEqual(managersCount, 1)
        })
    }

    func testLoginManager_emailNotFoundInDatabase_noTokenReturned() async throws {
        try await app.test(.POST, "/api/managers/login", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": "notFound@email.com",
                "password": faker.internet.password()
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)

            let response = try res.content.decode(ErrorFromManagerLoginApi.self)
            XCTAssertEqual(response.reason, "Manager with this Email-Address: notFound@email.com not found.")
            XCTAssertTrue(response.error)

            let managersCount = try await Manager.query(on: app.db).count()
            XCTAssertEqual(managersCount, 0)
        })
    }

    func testLoginManager_emailIsInValidEmailAddress_noTokenReturned() async throws {
        try await app.test(.POST, "/api/managers/login", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": "invalid",
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromManagerLoginApi.self)
            XCTAssertEqual(response.reason, "email is not a valid email address")
            XCTAssertTrue(response.error)

            let managersCount = try await Manager.query(on: app.db).count()
            XCTAssertEqual(managersCount, 0)
        })
    }

    func testLoginManager_passwordIsLessThanEightCharacters_noTokenReturned() async throws {
        try await app.test(.POST, "/api/managers/login", beforeRequest: { req async throws in
            try req.content.encode([
                "email": faker.internet.safeEmail(),
                "password": "0123456"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromManagerLoginApi.self)
            XCTAssertEqual(response.reason, "password is less than minimum of 8 character(s)")
            XCTAssertTrue(response.error)

            let managersCount = try await Manager.query(on: app.db).count()
            XCTAssertEqual(managersCount, 0)
        })
    }

    func testLoginManager_passwordIsGreaterThanThirtyTwoCharacters_noTokenReturned() async throws {
        try await app.test(.POST, "/api/managers/login", beforeRequest: { req async throws in
            try req.content.encode([
                "email": faker.internet.safeEmail(),
                "password": String(repeating: "p", count: 33)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromManagerLoginApi.self)
            XCTAssertEqual(response.reason, "password is greater than maximum of 32 character(s)")
            XCTAssertTrue(response.error)

            let managersCount = try await Manager.query(on: app.db).count()
            XCTAssertEqual(managersCount, 0)
        })
    }

}

struct ManagerLoginDataFromApi: Content {
    var token: String
}

struct ErrorFromManagerLoginApi: Content {
    var reason: String
    var error: Bool
}