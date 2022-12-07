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

    func testCreateHr_nameLessThanThreeCharacters_notSavedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": "1",
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromCreateHrApi.self)
            XCTAssertEqual(response.reason, "name is less than minimum of 3 character(s)")
            XCTAssertTrue(response.error)
        })
    }

    func testCreateHr_nameGreaterThanOneHundredCharacters_notSavedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.lorem.words(amount: 101),
                "email": faker.internet.safeEmail(),
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromCreateHrApi.self)
            XCTAssertEqual("name is greater than maximum of 100 character(s)", response.reason)
            XCTAssertTrue(response.error)
        })
    }

    func testCreateHr_emailIsInvalidEmailAddress_notSavedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": "invalid",
                "password": faker.internet.password(minimumLength: 8, maximumLength: 32)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromCreateHrApi.self)
            XCTAssertEqual(response.reason, "email is not a valid email address")
            XCTAssertTrue(response.error)
        })
    }

    func testCreateHr_passwordLessThanEightCharacters_notSavedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": "0123456"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromCreateHrApi.self)
            XCTAssertEqual(response.reason, "password is less than minimum of 8 character(s)")
            XCTAssertTrue(response.error)

            let hrsCount = try await Hr.query(on: app.db).count()
            XCTAssertEqual(0, hrsCount)
        })
    }

    func testCreateHr_passwordGreaterThanThirtyTwoCharacters_notSavedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail(),
                "password": faker.lorem.words(amount: 33)
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)

            let response = try res.content.decode(ErrorFromCreateHrApi.self)
            XCTAssertEqual(response.reason, "password is greater than maximum of 32 character(s)")
            XCTAssertTrue(response.error)
        })
    }

    func testCreateHr_emptyRequestBody_notSavedToDatabase() async throws {
        try await app.test(.POST, "/api/hrs", beforeRequest: { req async throws in
            try req.content.encode("".self)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .unprocessableEntity)

            let response = try res.content.decode(ErrorFromCreateHrApi.self)
            XCTAssertEqual(response.reason, "Empty Body")
            XCTAssertTrue(response.error)

            let hrsCount = try await Hr.query(on: app.db).count()
            XCTAssertEqual(0, hrsCount)
        })
    }
}

struct ErrorFromCreateHrApi: Content {
    var reason: String
    var error: Bool
}