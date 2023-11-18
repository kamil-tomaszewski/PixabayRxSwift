//
//  HomeViewModel.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 17/11/2023.
//

import Foundation
import RxSwift
import RxCocoa
import pixabay_repositories
import Differentiator

final class HomeViewModel {
    let repository: ImagesRepositoryProtocol
    
    let disposeBag = DisposeBag()
    
    let input = Input()
    private(set) var output = Output()
    
    init(repository: ImagesRepositoryProtocol) {
        self.repository = repository
        
        let imagesEvents = input.viewDidAppear
            .flatMapLatest {
                repository.rx.fetchImages()
                    .asObservable()
                    .materialize()
            }
            .share()
        
        output.images = imagesEvents
            .elements()
            .map {
                [Section(header: $0.count.formatted(),
                        items: $0.map { ImageListItem(id: $0.id.formatted(), imageUrl: $0.previewUrl, author: $0.user)})]
            }
            .asDriver(onErrorJustReturn: [])
        
        output.navigateToDetails = input.detailsSelected
            .withLatestFrom(imagesEvents.elements()) { ($0, $1) }
            .map { selected, images in
                images.first { $0.id.formatted() == selected.id }
            }
            .unwrap()
            .asSignal(onErrorSignalWith: .never())
    }
}

extension HomeViewModel {
    struct Input {
        let viewDidAppear = PublishRelay<Void>()
        let detailsSelected = PublishRelay<ImageListItem>()
        
        fileprivate init() {}
    }
    
    struct Output {
        fileprivate(set) var images: Driver<[Section]> = .never()
        fileprivate(set) var navigateToDetails: Signal<ImageDetails> = .never()
    }
}

extension HomeViewModel {
    struct Section: SectionModelType {
        typealias Item = ImageListItem
        var header: String
        var items: [Item]
        
        init(header: String, items: [Item]) {
            self.header = header
            self.items = items
        }
        
        init(original: Section, items: [ImageListItem]) {
            self = original
            self.items = items
        }
    }
}

struct ImageListItem {
    let id: String
    let imageUrl: URL
    let author: String
}
