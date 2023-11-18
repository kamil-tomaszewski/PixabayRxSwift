//
//  File.swift
//  
//
//  Created by Kamil Tomaszewski on 15/11/2023.
//

import Foundation

public protocol UserRepositoryProtocol {
    func login(email: String, password: String) async throws
}

public final class UserRepository: UserRepositoryProtocol {
    public init() {}
    
    public func login(email: String, password: String) async throws {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            if email != "tim@apple.com" {
                throw RepositoryError.incorrectCredentials
            }
    }
}
