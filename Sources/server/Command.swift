//
//  Command.swift
//  
//
//  Created by Kenneth Laskoski on 10/05/22.
//

import Network
import ArgumentParser

@main
struct Command: ParsableCommand {
  static let configuration = CommandConfiguration(commandName: "server", abstract: "sr.dev.br server command.")

  @Argument(help: "The host to bind on.")
  var host: String = "::1"

  @Argument(help: "The port to bind on.")
  var port: Int = 8007

  mutating func run() throws {
    let bootstrap = { host, port in
      App.listen(host: host, port: port)
    }
    bootstrap(host, port)
  }
}
