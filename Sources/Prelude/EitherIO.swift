//
//  EitherIO.swift
//  
//
//  Created by Kenneth Laskoski on 03/05/22.
//

public struct EitherIO<E, A> {
  public let run: IO<Either<E, A>>
  public init(run: IO<Either<E, A>>) {
    self.run = run
  }
}

public func pure<E, A>(_ a: A) -> EitherIO<E, A> {
  EitherIO.init <<< pure <<< pure <| a
//  EitherIO(run: pure(pure(a)))
}

extension EitherIO {
  public func flatMap<B>(_ f: @escaping (A) -> EitherIO<E, B>) -> EitherIO<E, B> {
    return .init(
      run: self.run.flatMap(either(pure <<< Either.one, ^\.run <<< f))
    )
  }
}

public func flatMap<E, A, B>(_ f: @escaping (A) -> EitherIO<E, B>) -> (EitherIO<E, A>) -> EitherIO<E, B> {
  return { $0.flatMap(f) }
}

public func >=> <E, A, B, C>(f: @escaping (A) -> EitherIO<E, B>, g: @escaping (B) -> EitherIO<E, C>) -> (A) -> EitherIO<E, C> {
  return f >>> flatMap(g)
}
