@testable import App
import XCTVapor
import Fakery

final class UpdateHrTests: XCTestCase {
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

    func testUpdateHr_updateDatabase() async throws {
        let hr = Hr()
        hr.name = faker.name.name()
        hr.email = faker.internet.safeEmail()
        hr.password = faker.internet.password(minimumLength: 8, maximumLength: 32)
        try await hr.save(on: app.db)
        try await app.test(.PUT, "/api/hrs/\(hr.id!)", beforeRequest: {req async throws in
            try req.content.encode([
                "name": "updated name",
                "email": "updatedEmail@email.com",
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let hrFromDatabase = try await Hr.query(on: app.db).first()
            let hrFromApi = try res.content.decode(Hr.self)
            XCTAssertEqual(hrFromDatabase?.name, hrFromApi.name)
            XCTAssertEqual(hrFromDatabase?.email, hrFromApi.email)
            XCTAssertNotEqual("password", hrFromDatabase?.password)
            
            let hrCount = try await Hr.query(on: app.db).count()
            XCTAssertEqual(1, hrCount)
        })
    }

    func testUpdateHr_nameNotLessThanThreeCharacters_updateDatabase() async throws {
        try await Hr.createHr(on: app.db)
        guard let hr = try await Hr.query(on: app.db).first() else {
            return
        }

        try await app.test(.PUT, "/api/hrs/\(hr.id!)", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail()
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            
            let hrFromApi = try res.content.decode(Hr.self)
            let hrFromDatabase = try await Hr.query(on: app.db).first()
            XCTAssertEqual(hrFromDatabase?.name, hrFromApi.name)
            XCTAssertEqual(hrFromDatabase?.email, hrFromApi.email)
            XCTAssertNotEqual("password", hrFromDatabase?.password)
            
            let hrCount = try await Hr.query(on: app.db).count()
            XCTAssertEqual(1, hrCount)
        })
    }

    func testUpdateHr_nameNotGreaterThanOneHundredCharacters_updateDatabase() async throws {
        try await Hr.createHr(on: app.db)
        guard let hr = try await Hr.query(on: app.db).first() else {
            return
        }

        try await app.test(.PUT, "/api/hrs/\(hr.id!)", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail()
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            let hrFromApi = try res.content.decode(Hr.self)
            let hrFromDatabase = try await Hr.query(on: app.db).first()
            XCTAssertEqual(hrFromDatabase?.name, hrFromApi.name)
            XCTAssertEqual(hrFromDatabase?.email, hrFromApi.email)
            XCTAssertNotEqual("password", hrFromDatabase?.password)
            
            let hrCount = try await Hr.query(on: app.db).count()
            XCTAssertEqual(1, hrCount)
        })
    }

    func testUpdateHr_nameIsRequired_updateDatabase() async throws {
        try await Hr.createHr(on: app.db)
        guard let hr = try await Hr.query(on: app.db).first() else {
            return
        }

        try await app.test(.PUT, "/api/hrs/\(hr.id!)", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail()
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
        })
    }

    func testUpdateHr_emailIsRequired_updateDatabase() async throws {
        try await Hr.createHr(on: app.db)
        guard let hr = try await Hr.query(on: app.db).first() else {
            return
        }

        try await app.test(.PUT, "/api/hrs/\(hr.id!)", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail()
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            let hrFromApi = try res.content.decode(Hr.self)
            let hrFromDatabase = try await Hr.query(on: app.db).first()
            XCTAssertEqual(hrFromDatabase?.name, hrFromApi.name)
            XCTAssertEqual(hrFromDatabase?.email, hrFromApi.email)
            XCTAssertNotEqual("password", hrFromDatabase?.password)
            
            let hrCount = try await Hr.query(on: app.db).count()
            XCTAssertEqual(1, hrCount)
        })
    }

    func testUpdateHr_emailIsValidEmailAddress_updateDatabase() async throws {
        try await Hr.createHr(on: app.db)
        guard let hr = try await Hr.query(on: app.db).first() else {
            return
        }

        try await app.test(.PUT, "/api/hrs/\(hr.id!)", beforeRequest: { req async throws in
            try req.content.encode([
                "name": faker.name.name(),
                "email": faker.internet.safeEmail()
            ])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)

            let hrFromApi = try res.content.decode(Hr.self)
            let hrFromDatabase = try await Hr.query(on: app.db).first()
            XCTAssertEqual(hrFromDatabase?.name, hrFromApi.name)
            XCTAssertEqual(hrFromDatabase?.email, hrFromApi.email)
            XCTAssertNotEqual("password", hrFromDatabase?.password)
            
            let hrCount = try await Hr.query(on: app.db).count()
            XCTAssertEqual(1, hrCount)
        })
    }
}