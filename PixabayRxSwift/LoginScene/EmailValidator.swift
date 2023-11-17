//
//  EmailValidator.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 15/11/2023.
//

import Foundation
enum FormValidatorResult: Equatable {
    case valid
    case invalid
}

protocol FormFieldValidator {
    func validate() -> FormValidatorResult
}

struct EmailValidator: FormFieldValidator {
    
    let email: String
    
    private let emailPred = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    
    func validate() -> FormValidatorResult {
        if emailPred.evaluate(with: email) {
            return .valid
        }
        
        return .invalid
    }
}
