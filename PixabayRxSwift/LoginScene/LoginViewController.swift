//
//  LoginViewController.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 15/11/2023.
//

import UIKit
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
    var viewModel: LoginViewModel! //TODO: FIXME
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        
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
            .drive(emailErrorLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.passwordError
            .drive(passwordErrorLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.isLoginEnabled
            .drive(loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.output.loginOperationError
            .drive(loginErrorLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.loginSucceeded
            .emit(onNext: { [weak self] in
                self?.navigateHome()
            })
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
        navigationController?.pushViewController(homeViewController, animated: true)
    }
}

