//
//  File.swift
//  
//
//  Created by Kamil Tomaszewski on 17/11/2023.
//

import Foundation

enum Constants {
    static let pixabayApiKey = "40737853-7e404b1fd5e5fb80f65897237"
    static let apiScheme = "https"
    static let apiHost = "pixabay.com"
    static let apiHostRoot = "/api/"
}

public protocol ImagesRepositoryProtocol {
    func fetchImages() async throws -> [ImageDetails]
}

public final class ImagesRepository: ImagesRepositoryProtocol {
    let session: URLSession
    let decoder: JSONDecoder
    
    public init(session: URLSession = .shared,
         decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
    
    public func fetchImages() async throws -> [ImageDetails] {
        var components = URLComponents()
        components.scheme = Constants.apiScheme
        components.host = Constants.apiHost
        components.path = Constants.apiHostRoot
        components.queryItems = [
            .init(name: "key", value: Constants.pixabayApiKey),
        ]
        
        guard let url = components.url else { throw RepositoryError.malformedUrl }
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw RepositoryError.noNetwork }
        guard 200..<300 ~= httpResponse.statusCode else { throw RepositoryError.incorrectStatusCode(code: httpResponse.statusCode,
                                                                                                    description: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode),
                                                                                                    url: url) }
        do {
            let decodedResponse = try decoder.decode(ImageDetailsListResponse.self, from: data)
            return decodedResponse.hits.map { .init(with: $0) }
        } catch let error {
            print("DECODING ERROR: \(error)")
            throw RepositoryError.unknown
        }
    }
}
