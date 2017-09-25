//
//  MultiMap.swift
//  LispKit
//
//  Created by Matthias Zenger on 18/09/2016.
//  Copyright © 2016 ObjectHub. All rights reserved.
//

/// Minimalistic multi map implementation
public struct MultiMap<Key: Hashable, Value>: CustomStringConvertible {
  private var map: [Key : [Value]]
  
  public init() {
    self.map = [:]
  }
  
  public var keys: Dictionary<Key, [Value]>.Keys {
    return map.keys
  }
  
  public func hasValues(for key: Key) -> Bool {
    return self.map[key] != nil
  }
  
  public func values(for key: Key) -> [Value] {
    return self.map[key] ?? []
  }
  
  public mutating func insert(_ key: Key, mapsTo value: Value) {
    if self.map[key] == nil {
      self.map[key] = [value]
    } else {
      self.map[key]!.append(value)
    }
  }
  
  public var description: String {
    var builder = StringBuilder(prefix: "{", postfix: "}", separator: ", ")
    for (key, value) in self.map {
      builder.append("\(key) → \(value)")
    }
    return builder.description
  }
}
