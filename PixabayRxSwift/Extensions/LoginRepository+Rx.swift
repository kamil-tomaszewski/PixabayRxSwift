//
//  LoginRepository+Rx.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 16/11/2023.
//

import pixabay_repositories
import RxSwift

final class RxUserRepository: ReactiveCompatible {
    fileprivate let repository: UserRepositoryProtocol
    fileprivate init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
}

extension UserRepositoryProtocol {
    var rx: Reactive<RxUserRepository> {
        return RxUserRepository(repository: self).rx
    }
}

extension Reactive where Base: RxUserRepository {
    func login(email: String, password: String) -> Completable {
        Completable.async {
            try await self.base.repository.login(email: email, password: password)
        }
    }
}

