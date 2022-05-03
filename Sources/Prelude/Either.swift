//
//  Either.swift
//  
//
//  Created by Kenneth Laskoski on 03/05/22.
//

public enum Either<A, B> {
  case one(A)
  case two(B)
}

extension Either {
  public func either<C>(_ f: (A) throws -> C, _ g: (B) throws -> C) rethrows -> C {
    switch self {
    case .one(let a):
      return try f(a)
    case .two(let b):
      return try g(b)
    }
  }

  public var one: A? { either(Optional.some, const(.none)) }
  public var two: B? { either(const(.none), Optional.some) }

  public var isOne: Bool { either(const(true), const(false)) }
  public var isTwo: Bool { either(const(false), const(true)) }
}

public func either<A, B, C>(_ f: @escaping (A) -> C, _ g: @escaping (B) -> C) -> (Either<A, B>) -> C {
  { ab in ab.either(f, g) }
}

public func pure<A, B>(_ b: B) -> Either<A, B> { .two(b) }

extension Either where A == Error {
  public static func wrap<C>(_ f: @escaping (C) throws -> B) -> (C) -> Either {
    return { a in
      do {
        return .two(try f(a))
      } catch let error {
        return .one(error)
      }
    }
  }

  public static func wrap(_ f: @escaping () throws -> B) -> Either {
    do {
      return .two(try f())
    } catch let error {
      return .one(error)
    }
  }

  public func unwrap() throws -> B {
    return try either({ throw $0 }, id)
  }
}

extension Either where A: Error {
  public func unwrap() throws -> B {
    return try either({ throw $0 }, id)
  }
}

public func unwrap<B>(_ either: Either<Error, B>) throws -> B {
  return try either.unwrap()
}

public func unwrap<A: Error, B>(_ either: Either<A, B>) throws -> B {
  return try either.unwrap()
}
