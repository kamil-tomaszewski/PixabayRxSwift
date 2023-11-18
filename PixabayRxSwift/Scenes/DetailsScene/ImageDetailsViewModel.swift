//
//  ImageDetailsViewModel.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 18/11/2023.
//

import Foundation
import pixabay_repositories
import RxSwift
import RxCocoa
import Differentiator

final class ImageDetailsViewModel {
    let disposeBag = DisposeBag()
    
    let input = Input()
    private(set) var output = Output()
    
    init(imageDetails: ImageDetails) {
        let sections: [Sections] = [
            .ImageDataSection(title: "Image Data", items: [
                .ImageUrlSectionItem(imageDetails.imageUrl),
                .TitleDescriptionSectionItem(field: .size, description: "\(imageDetails.imageWidth) x \(imageDetails.imageHeight)"),
                .TitleDescriptionSectionItem(field: .type, description: imageDetails.type),
                .TitleDescriptionSectionItem(field: .tags, description: imageDetails.tags.joined(separator: ","))
            ]),
            .ImageDescriptionSection(title: "Image Description", items: [
                .TitleDescriptionSectionItem(field: .author, description: imageDetails.user),
                .TitleDescriptionSectionItem(field: .views, description: imageDetails.views.formatted()),
                .TitleDescriptionSectionItem(field: .likes, description: imageDetails.likes.formatted()),
                .TitleDescriptionSectionItem(field: .comments, description: imageDetails.comments.formatted()),
                .TitleDescriptionSectionItem(field: .favorites, description: imageDetails.collections.formatted()),
                .TitleDescriptionSectionItem(field: .downloads, description: imageDetails.downloads.formatted())
            ])
            
        ]
        
        output.detailsSections = Observable.just(sections)
            .asDriver(onErrorJustReturn: [])
    }
}

extension ImageDetailsViewModel {
    struct Input {
        fileprivate init() {}
    }
    
    struct Output {
        fileprivate(set) var detailsSections: Driver<[Sections]> = .never()
    }
}

extension ImageDetailsViewModel {
    enum Field: String {
        case size
        case type
        case tags
        case author
        case views
        case likes
        case comments
        case favorites
        case downloads
    }
}

extension ImageDetailsViewModel {
    enum Sections {
        case ImageDataSection(title: String, items: [SectionItem])
        case ImageDescriptionSection(title: String, items: [SectionItem])
    }
    
    enum SectionItem {
        case ImageUrlSectionItem(URL)
        case TitleDescriptionSectionItem(field: Field, description: String)
    }
}

extension ImageDetailsViewModel.Sections: SectionModelType {
    typealias Item = ImageDetailsViewModel.SectionItem
    
    var items: [Item] {
        switch self {
        case let .ImageDataSection(_, items):
            return items.map { $0 }
        case let .ImageDescriptionSection(_, items):
            return items.map { $0 }
        }
    }
    
    init(original: ImageDetailsViewModel.Sections, items: [Item]) {
        switch original {
        case let .ImageDataSection(title, items):
            self = .ImageDataSection(title: title, items: items)
        case let .ImageDescriptionSection(title, items):
            self = .ImageDescriptionSection(title: title, items: items)
        }
    }
}

extension ImageDetailsViewModel.Sections {
    var title: String {
        switch self {
        case let .ImageDataSection(title, _):
            return title
        case let .ImageDescriptionSection(title, _):
            return title
        }
    }
}
