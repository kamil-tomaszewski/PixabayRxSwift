//
//  ImageDetails.swift
//
//
//  Created by Kamil Tomaszewski on 17/11/2023.
//

import Foundation

public struct ImageDetails {
    public let id: Int
    public let previewUrl: URL
    public let imageUrl: URL
    public let tags: [String]
    public let imageWidth: Int
    public let imageHeight: Int
    public let imageSize: Int
    public let type: String
    public let user: String
    public let views: Int
    public let downloads: Int
    public let likes: Int
    public let comments: Int
    public let collections: Int
}

extension ImageDetails {
    init(with response: ImageDetailsResponse) {
        id = response.id
        previewUrl = response.previewURL
        imageUrl = response.largeImageURL
        tags = response.tags.components(separatedBy: ",")
        imageWidth = response.imageWidth
        imageHeight = response.imageHeight
        imageSize = response.imageSize
        type = response.type
        user = response.user
        views = response.views
        downloads = response.downloads
        likes = response.likes
        comments = response.comments
        collections = response.collections
    }
}
