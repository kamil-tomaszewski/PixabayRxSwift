//
//  ImageDetailsResponse.swift
//
//
//  Created by Kamil Tomaszewski on 17/11/2023.
//

import Foundation

struct ImageDetailsListResponse: Decodable {
    let total: Int
    let hits: [ImageDetailsResponse]
}

struct ImageDetailsResponse: Decodable {
    let id: Int
    let previewURL: URL
    let largeImageURL: URL
    let tags: String
    let imageWidth: Int
    let imageHeight: Int
    let imageSize: Int
    let type: String
    let user: String
    let views: Int
    let downloads: Int
    let likes: Int
    let comments: Int
    let collections: Int
}
