import Vapor

struct ManagerDataFromCreateHandler: Content {
    var name: String
    var email: String
}