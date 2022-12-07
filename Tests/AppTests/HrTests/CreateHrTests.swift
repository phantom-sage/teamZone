@testable import App
import XCTVapor
import Fakery

final class CreateHrTests: XCTestCase {
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

    func testCreateHr_withAllFields_savedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.email(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let hrFromDatabase = try await Hr.query(on: app.db).first() else { return }
            let hrDataFromApi = try res.content.decode(HrResponse.self)
            XCTAssertEqual(hrFromDatabase.name, hrDataFromApi.name)
            XCTAssertEqual(hrFromDatabase.email, hrDataFromApi.email)
        })
    }

    func testCreateHr_emailIsRequired_savedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password()
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let hrFromDatabase = try await Hr.query(on: app.db).first() else { return }
            let hrDataFromApi = try res.content.decode(HrResponse.self)
            XCTAssertEqual(hrFromDatabase.name, hrDataFromApi.name)
            XCTAssertEqual(hrFromDatabase.email, hrDataFromApi.email)
        })
    }

    func testCreateHr_emailIsValid_savedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let hrFromDatabase = try await Hr.query(on: app.db).first() else { return }
            let hrDataFromApi = try res.content.decode(HrResponse.self)
            XCTAssertEqual(hrFromDatabase.name, hrDataFromApi.name)
            XCTAssertEqual(hrFromDatabase.email, hrDataFromApi.email)
        })
    }

    func testCreateHr_nameIsNotLessThanThreeCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let hrFromDatabase = try await Hr.query(on: app.db).first() else { return }
            let hrDataFromApi = try res.content.decode(HrResponse.self)
            XCTAssertEqual(hrFromDatabase.name, hrDataFromApi.name)
            XCTAssertEqual(hrFromDatabase.email, hrDataFromApi.email)
        })
    }

    func testCreateHr_nameIsNotGreaterThanOneHundredCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let hrFromDatabase = try await Hr.query(on: app.db).first() else { return }
            let hrDataFromApi = try res.content.decode(HrResponse.self)
            XCTAssertEqual(hrFromDatabase.name, hrDataFromApi.name)
            XCTAssertEqual(hrFromDatabase.email, hrDataFromApi.email)
        })
    }

    func testCreateHr_nameIsRequired_savedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let hrFromDatabase = try await Hr.query(on: app.db).first() else { return }
            let hrDataFromApi = try res.content.decode(HrResponse.self)
            XCTAssertEqual(hrFromDatabase.name, hrDataFromApi.name)
            XCTAssertEqual(hrFromDatabase.email, hrDataFromApi.email)
        })
    }

    func testCreateHr_passwordIsRequired_savedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let hrFromDatabase = try await Hr.query(on: app.db).first() else { return }
            let hrDataFromApi = try res.content.decode(HrResponse.self)
            XCTAssertEqual(hrFromDatabase.name, hrDataFromApi.name)
            XCTAssertEqual(hrFromDatabase.email, hrDataFromApi.email)
        })
    }

    func testCreateHr_passwordNotLessThanEightCharacters_savedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let hrFromDatabase = try await Hr.query(on: app.db).first() else { return }
            let hrDataFromApi = try res.content.decode(HrResponse.self)
            XCTAssertEqual(hrFromDatabase.name, hrDataFromApi.name)
            XCTAssertEqual(hrFromDatabase.email, hrDataFromApi.email)
        })
    }

    func testCreateHr_passwordNotGreaterThanThirtyTwoCharacters_savedtoDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.safeEmail()
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let hrFromDatabase = try await Hr.query(on: app.db).first() else { return }
            let hrDataFromApi = try res.content.decode(HrResponse.self)
            XCTAssertEqual(hrFromDatabase.name, hrDataFromApi.name)
            XCTAssertEqual(hrFromDatabase.email, hrDataFromApi.email)
        })
    }

    func testCreateHr_passwordIsHashed_savedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": "password"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            guard let hrFromDatabase = try await Hr.query(on: app.db).first() else { return }
            let hrDataFromApi = try res.content.decode(HrResponse.self)
            XCTAssertEqual(hrFromDatabase.name, hrDataFromApi.name)
            XCTAssertEqual(hrFromDatabase.email, hrDataFromApi.email)
            XCTAssertNotEqual(hrFromDatabase.password, "password")
        })
    }
}