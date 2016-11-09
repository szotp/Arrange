import UIKit
import Arrange
import PlaygroundSupport

class ExampleViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Navigation bar"
        let inner = UIView().style {
            $0.backgroundColor = .darkGray
        }
        arrange([.fill(10)], inner)
    }
}

let login = ExampleViewController()
let navigation = UINavigationController(rootViewController: login)
navigation.view.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
PlaygroundPage.current.liveView = navigation.view

