import Fluent
import Vapor

func routes(_ app: Application) throws {
    let clientsController = ClientsController()
    try app.register(collection: clientsController)
}
