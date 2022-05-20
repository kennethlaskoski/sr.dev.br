//
//  App.swift
//
//
//  Created by Kenneth Laskoski on 10/05/22.
//

import NIOCore
import NIOPosix

public struct App {
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

  public static func listen(host: String, port: Int) {
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

    do {
      let channel = try { () -> Channel in
          return try bootstrap.bind(host: host, port: port).wait()
      }()

      print("Server started and listening on \(channel.localAddress!)")

      // This will never unblock as we don't close the ServerChannel
      try channel.closeFuture.wait()

      print("Server closed")
    } catch {

    }
  }
}
