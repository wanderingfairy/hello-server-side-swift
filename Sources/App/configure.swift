import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
  // uncomment to serve files from /Public folder
  let fileMiddleware = FileMiddleware(publicDirectory: app.directory.publicDirectory)
  app.middleware.use(fileMiddleware)
  
  app.databases.use(.postgres(
    hostname: Environment.get("DATABASE_HOST") ?? "localhost",
    port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
    username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
    password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
    database: Environment.get("DATABASE_NAME") ?? "vapor_database"
  ), as: .psql)
  
  app.migrations.add(CreateTodo())
  
  app.views.use(.leaf)
  
  app.routes.defaultMaxBodySize = "512kb"
  
  
  app.routes.caseInsensitive = true //case-insensitive
  // register routes
  try routes(app)
}
