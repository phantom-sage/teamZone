@testable import App
import XCTVapor


struct ErrorFromCreateClientApi: Content {
    var reason: String
    var error: Bool
}

final class CreateClientTests: XCTestCase {
    var app: Application!

    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        try app.autoRevert().wait()
        try app.autoMigrate().wait()
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    func testCreateClientWithValidData_clientCreated() async throws {
        try await app.test(.POST, "/api/clients", beforeRequest: { req in
            try req.content.encode(["username": "Client username", "email": "email@email.com"])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let client = try res.content.decode(Client.self)
            XCTAssertEqual(client.username, "Client username")
            XCTAssertEqual(client.email, "email@email.com")
            let allClients = try await Client.query(on: app.db).all()
            XCTAssertEqual(allClients.count, 1)
        })
    }

    func testCreateClientWithoutUsernameProvided_clientNotCreated_validationError() async throws {
        try await app.test(.POST, "/api/clients", beforeRequest: { req in
            try req.content.encode(["email": "email@email.com"])
        }, afterResponse: { res async throws in
            let response = try res.content.decode(ErrorFromCreateClientApi.self)
            XCTAssertEqual(response.reason, "username is required")
            XCTAssertTrue(response.error)
            XCTAssertEqual(res.status, .badRequest)
            let allClients = try await Client.query(on: app.db).all()
            XCTAssertEqual(allClients.count, 0)
        })
    }

    func testCreateClientWithoutEmailAddressProvided_clientNotCreated_validationError() async throws {
        try await app.test(.POST, "/api/clients", beforeRequest: { req in
            try req.content.encode(["username": "Client username"])
        }, afterResponse: { res async throws in
            let response = try res.content.decode(ErrorFromCreateClientApi.self)
            XCTAssertEqual(response.reason, "email is required")
            XCTAssertTrue(response.error)
            XCTAssertEqual(res.status, .badRequest)
            let allClients = try await Client.query(on: app.db).all()
            XCTAssertEqual(allClients.count, 0)
        })
    }

    func testCreateClientWithInvalidEmailAddress_clientNotCreated_validationError() async throws {
        try await app.test(.POST, "/api/clients", beforeRequest: { req in
            try req.content.encode(["username": "Client username", "email": "invalid email address"])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)
            let response = try res.content.decode(ErrorFromCreateClientApi.self)
            XCTAssertEqual(response.reason, "email is not a valid email address")
            let allClients = try await Client.query(on: app.db).all()
            XCTAssertEqual(allClients.count, 0)
        })
    }

    func testCreateClientWithTooLongUsername_clientNotCreated_validationError() async throws {
        try await app.test(.POST, "/api/clients", beforeRequest: { req in
            try req.content.encode(["username": String(repeating: "too long username", count: 5000), "email": "email@email.com"])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)
            let response = try res.content.decode(ErrorFromCreateClientApi.self)
            XCTAssertEqual(response.reason, "username is greater than maximum of 100 character(s)")
            let allClients = try await Client.query(on: app.db).all()
            XCTAssertEqual(allClients.count, 0)
        })
    }

    func testCreateClientWithTooLongEmailAddress_clientNotCreated_validationError() async throws {
        try await app.test(.POST, "/api/clients", beforeRequest: { req in
            try req.content.encode(["username": "Client username", "email": "email@email\(String(repeating: "email", count: 500)).com"])
        }, afterResponse: { res async throws in
            let response = try res.content.decode(ErrorFromCreateClientApi.self)
            XCTAssertEqual(response.reason, "email is not a valid email address")
            XCTAssertEqual(res.status, .badRequest)
            let allClients = try await Client.query(on: app.db).all()
            XCTAssertEqual(allClients.count, 0)
        })
    }


    func testCreateClientWithTooShortUsername_clientNotCreated_validationError() async throws {
        try await app.test(.POST, "/api/clients", beforeRequest: { req in
            try req.content.encode(["username": "C", "email": "email@email.com"])
        }, afterResponse: { res async throws in
            let response = try res.content.decode(ErrorFromCreateClientApi.self)
            XCTAssertEqual("username is less than minimum of 3 character(s)", response.reason)
            XCTAssertEqual(res.status, .badRequest)
            let clientsCount = try await Client.query(on: app.db).all().count
            XCTAssertEqual(clientsCount, 0)
        })
    }

    func testCreateClientWithDuplicateUsername_clientNotCreated_validationError() async throws {
        let client1 = Client(username: "username", email: "email@email.com")
        try await client1.save(on: app.db)
        let clientsCount = try await Client.query(on: app.db).count()
        XCTAssertEqual(clientsCount, 1)

        try await app.test(.POST, "/api/clients", beforeRequest: { req in
            try req.content.encode(["username": "username", "email": "newemail@email.com"])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)
            let response = try res.content.decode(ErrorFromCreateClientApi.self)

            XCTAssertEqual("Client with this 'username' username already taken.", response.reason)
            XCTAssertTrue(response.error)

            let newClientsCount = try await Client.query(on: app.db).count()
            XCTAssertEqual(newClientsCount, 1)
        })
    }

    func testCreateClientWithDuplicateEmailAddress_clientNotCreated_validationError() async throws {
        let client1 = Client(username: "username", email: "email@email.com")
        try await client1.save(on: app.db)
        let clientsCount = try await Client.query(on: app.db).count()
        XCTAssertEqual(clientsCount, 1)

        try await app.test(.POST, "/api/clients", beforeRequest: { req in
            try req.content.encode(["username": "Client username", "email": "email@email.com"])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)
            let response = try res.content.decode(ErrorFromCreateClientApi.self)

            XCTAssertEqual("Client with this 'email@email.com' Email-Address already taken.", response.reason)
            XCTAssertTrue(response.error)

            let newClientsCount = try await Client.query(on: app.db).count()
            XCTAssertEqual(newClientsCount, 1)
        })
    }
}