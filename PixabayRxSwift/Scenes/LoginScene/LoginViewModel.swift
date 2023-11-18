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
        
        let invalidEmailMessage = "Please enter a valid email address"
        
        let isInvalidEmail = input.email
            .map { EmailValidator(email: $0).validate() == .invalid }
            .share()

        output.emailError = Observable.merge(isInvalidEmail, input.submit.mapTo(false))
            .map { $0 ? invalidEmailMessage : nil }
            .asDriver(onErrorJustReturn: nil)
        
        let invalidPasswordMessage = "The password must be between 6 and 12 characters long"
        
        let isInvalidPassword = input.password
            .map { $0.count < 6 || $0.count > 12 }
            .share()
        
        output.passwordError = Observable.merge(isInvalidPassword, input.submit.mapTo(false))
            .map { $0 ? invalidPasswordMessage : nil }
            .asDriver(onErrorJustReturn: nil)
        
        output.isLoginEnabled = Observable
            .combineLatest(isInvalidEmail, isInvalidPassword)
            .map { !$0 && !$1 }
            .asDriver(onErrorJustReturn: true)
        
        let credentials = Observable
            .combineLatest(input.email, input.password)
        
        let loginOperationErrorMessage = "Login failed"
        
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
            .mapTo(loginOperationErrorMessage)
            .startWith(nil)

        output.loginOperationError = Observable.merge(loginResultError, input.submit.mapTo(nil))
            .asDriver(onErrorJustReturn: nil)
    }
}

extension LoginViewModel {
    struct Input {
        let email = BehaviorSubject<String>(value: "")
        let password = BehaviorSubject<String>(value: "")
        let submit = PublishRelay<Void>()
        
        fileprivate init() {}
    }
    
    struct Output {
        fileprivate(set) var emailError: Driver<String?> = .never()
        fileprivate(set) var passwordError: Driver<String?> = .never()
        fileprivate(set) var isLoginEnabled: Driver<Bool> = .never()
        fileprivate(set) var loginOperationError: Driver<String?> = .never()
        fileprivate(set) var loginSucceeded: Signal<Void> = .never()
    }
}
