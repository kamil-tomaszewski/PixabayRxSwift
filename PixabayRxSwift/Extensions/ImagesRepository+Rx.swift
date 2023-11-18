//
//  ImagesRepository+Rx.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 17/11/2023.
//

import pixabay_repositories
import RxSwift

final class RxImagesRepository: ReactiveCompatible {
    fileprivate let repository: ImagesRepositoryProtocol
    fileprivate init(repository: ImagesRepositoryProtocol) {
        self.repository = repository
    }
}

extension ImagesRepositoryProtocol {
    var rx: Reactive<RxImagesRepository> {
        return RxImagesRepository(repository: self).rx
    }
}

extension Reactive where Base: RxImagesRepository {
    func fetchImages() -> Single<[ImageDetails]> {
        Single.async {
            try await self.base.repository.fetchImages()
        }
    }
}
