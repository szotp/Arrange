import UIKit
import Arrange
import PlaygroundSupport

extension UITextField {
    func addMarginView(margin : CGFloat) {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: margin, height: 0))
        leftView?.isHidden = true
        leftViewMode = .always
    }
}

extension ArrangementItem {
    static var hidden : ArrangementItem {
        return after({ context in
            context.superview.isHidden = true
        })
    }
}

class LoginView : UIView {
    let loginTextField : UITextField
    let passwordTextField : UITextField
    let signInButton : UIButton
    let signUpButton : UIButton

    let z : [ArrangementItem] = [.left(8)]

    override init(frame: CGRect) {
        loginTextField = UITextField().style {
            $0.placeholder = "Login"
            $0.backgroundColor = .white
            $0.addMarginView(margin: 8)
        }

        passwordTextField = UITextField().style {
            $0.placeholder = "Password"
            $0.isSecureTextEntry = true
            $0.backgroundColor = .white
            $0.addMarginView(margin: 8)
        }

        signInButton = UIButton(type: .custom).style {
            $0.setTitle("Sign in", for: .normal)
            $0.backgroundColor = .black
        }

        signUpButton = UIButton(type: .custom).style {
            $0.setTitle("Sign up", for: .normal)
            $0.backgroundColor = .black
            $0.layer.borderColor = UIColor.white.cgColor
            $0.layer.borderWidth = 1
        }

        super.init(frame: frame)
        backgroundColor = .gray

        arrange(
            z + [.centeredVertically, .left(8), .right(8), .spacing(8)],
            loginTextField,
            passwordTextField,
            UIView().arrange(
                [.horizontal, .equalSizes, .spacing(8)],
                signInButton,
                signUpButton
            )
        )
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class LoginViewController : UIViewController {
    override func loadView() {
        view = LoginView()
    }
}


PlaygroundPage.current.liveView = LoginView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
