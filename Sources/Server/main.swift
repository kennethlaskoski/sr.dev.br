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
import NIO
import Engine

#if DEBUG
  let numberOfThreads = 1
#else
  let numberOfThreads = System.coreCount
#endif
let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: numberOfThreads)

// Bootstrap

let target = try! bootstrap()
  .run.perform().unwrap()

run("", on: eventLoopGroup, at: target)

defer {
  try! eventLoopGroup.syncShutdownGracefully()
}
