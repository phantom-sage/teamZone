import Vapor

struct VerifyManagerJWTTokenMiddleware: AsyncMiddleware {
    func respond(to request: Vapor.Request, chainingTo next: Vapor.AsyncResponder) async throws -> Vapor.Response {
        try request.jwt.verify(as: ManagerLoginJWT.self)
        
        // manager token veriftied continue.
        return try await next.respond(to: request)
    }
}