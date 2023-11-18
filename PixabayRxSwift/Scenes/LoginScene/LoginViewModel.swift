//
//  LoginViewModel.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 15/11/2023.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt
import pixabay_repositories

final class LoginViewModel {
    let repository: UserRepositoryProtocol
    
    let disposeBag = DisposeBag()
    
    let input = Input()
    private(set) var output = Output()
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
        
        output.email = input.email.asDriver(onErrorJustReturn: nil)
        output.password = input.password.asDriver(onErrorJustReturn: nil)
        
        let email = input.email
            .unwrap()
        
        let isInvalidEmail = email
            .map { EmailValidator(email: $0).validate() == .invalid }
            .share()

        output.emailError = Observable.merge(isInvalidEmail, input.submit.mapTo(false))
            .asDriver(onErrorJustReturn: false)
        
        let password = input.password
            .unwrap()
        
        let isInvalidPassword = password
            .map { $0.count < 6 || $0.count > 12 }
            .share()
        
        output.passwordError = Observable.merge(isInvalidPassword, input.submit.mapTo(false))
            .asDriver(onErrorJustReturn: false)
        
        output.isLoginEnabled = Observable
            .combineLatest(isInvalidEmail, isInvalidPassword)
            .map { !$0 && !$1 }
            .asDriver(onErrorJustReturn: true)
        
        let credentials = Observable
            .combineLatest(email, password)
        
        let loginResultEvents = input.submit
            .withLatestFrom(credentials)
            .flatMapLatest { email, password in
                repository.rx.login(email: email, password: password)
                    .andThen(Observable.just(()))
                    .asObservable()
                    .materialize()
            }
            .share()
        
        output.loginSucceeded = loginResultEvents
            .elements()
            .asSignal(onErrorSignalWith: .never())
        
        let loginResultError = loginResultEvents
            .errors()
            .mapTo(true)
            .startWith(false)

        output.loginOperationError = Observable.merge(loginResultError, input.submit.mapTo(false))
            .asDriver(onErrorJustReturn: false)
    }
}

extension LoginViewModel {
    struct Input {
        let email = BehaviorSubject<String?>(value: nil)
        let password = BehaviorSubject<String?>(value: nil)
        let submit = PublishRelay<Void>()
        
        fileprivate init() {}
    }
    
    struct Output {
        fileprivate(set) var email: Driver<String?> = .never()
        fileprivate(set) var emailError: Driver<Bool> = .never()
        fileprivate(set) var password: Driver<String?> = .never()
        fileprivate(set) var passwordError: Driver<Bool> = .never()
        fileprivate(set) var isLoginEnabled: Driver<Bool> = .never()
        fileprivate(set) var loginOperationError: Driver<Bool> = .never()
        fileprivate(set) var loginSucceeded: Signal<Void> = .never()
    }
}
