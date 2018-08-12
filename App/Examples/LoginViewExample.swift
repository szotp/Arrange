//
//  LoginViewExample.swift
//  App
//
//  Created by krzat on 12/08/2018.
//  Copyright © 2018 szotp. All rights reserved.
//

import UIKit
import Arrange

private class LoginView: ProgrammaticView {
    let emailTextField = UITextField().style { v in
        v.placeholder = "Email"
        v.backgroundColor = UIColor.white
    }
    
    let passwordTextField = UITextField().style { v in
        v.placeholder = "Password"
        v.backgroundColor = UIColor.white
    }
    
    let signInButton = UIButton().style { v in
        v.setTitle("Sign in", for: .normal)
        v.backgroundColor = UIColor.black
    }
    
    let signUpButton = UIButton().style { v in
        v.setTitle("Sign up", for: .normal)
        v.backgroundColor = UIColor.black
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 1
    }
    
    override func setupLayout() {
        backgroundColor = UIColor.darkGray
        
        self.arrange(
            .centerY { c in
                c.setMargins(padding: 8, spacing: 4)
            },
            emailTextField,
            passwordTextField,
            UIView().arrange(
                .fillHorizontally { c in
                    c.stack.distribution = .fillEqually
                    c.stack.spacing = 4
                },
                signInButton,
                signUpButton
            )
        )
    }
}

class LoginViewExample: ExampleViewController {
    private let mainView = LoginView()
    
    override func loadView() {
        view = mainView
    }
}
