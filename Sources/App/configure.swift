import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import Leaf
import Vapor
import GraphQL
import GraphQLKit

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    switch app.environment {
        case .testing:
            app.databases.use(.sqlite(.memory), as: .sqlite)
            try app.autoMigrate().wait()
        default:
            app.databases.use(.postgres(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
                username: Environment.get("DATABASE_USERNAME") ?? "vapor_user",
                password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
                database: Environment.get("DATABASE_NAME") ?? "vapor_db"
            ), as: .psql)
    }

    app.migrations.add(CreateProject())
    app.migrations.add(CreateClient())
    app.migrations.add(CreateManager())
    app.migrations.add(CreateHr())
    app.migrations.add(CreateTeamMember())
    app.migrations.add(CreateTask())

    app.views.use(.leaf)

    app.passwords.use(.bcrypt(cost: 8))

    // register routes
    try routes(app)

    app.register(graphQLSchema: projectSchema, withResolver:  ProjectResolver())
}
