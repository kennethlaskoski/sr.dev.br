//
//  NIO.swift
//  
//
//  Created by Kenneth Laskoski on 03/05/22.
//

import NIO

public enum BindTarget {
  case ip(host: String, port: Int)
  case unixDomainSocket(path: String)
}

public func run(
  _ content: @autoclosure @escaping () -> String,
  on eventLoopGroup: EventLoopGroup,
  at target: BindTarget
) {
  do {
    let bootstrap = ServerBootstrap(group: eventLoopGroup)
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
    
    
    let channel = try { () -> Channel in
      switch target {
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
  } catch {
    fatalError(error.localizedDescription)
  }
}

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
