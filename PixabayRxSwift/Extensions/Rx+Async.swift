//
//  Rx+Async.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 16/11/2023.
//

import RxSwift

enum Error: Swift.Error {
    case unknown
}

extension Completable {
    static func fromAsync<T>(_ fn: @escaping () async throws -> T) -> Single<T> {
        .create { observer in
            let task = Task {
                do { try await observer(.success(fn())) }
                catch { observer(.failure(error))}
            }
            return Disposables.create { task.cancel() }
        }
    }
}

extension PrimitiveSequenceType where Trait == CompletableTrait, Element == Swift.Never {
    /// Create completable that emit completion from async throws function.
    ///
    /// - Parameter handler:  A async throws function.
    /// - Returns: The observable sequence with the specified implementation for the subscribe method
    static func async(_ handler: @escaping () async throws -> Void) -> Completable {
        Completable.create { completable in
            let task = Task {
                do {
                    try await handler()
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }

    static func async<T: AnyObject>(with object: T, handler: @escaping (T) async throws -> Void) -> Completable {
        Completable.create { completable in
            let task = Task { [weak object] in
                guard let object = object else { throw Error.unknown }
                do {
                    try await handler(object)
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
