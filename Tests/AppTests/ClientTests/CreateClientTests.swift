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
        try await app.test(.POST, "clients", beforeRequest: { req in
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
        try await app.test(.POST, "clients", beforeRequest: { req in
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
}