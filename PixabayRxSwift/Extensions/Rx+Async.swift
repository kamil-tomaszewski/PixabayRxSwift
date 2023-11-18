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

extension PrimitiveSequenceType where Trait == SingleTrait {
    static func async(_ handler: @escaping () async throws -> Element) -> Single<Element> {
        Single.create { single in
            let task = Task {
                do {
                    single(.success(try await handler()))
                } catch {
                    single(.failure(error))
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }

    static func async<T: AnyObject>(with object: T, handler: @escaping (T) async throws -> Element) -> Single<Element> {
        Single<Element>.create { single in
            let task = Task { [weak object] in
                guard let object = object else { throw Error.unknown }
                do {
                    single(.success(try await handler(object)))
                } catch {
                    single(.failure(error))
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }
}

extension PrimitiveSequenceType where Trait == CompletableTrait, Element == Swift.Never {
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
