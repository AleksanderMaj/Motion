//
//  Gen.swift
//  Motion
//
//  Created by Aleksander Maj on 25/10/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import Foundation

struct Gen<A> {
    let run: () -> A
}

let random = Gen(run: arc4random)

extension Gen {
    func map<B>(_ f: @escaping (A) -> B) -> Gen<B> {
        return Gen<B> { f(self.run()) }
    }
}

let uint64 = Gen<UInt64> {
    let lower = UInt64(random.run())
    let upper = UInt64(random.run()) << 32
    return lower + upper
}

func int(in range: ClosedRange<Int>) -> Gen<Int> {
    return Gen<Int> {
        var delta = UInt64(truncatingIfNeeded: range.upperBound &- range.lowerBound)
        if delta == UInt64.max {
            return Int(truncatingIfNeeded: uint64.run())
        }
        delta += 1
        let tmp = UInt64.max % delta + 1
        let upperBound = tmp == delta ? 0 : tmp
        var random: UInt64 = 0
        repeat {
            random = uint64.run()
        } while random < upperBound
        return Int(
            truncatingIfNeeded: UInt64(truncatingIfNeeded: range.lowerBound)
                &+ random % delta
        )
    }
}

func element<A>(of xs: [A]) -> Gen<A?> {
    return int(in: 0...(xs.count - 1)).map { idx in
        guard !xs.isEmpty else { return nil }
        return xs[idx]
    }
}

extension Gen {
    func array(count: Gen<Int>) -> Gen<[A]> {
        return Gen<[A]> {
            Array(repeating: (), count: count.run())
                .map { self.run() }
        }
    }
}

extension Gen where A == Character {
    func string(count: Gen<Int>) -> Gen<String> {
        return self
            .map(String.init)
            .array(count: count)
            .map { $0.joined() }
    }
}

func zip2<A, B>(_ a: Gen<A>, _ b: Gen<B>) -> Gen<(A, B)> {
    return Gen<(A, B)> {
        (a.run(), b.run())
    }
}

func zip3<A, B, C>(_ a: Gen<A>, _ b: Gen<B>, _ c: Gen<C>) -> Gen<(A, B, C)> {
    return zip2(a, zip2(b, c)).map { ($0, $1.0, $1.1) }
}

func zip2<A, B, C>(with f: @escaping (A, B) -> C) -> (Gen<A>, Gen<B>) -> Gen<C> {
    return { zip2($0, $1).map(f) }
}

func zip3<A, B, C, D>(with f: @escaping (A, B, C) -> D) -> (Gen<A>, Gen<B>, Gen<C>) -> Gen<D> {
    return { zip3($0, $1, $2).map(f) }
}

