//
//  IO.swift
//  
//
//  Created by Kenneth Laskoski on 02/05/22.
//

import Foundation

public struct IO<A> {
  private let compute: () -> A
  public init(_ compute: @escaping () -> A) {
    self.compute = compute
  }

  public func perform() -> A {
    compute()
  }
}

public func perform<A>(_ io: IO<A>) -> A {
  io.perform()
}

public func pure<A>(_ a: A) -> IO<A> {
  IO { a }
}

extension IO {
  public func flatMap<B>(_ f: @escaping (A) -> IO<B>) -> IO<B> {
    IO<B> { f(self.perform()).perform() }
  }
}

public func flatMap<A, B>(_ f: @escaping (A) -> IO<B>) -> (IO<A>) -> IO<B> {
  { $0.flatMap(f) }
}
