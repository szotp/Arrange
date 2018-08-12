import UIKit
import Arrange
import PlaygroundSupport

class ExampleViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Navigation bar"
        
        view.style {
            $0.backgroundColor = UIColor.darkGray
        }

        view.arrange(
            .custom {
                $0.relativeToSafeArea()
                $0.setPadding(16)
                $0.fill()
            },
            UIView().style {
                $0.backgroundColor = .gray
            }
        )
    }
}

let login = ExampleViewController()
let navigation = UINavigationController(rootViewController: login)
navigation.view.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
PlaygroundPage.current.liveView = navigation.view

