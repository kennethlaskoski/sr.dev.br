//
//  Bootstrap.swift
//  
//
//  Created by Kenneth Laskoski on 02/05/22.
//

import Prelude
import Backtrace

public func bootstrap() -> EitherIO<Error, BindTarget> {
  Backtrace.install()

  return EitherIO.debug(prefix: "⚠️ Bootstrapping sr.dev.br")
    .flatMap(readArgs)
//    .flatMap(const(.debug(prefix: "✅ sr.dev.br bootstrapped!")))
}

private let readArgs = { (_: Unit) -> EitherIO<Error, BindTarget> in
  // First argument is the program path
  let arguments = CommandLine.arguments
  let arg1 = arguments.dropFirst().first
  let arg2 = arguments.dropFirst(2).first

  let defaultHost = "::1"
  let defaultPort = 8007

  let bindTarget: BindTarget
  switch (arg1, arg1.flatMap(Int.init), arg2.flatMap(Int.init)) {
  case (.some(let h), _ , .some(let p)):
    /* we got two arguments, let's interpret that as host and port */
    bindTarget = .ip(host: h, port: p)
  case (.some(let portString), .none, _):
    /* couldn't parse as number, expecting unix domain socket path */
    bindTarget = .unixDomainSocket(path: portString)
  case (_, .some(let p), _):
    /* only one argument --> port */
    bindTarget = .ip(host: defaultHost, port: p)
  default:
    bindTarget = .ip(host: defaultHost, port: defaultPort)
  }

  return pure(bindTarget)
}
