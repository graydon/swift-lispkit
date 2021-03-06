//
//  Hash.swift
//  LispKit
//
//  Created by Matthias Zenger on 16/07/2016.
//  Copyright © 2016 ObjectHub. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation


public func equalHash(_ expr: Expr) -> Int {
  var visited = Set<Reference>()
  
  func alreadyVisited(_ ref: Reference) -> Bool {
    if visited.contains(ref) {
      return true
    }
    visited.insert(ref)
    return false
  }
  
  func hash(_ expr: Expr) -> Int {
    switch expr.normalized {
      case .undef,
           .uninit(_):
        return 0
      case .void:
        return 1
      case .eof:
        return 2
      case .null:
        return 3
      case .true:
        return 4
      case .false:
        return 5
      case .symbol(let sym):
        return sym.hashValue &* 31 &+ 6
      case .fixnum(let num):
        return num.hashValue &* 31 &+ 7
      case .bignum(let num):
        return num.hashValue &* 31 &+ 8
      case .rational(let n, let d):
        return ((hash(n) &* 31) &+ hash(d)) &* 31 &+ 9
      case .flonum(let num):
        return num.hashValue &* 31 &+ 11
      case .complex(let num):
        return num.value.hashValue &* 31 &+ 12
      case .char(let char):
        return char.hashValue &* 31 &+ 13
      case .string(let str):
        return str.hashValue &* 31 &+ 14
      case .bytes(let bvector):
        var res = 0
        for byte in bvector.value {
          res = res &* 31 &+ byte.hashValue
        }
        return res &* 31 &+ 15
      case .pair(let car, let cdr):
        return ((hash(car) &* 31) &+ hash(cdr)) &* 31 &+ 16
      case .box(let cell):
        if alreadyVisited(cell) {
          return 0
        }
        let res = hash(cell.value)
        visited.remove(cell)
        return res &* 31 &+ 17
      case .mpair(let tuple):
        if alreadyVisited(tuple) {
          return 0
        }
        let res = hash(tuple.fst) &* 31 &+ hash(tuple.snd)
        visited.remove(tuple)
        return res &* 31 &+ 18
      case .vector(let vector):
        if alreadyVisited(vector) {
          return 0
        }
        var res = 0
        for expr in vector.exprs {
          res = res &* 31 &+ hash(expr)
        }
        visited.remove(vector)
        return res &* 31 &+ 19
      case .record(let record):
        if alreadyVisited(record) {
          return 0
        }
        var res: Int
        switch record.kind {
          case .recordType:
            res = 1
          case .record(let type):
            res = type.hashValue
          default:
            res = 0
        }
        for expr in record.exprs {
          res = res &* 31 &+ hash(expr)
        }
        visited.remove(record)
        return res &* 31 &+ 20
      case .table(let map):
        if alreadyVisited(map) {
          return 0
        }
        var res = 0
        for (key, value) in map.mappings {
          res = res &+ (hash(key) &* 31) &+ hash(value)
        }
        visited.remove(map)
        return res &* 31 &+ 21
      case .promise(let promise):
        return promise.hashValue &* 31 &+ 22
      case .values(let expr):
        return hash(expr) &* 31 &+ 23
      case .procedure(let proc):
        return proc.hashValue &* 31 &+ 24
      case .special(let special):
        return special.hashValue &* 31 &+ 25
      case .env(let environment):
        return environment.hashValue &* 31 &+ 26
      case .port(let port):
        return port.hashValue &* 31 &+ 27
      case .tagged(let tag, let expr):
        return (eqvHash(tag) &* 31 &+ hash(expr)) &* 31 &+ 28
      case .error(let err):
        return err.hashValue &* 31 &+ 29
      case .syntax(let pos, let expr):
        return ((pos.hashValue &* 31) &+ hash(expr)) &* 31 &+ 30
    }
  }
  
  return hash(expr)
}

