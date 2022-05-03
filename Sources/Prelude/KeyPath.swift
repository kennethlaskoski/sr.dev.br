//
//  KeyPath.swift
//  
//
//  Created by Kenneth Laskoski on 03/05/22.
//

public func over<Root, Value>(_ keyPath: WritableKeyPath<Root, Value>) -> (@escaping (Value) -> Value) -> (Root) -> Root {
  { over in
    { root in
      var copy = root
      copy[keyPath: keyPath] = over(copy[keyPath: keyPath])
      return copy
    }
  }
}

public func get<Root, Value>(_ keyPath: KeyPath<Root, Value>) -> (Root) -> Value { {root in root[keyPath: keyPath]} }
public func set<Root, Value>(_ keyPath: WritableKeyPath<Root, Value>) -> (Value) -> (Root) -> Root { over(keyPath) <<< const }

prefix operator ^
extension KeyPath {
  public static prefix func ^ (keyPath: KeyPath) -> (Root) -> Value { get(keyPath) }
}