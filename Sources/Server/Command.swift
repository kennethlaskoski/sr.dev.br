//
//  Command.swift
//  
//
//  Created by Kenneth Laskoski on 10/05/22.
//

import ArgumentParser

@main
struct Command: ParsableCommand {
  static let configuration = CommandConfiguration(abstract: "Start sr.dev.br server.")

  @Option(name: .shortAndLong, help: "The host to bind on.")
  var host: String = "::1"

  @Option(name: .shortAndLong, help: "The port to bind on.")
  var port: Int = 8007

  mutating func run() throws {
    Server.run(host: host, port: port)
  }
}
