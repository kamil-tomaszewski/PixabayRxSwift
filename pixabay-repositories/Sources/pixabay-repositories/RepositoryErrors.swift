//
//  File.swift
//  
//
//  Created by Kamil Tomaszewski on 15/11/2023.
//

import Foundation

public enum RepositoryError: Error {
    case unknown
    case incorrectCredentials
    case malformedUrl
    case noNetwork
    case incorrectStatusCode(code: Int, description: String, url: URL)
}
