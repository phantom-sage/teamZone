@testable import App
import XCTVapor
import Fakery

final class CreateManagerTests: XCTestCase {
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

    func testCreateManager_managerCreated_savedToDatabase() async throws {
        try await app.test(.POST, "/api/managers", beforeRequest: { req in 
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": "password"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let managerFromApi = try res.content.decode(Manager.self)
            guard let managerFromDatabase = try await Manager.query(on: app.db).first() else {
                debugPrint("Manager not created in database")
                return
            }
            XCTAssertEqual(managerFromApi.name, managerFromDatabase.name)
            XCTAssertEqual(managerFromApi.email, managerFromDatabase.email)
        })
    }

    func testCreateManager_passwordIsHashed_savedToDatabase() async throws {
        try await app.test(.POST, "/api/managers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": "password"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let managerFromApi = try res.content.decode(Manager.self)
            guard let managerFromDatabase = try await Manager.query(on: app.db).first() else {
                debugPrint("Manager not saved to database")
                return
            }

            XCTAssertNotEqual(managerFromDatabase.password, "password")
            XCTAssertEqual(managerFromApi.name, managerFromDatabase.name)
            XCTAssertEqual(managerFromApi.email, managerFromDatabase.email)
        })
    }

    func testCreateManager_emailIsValidEmailAddress_savedToDatabase() async throws {
        try await app.test(.POST, "/api/managers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": "password"
            ])
        }, afterResponse: {res async throws in
            XCTAssertEqual(res.status, .ok)
            let managersCount = try await Manager.query(on: app.db).count()
            XCTAssertEqual(1, managersCount)
        })
    }

    func testCreateManager_nameNotLessThanThreeCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/managers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": "password"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
        })
    }

    func testCreateManager_nameNotGreaterThanOneHundredCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/managers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": "password"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
        })
    }

    func testCreateManager_passwordNotLessThanEightCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/managers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
        })
    }

    func testCreateManager_passwordNotGreaterThanThirtyTwoCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/managers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.email(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
        })
    }

    func testCreateManager_emailAddressInUnique_savedToDatabase() async throws {
        try await app.test(.POST, "/api/managers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
        })
    }
}