public func eqvHash(_ expr: Expr) -> Int {
  switch expr.normalized {
    case .undef,
         .uninit(_):
      return 0
    case .void:
      return 1
    case .eof:
      return 2
    case .null:
      return 3
    case .true:
      return 4
    case .false:
      return 5
    case .symbol(let sym):
      return sym.hashValue &* 31 &+ 6
    case .fixnum(let num):
      return num.hashValue &* 31 &+ 7
    case .bignum(let num):
      return num.hashValue &* 31 &+ 8
    case .rational(let n, let d):
      return ((eqvHash(n) &* 31) &+ eqvHash(d)) &* 31 &+ 9
    case .flonum(let num):
      return num.hashValue &* 31 &+ 11
    case .complex(let num):
      return num.value.hashValue &* 31 &+ 12
    case .char(let char):
      return char.hashValue &* 31 &+ 13
    case .string(let str):
      return ObjectIdentifier(str).hashValue &* 31 &+ 14
    case .bytes(let bvector):
      return bvector.hashValue &* 31 &+ 15
    case .pair(let car, let cdr):
      return ((eqvHash(car) &* 31) &+ eqvHash(cdr)) &* 31 &+ 16
    case .box(let cell):
      return cell.hashValue &* 31 &+ 17
    case .mpair(let tuple):
      return tuple.hashValue &* 31 &+ 18
    case .vector(let vector):
      return vector.hashValue &* 31 &+ 19
    case .record(let record):
      return record.hashValue &* 31 &+ 20
    case .table(let map):
      return map.hashValue &* 31 &+ 21
    case .promise(let promise):
      return promise.hashValue &* 31 &+ 22
    case .values(let expr):
      return eqvHash(expr) &* 31 &+ 23
    case .procedure(let proc):
      return proc.hashValue &* 31 &+ 24
    case .special(let special):
      return special.hashValue &* 31 &+ 25
    case .env(let environment):
      return environment.hashValue &* 31 &+ 26
    case .port(let port):
      return port.hashValue &* 31 &+ 27
    case .tagged(let tag, let expr):
      return (eqvHash(tag) &* 31 &+ eqvHash(expr)) &* 31 &+ 28
    case .error(let err):
      return err.hashValue &* 31 &+ 29
    case .syntax(let pos, let expr):
      return ((pos.hashValue &* 31) &+ eqvHash(expr)) &* 31 &+ 30
  }
}

public func eqHash(_ expr: Expr) -> Int {
  switch expr {
    case .undef,
         .uninit(_):
      return 0
    case .void:
      return 1
    case .eof:
      return 2
    case .null:
      return 3
    case .true:
      return 4
    case .false:
      return 5
    case .symbol(let sym):
      return sym.hashValue &* 31 &+ 6
    case .fixnum(let num):
      return num.hashValue &* 31 &+ 7
    case .bignum(let num):
      return num.hashValue &* 31 &+ 8
    case .rational(let n, let d):
      return ((eqHash(n) &* 31) &+ eqHash(d)) &* 31 + 9
    case .flonum(let num):
      return num.hashValue &* 31 &+ 11
    case .complex(let num):
      return num.value.hashValue &* 31 &+ 12
    case .char(let char):
      return char.hashValue &* 31 &+ 13
    case .string(let str):
      return ObjectIdentifier(str).hashValue &* 31 &+ 14
    case .bytes(let bvector):
      return bvector.hashValue &* 31 &+ 15
    case .pair(let car, let cdr):
      return ((eqHash(car) &* 31) &+ eqHash(cdr)) &* 31 &+ 16
    case .box(let cell):
      return cell.hashValue &* 31 &+ 17
    case .mpair(let tuple):
      return tuple.hashValue &* 31 &+ 18
    case .vector(let vector):
      return vector.hashValue &* 31 &+ 19
    case .record(let record):
      return record.hashValue &* 31 &+ 20
    case .table(let map):
      return map.hashValue &* 31 &+ 21
    case .promise(let promise):
      return promise.hashValue &* 31 &+ 22
    case .values(let expr):
      return eqHash(expr) &* 31 &+ 23
    case .procedure(let proc):
      return proc.hashValue &* 31 &+ 24
    case .special(let special):
      return special.hashValue &* 31 &+ 25
    case .env(let environment):
      return environment.hashValue &* 31 &+ 26
    case .port(let port):
      return port.hashValue &* 31 &+ 27
    case .tagged(let tag, let expr):
      return (eqvHash(tag) &* 31 &+ eqHash(expr)) &* 31 &+ 28
    case .error(let err):
      return err.hashValue &* 31 &+ 29
    case .syntax(let pos, let expr):
      return ((pos.hashValue &* 31) &+ eqHash(expr)) &* 31 &+ 30
  }
}
