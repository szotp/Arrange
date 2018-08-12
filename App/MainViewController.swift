//
//  ViewController.swift
//  App
//
//  Created by krzat on 29/07/2018.
//  Copyright © 2018 szotp. All rights reserved.
//

import UIKit
import Arrange

class MainViewController: UIViewController {
    private var items: [Item] = Item.load()
    
    let picker = PickingView()
    let containerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.style { v in
            v.backgroundColor = UIColor.init(white: 0.95, alpha: 1.0)
        }
        
        containerView.style { v in
            v.backgroundColor = UIColor.white
        }
        
        view.arrange(
            .custom { c in
                c.fillUsingBottomSafeArea()
            },
            containerView,
            picker.style { v in
                v.items = items.map { $0.title }
                v.onSelected = { [weak self] _ in
                    self?.updateContainerView()
                }
            }
        )
        updateContainerView()
    }
    
    var currentViewController: UIViewController? {
        willSet {
            containerView.subviews.first?.removeFromSuperview()
            currentViewController?.removeFromParentViewController()
        }
        didSet {
            guard let vc = currentViewController else {
                return
            }
            
            addChildViewController(vc)
            containerView.arrange(.fill, vc.view)
            vc.didMove(toParentViewController: self)
        }
    }
    
    func updateContainerView() {
        let vc = items[picker.selectedIndex].type.init()
        let nc = UINavigationController(rootViewController: vc)
        currentViewController = nc
    }
}

class PickingView: ProgrammaticView, UIPickerViewDelegate, UIPickerViewDataSource {
    let picker = UIPickerView()
    
    var items: [String] = []
    var onSelected: ((Int) -> Void)?
    
    var selectedIndex: Int {
        return picker.selectedRow(inComponent: 0)
    }
    
    override func setupLayout() {
        arrange(
            .fill,
            picker.styleAndLayout { v, c in
                c.setHeight(100)
                v.dataSource = self
                v.delegate = self
            }
        )
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        onSelected?(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension ArrangementContext {
    func fillUsingBottomSafeArea() {
        pinTop()
        relativeToSafeArea()
        pin(.leading, .bottom, .trailing)
    }
}

class ExampleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(describing: type(of: self))
    }
}

private struct Item {
    var type: ExampleViewController.Type
    
    var title: String {
        return String(describing: type)
    }
    
    static func load() -> [Item] {
        let existing = Bundle.main.getSubclassesOf(ExampleViewController.self)
        
        let ordered: [ExampleViewController.Type] = [
            FillExample.self,
            CenterExample.self,
            LoginViewExample.self,
            TableViewExample.self
        ]
        
        assert(ordered.count == existing.count)
        
        return ordered.map {
            Item(type: $0)
        }
    }
}

private extension Bundle {
    func getSubclassesOf<T>(_ type: T.Type) -> [T.Type] {
        guard let url = executableURL?.path else {
            assertionFailure()
            return []
        }
        
        var count = UInt32(0)
        
        guard let ptr = objc_copyClassNamesForImage(url, &count) else {
            assertionFailure()
            return []
        }
        
        var result: [T.Type] = []
        
        for i in 0..<count {
            let name = String.init(cString: ptr[Int(i)])
            guard let anyType: AnyClass = Bundle.main.classNamed(name) else {
                assertionFailure()
                continue
            }
            
            if let castType = anyType as? T.Type, castType != type {
                result.append(castType)
            }
        }
        
        return result
    }
}
