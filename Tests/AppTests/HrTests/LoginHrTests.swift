@testable import App
import XCTVapor
import Fakery

final class LoginHrTests: XCTestCase {
    var app: Application!
    var faker: Faker!
    var hr: Hr!

    override func setUp() async throws {
        app = Application(.testing)
        try configure(app)
        try await app.autoRevert()
        try await app.autoMigrate()
        faker = Faker(locale: "en")

        hr = Hr()
        hr.name = faker.name.name()
        hr.email = faker.internet.safeEmail()
        hr.password = try await app.password.async.hash("password")
        try await hr.save(on: app.db)
    }

    override func tearDown() async throws {
        app.shutdown()
    }

    func testLoginHr_tokenReturnedFromApi() async throws {
        try await app.test(.POST, "/api/hrs/login", beforeRequest: { req async throws in
            try req.content.encode([
                "email": hr.email,
                "password": "password"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            let response = try res.content.decode(JWTTokenResponseFromLoginHrApi.self)
            XCTAssertFalse(response.token.isEmpty)
        })
    }

    func testLoginHr_emailIsCorrectButPasswordIsIncorrect_noTokenReturned() async throws {
        try await app.test(.POST, "/api/hrs/login", beforeRequest: { req async throws in
            try req.content.encode([
                "email": hr.email,
                "password": "Incorrect"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func testLoginHr_emailIsIncorrectButPasswordIsCorrect_noTokenReturned() async throws {
        try await app.test(.POST, "/api/hrs/login", beforeRequest: { req async throws in
            try req.content.encode([
                "email": faker.internet.safeEmail(),
                "password": "password"
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)
        })
    }
}

struct JWTTokenResponseFromLoginHrApi: Content {
    var token: String
}