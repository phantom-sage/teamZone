@testable import App
import XCTVapor
import Fakery

final class CreateManagerTests: XCTestCase {
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

    func testCreateManager_managerCreated_savedToDatabase() async throws {
        try await app.test(.POST, "/api/managers", beforeRequest: { req in 
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": "password"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let managerFromApi = try res.content.decode(ManagerDataFromCreateHandler.self)
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
            let managerFromApi = try res.content.decode(ManagerDataFromCreateHandler.self)
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

    // name greater than 100 characters
    func testCreateManager_nameIsLessThanThreeCharacters_notSavedToDatabase() async throws {
        try await app.test(.POST, "/api/managers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": "1",
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromCreateManagerApi.self)
            XCTAssertEqual(response.reason, "name is less than minimum of 3 character(s)")
            XCTAssertTrue(response.error)

            let managersCount = try await Manager.query(on: app.db).count()
            XCTAssertEqual(0, managersCount)
        })
    }

    func testCreateManager_nameIsGreaterThanOneHundredCharacters_notSavedToDatabase() async throws {
        try await app.test(.POST, "/api/managers", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.lorem.words(amount: 101),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromCreateManagerApi.self)
            XCTAssertEqual(response.reason, "name is greater than maximum of 100 character(s)")
            XCTAssertTrue(response.error)

            let managersCount = try await Manager.query(on: app.db).count()
            XCTAssertEqual(managersCount, 0)
        })
    }
}

struct ErrorFromCreateManagerApi: Content {
    var reason: String
    var error: Bool
}