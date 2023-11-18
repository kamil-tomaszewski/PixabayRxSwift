//
//  LoginViewController.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 15/11/2023.
//

import UIKit
import pixabay_repositories
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {
    @IBOutlet private var emailTextfield: UITextField!
    @IBOutlet private var emailErrorLabel: UILabel!
    @IBOutlet private var passwordTextfield: UITextField!
    @IBOutlet private var passwordErrorLabel: UILabel!
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var loginErrorLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    var viewModel: LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        
        emailTextfield.keyboardType = .emailAddress
        emailTextfield.autocapitalizationType = .none
        emailTextfield.autocorrectionType = .no
        
        emailTextfield.rx.controlEvent([.editingDidEndOnExit])
            .asObservable()
            .subscribe(onNext: { [weak self] in
                self?.passwordTextfield.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        bindOutput()
        bindInput()
    }

    private func bindOutput() {
        viewModel.output.emailError
            .map { $0 ? .systemRed : .label }
            .drive(emailErrorLabel.rx.textColor)
            .disposed(by: disposeBag)
        
        viewModel.output.passwordError
            .map { $0 ? .systemRed : .label }
            .drive(passwordErrorLabel.rx.textColor)
            .disposed(by: disposeBag)
        
        viewModel.output.isLoginEnabled
            .drive(loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.output.loginOperationError
            .map { !$0 }
            .drive(loginErrorLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.output.loginSucceeded
            .emit(onNext: { [weak self] in
                self?.navigateHome()
            })
            .disposed(by: disposeBag)
        
        viewModel.output.email
            .drive(emailTextfield.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.password
            .drive(passwordTextfield.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func bindInput() {
        emailTextfield.rx
            .text.orEmpty
            .bind(to: viewModel.input.email)
            .disposed(by: disposeBag)
        
        passwordTextfield.rx
            .text.orEmpty
            .bind(to: viewModel.input.password)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .bind(to: viewModel.input.submit)
            .disposed(by: disposeBag)
    }
    
    private func navigateHome() {
        let homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
        homeViewController.viewModel = HomeViewModel(repository: ImagesRepository())
        navigationController?.pushViewController(homeViewController, animated: true)
    }
}

