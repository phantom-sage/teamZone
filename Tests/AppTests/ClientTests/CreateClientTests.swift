@testable import App
import XCTVapor

final class CreateClientTests: XCTestCase {
    func testCreateClientWithValidData_clientCreated() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        // send request to create new client
        try await app.test(.POST, "clients", beforeRequest: { req in
            try req.content.encode(["username": "client username", "email": "email@email.com"])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let client = try res.content.decode(Client.self)
            XCTAssertEqual(client.username, "client username")
            XCTAssertEqual(client.email, "email@email.com")
            let allClients = try await Client.query(on: app.db).all()
            XCTAssertEqual(allClients.count, 1)
        })

        try app.autoRevert().wait()
        try app.autoMigrate().wait()
    }
}