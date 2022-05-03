//
//  Function.swift
//  
//
//  Created by Kenneth Laskoski on 03/05/22.
//

public func id<A>(_ a: A) -> A { a }

public func <| <A, B> (f: (A) -> B, a: A) -> B { f(a) }
public func |> <A, B> (a: A, f: (A) -> B) -> B { f(a) }

public func const<A, B>(_ a: A) -> (B) -> A { {_ in a} }

public func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C { {b in {a in f(a)(b)}} }

public func <<< <A, B, C>(g: @escaping (B) -> C, f: @escaping (A) -> B) -> (A) -> C { {a in g(f(a))} }
public func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C { {a in g(f(a))} }

public func flatMap<A, B, C>(_ g: @escaping (B) -> (A) -> C, _ f: @escaping (A) -> B) -> (A) -> C { {a in g(f(a))(a)} }
public func >=> <A, B, C, D>(_ f: @escaping (A) -> (D) -> B, _ g: @escaping (B) -> (D) -> C) -> (A) -> (D) -> C { {a in flatMap(g, f(a))} }
