//===----------------------------------------------------------------------===//
// This source file was forked from the SwiftNIO open source project
// Copyright (c) 2017-2021 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
// SPDX-License-Identifier: Apache-2.0
//
// Copyright (c) 2022 Kenneth Laskoski
//===----------------------------------------------------------------------===//
import NIOCore
import NIOPosix

private final class EchoHandler: ChannelInboundHandler {
  public typealias InboundIn = ByteBuffer

  public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    context.write(data, promise: nil)
  }

  public func channelReadComplete(context: ChannelHandlerContext) {
    context.flush()
  }

  public func errorCaught(context: ChannelHandlerContext, error: Error) {
    print("error: ", error)
    context.close(promise: nil)
  }
}

let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
let bootstrap = ServerBootstrap(group: group)
  .serverChannelOption(ChannelOptions.backlog, value: 256)
  .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)

  .childChannelInitializer { channel in
    // Ensure we don't read faster than we can write by adding the BackPressureHandler into the pipeline.
    channel.pipeline.addHandler(BackPressureHandler()).flatMap { v in
      channel.pipeline.addHandler(EchoHandler())
    }
  }

  .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
  .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
  .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())

defer {
  try! group.syncShutdownGracefully()
}

// First argument is the program path
let arguments = CommandLine.arguments
let arg1 = arguments.dropFirst().first
let arg2 = arguments.dropFirst(2).first

let defaultHost = "::1"
let defaultPort = 8007

enum BindTo {
  case ip(host: String, port: Int)
  case unixDomainSocket(path: String)
}

let bindTarget: BindTo
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

let channel = try { () -> Channel in
  switch bindTarget {
  case .ip(let host, let port):
    return try bootstrap.bind(host: host, port: port).wait()
  case .unixDomainSocket(let path):
    return try bootstrap.bind(unixDomainSocketPath: path).wait()
  }
}()

print("Server started and listening on \(channel.localAddress!)")

// This will never unblock as we don't close the ServerChannel
try channel.closeFuture.wait()

print("Server closed")
