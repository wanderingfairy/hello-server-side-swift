import Fluent
import Vapor

func routes(_ app: Application) throws {
  app.get { req in
    return req.view.render("index", ["title": "Hello Vapor!"])
  }
  
  app.get("hello") { req -> String in
    return "Hello, world!"
  }
  
  app.on(.GET, "hello", "vapor") { req -> String in // same at 'app.get(uri)'
    return "Hello, vapor!"
  }
  
  app.on(.GET, "hello", ":name") { (req) -> String in
    let name = req.parameters.get("name")!
    return "Hello, \(name)!"
  }
  
  app.get("hello", "**") { req -> String in
      let name = req.parameters.getCatchall().joined(separator: " ")
      return "Hello, \(name)!"
  }
  
  app.get("Number", ":x") { req -> String in
      guard let int = req.parameters.get("x", as: Int.self) else {
          throw Abort(.badRequest)
      }
      return "\(int) is a great number"
  }.description("get number")
  
  app.on(.POST, "listings", body: .collect(maxSize: "1mb")) { (req) -> String in
    return ""
  }
  
  // Request body will not be collected into a buffer.
//  app.on(.POST, "upload", body: .stream) { req in
//
//  }
  
//  print(app.routes.all)
  
//  let users = app.grouped("users")
  
  app.group("users") { users in
    //GET /users
    users.get { req -> String in
      return "GET USERS"
    }
    
    users.post { req -> String in
      return "POST USERS"
    }
    
    users.get(":id") { req -> String in
      guard let id = req.parameters.get("id") else {
        throw Abort(.internalServerError)
      }
      return "Your id is \(id)!"
    }
    
    // Redirection
    users.on(.GET, "redirect", ":id") { (req) -> Response in
      return req.redirect(to: "/users/\(req.parameters.get("id")!)")
    }
    
    // when user request post with {"hello": "world"}
    users.post("greeting") { req -> UInt in
      let greeting = try req.content.decode(Greeting.self)
      print(greeting.hello) // "world"
      return HTTPStatus.ok.code
    }
    
    users.get("hello") { req -> String in
      let hello = try req.query.decode(Hello.self)
      return "Hello, \(hello.name ?? "Anonymous")"
    }
    
    users.get("single") { req -> String in
      let name: String? = req.query["name"]
      return "Hello, \(name ?? "none")"
    }
  }
  
  try app.register(collection: TodoController())
}
