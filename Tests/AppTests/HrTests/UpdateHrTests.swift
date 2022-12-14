@testable import App
import XCTVapor
import Fakery

final class UpdateHrTests: XCTestCase {
    var app: Application!
    var faker: Faker!
    var responseFromManagerLoginApi: ManagerLoginDataFromApi!

    override func setUp() async throws {
        app = Application(.testing)
        try configure(app)
        try await app.autoRevert()
        try await app.autoMigrate()
        faker = Faker(locale: "en")

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

            responseFromManagerLoginApi = response
        })
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
            req.headers.add(name: .authorization, value: "Bearer \(responseFromManagerLoginApi.token)")
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
            req.headers.add(name: .authorization, value: "Bearer \(responseFromManagerLoginApi.token)")
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
            req.headers.add(name: .authorization, value: "Bearer \(responseFromManagerLoginApi.token)")
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
            req.headers.add(name: .authorization, value: "Bearer \(responseFromManagerLoginApi.token)")
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
            req.headers.add(name: .authorization, value: "Bearer \(responseFromManagerLoginApi.token)")
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
            req.headers.add(name: .authorization, value: "Bearer \(responseFromManagerLoginApi.token)")
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

    func testUpdateHr_notFoundInDatabase_notFoundError() async throws {
        let randomId = faker.number.randomInt()
        try await app.test(.PUT, "/api/hrs/\(randomId)", beforeRequest: { req async throws in
            req.headers.add(name: .authorization, value: "Bearer \(responseFromManagerLoginApi.token)")
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)

            let hrCount = try await Hr.query(on: app.db).count()
            XCTAssertEqual(0, hrCount)
        })
    }
}