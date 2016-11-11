//
//  ArrangeTests.swift
//  ArrangeTests
//
//  Created by krzat on 29/10/16.
//  Copyright © 2016 krzat. All rights reserved.
//

import XCTest
import Arrange

class BigView : UIView {}

extension CGRect {
    func assertEqual(to expected : CGRect, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(self, expected, file:file, line:line)
    }
}

class ArrangeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOneToOne(_ arrangement : [ArrangementItem], expected : CGRect, file: StaticString = #file, line: UInt = #line) {
        let view = bigView()
        let subview = smallView()

        view.arrange(arrangement, subview)
        view.layoutIfNeeded()
        
        XCTAssertEqual(subview.frame, expected, file:file, line:line)
    }
    
    func testPadding() {
        testOneToOne([.fill(1)], expected: CGRect(x: 1, y: 1, width: 98, height: 98))
        testOneToOne([.fill(-1)], expected: CGRect(x: -1, y: -1, width: 102, height: 102))
        testOneToOne([.left(1), .top(1)], expected: CGRect(x: 1, y: 1, width: 10, height: 10))
        testOneToOne([.right(1), .bottom(1)], expected: CGRect(x: 89, y: 89, width: 10, height: 10))
    }
    
    func testScrollable() {
        let view = UIView()
        let height = view.heightAnchor.constraint(equalToConstant: 110)
        //height.priority = UILayoutPriorityRequired-1
        height.isActive = true

        let container = bigView().arrange(
            [.scrollable],
            view
        )
    
        let scrollView = container.subviews.first as? UIScrollView
        
        container.layoutIfNeeded()
        XCTAssertNotNil(scrollView)
        XCTAssertEqual(view.frame, CGRect(x: 0, y: 0, width: 100, height: 110))
        XCTAssertEqual(scrollView!.frame, CGRect(x: 0, y: 0, width: 100, height: 100))
        XCTAssertTrue(scrollView!.subviews.contains(view.superview!) || scrollView!.subviews.contains(view))
    }
    
    func testDefaultStacking() {
        let top = smallView()
        let middle = unsizedView()
        let bottom = smallView()
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)).arrange(
            [],
            top,
            middle,
            bottom
        )
        container.layoutIfNeeded()
        XCTAssertEqual(top.frame, CGRect(x: 0, y: 0, width: 100, height: 10))
        XCTAssertEqual(middle.frame, CGRect(x: 0, y: 10, width: 100, height: 80))
        XCTAssertEqual(bottom.frame, CGRect(x: 0, y: 90, width: 100, height: 10))
    }
    
    func bigView() -> UIView {
        return BigView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    func smallView() -> UIView {
        let subview = UIView()
        
        let width = subview.widthAnchor.constraint(equalToConstant: 10)
        width.priority = UILayoutPriorityDefaultLow
        width.isActive = true
        
        let height = subview.heightAnchor.constraint(equalToConstant: 10)
        height.priority = UILayoutPriorityDefaultLow
        height.isActive = true
        
        return subview
    }
    
    func unsizedView() -> UIView {
        return UIView()
    }
    
    func testOverlay() {
        let a = unsizedView()
        let b = unsizedView()
        let container = bigView()
        
        container.arrange([.overlaying], a,b)
        container.layoutIfNeeded()
        
        XCTAssertEqual(a.frame, container.bounds)
        XCTAssertEqual(b.frame, container.bounds)
    }
    
    func testEqualize() {
        let a = unsizedView()
        let b = unsizedView()
        let container = bigView()
        
        do {
            container.arrange(
                [.equalSizes],
                a,
                b
            )
            container.layoutIfNeeded()
            
            XCTAssertEqual(a.frame, CGRect(x: 0, y: 0, width: 100, height: 50))
            XCTAssertEqual(b.frame, CGRect(x: 0, y: 50, width: 100, height: 50))
        }
        
        do {
            container.arrange(
                [.equalSizes, .horizontal],
                a,
                b
            )
            container.layoutIfNeeded()
            XCTAssertEqual(a.frame, CGRect(x: 0, y: 0, width: 50, height: 100))
            XCTAssertEqual(b.frame, CGRect(x: 50, y: 0, width: 50, height: 100))
        }
    }
    
    func testCentered() {
        testOneToOne(
            [.centered],
            expected: CGRect(x: 45, y: 45, width: 10, height: 10)
        )
        
        testOneToOne(
            [.centeredVertically, .left(0)],
            expected: CGRect(x: 0, y: 45, width: 10, height: 10)
        )
        
        testOneToOne(
            [.centeredHorizontally, .top(0)],
            expected: CGRect(x: 45, y: 0, width: 10, height: 10)
        )
    }
    
    func testStyle() {
        let view = UILabel().style{
            $0.text = "x"
        }
    
        XCTAssertEqual(view.text, "x")
    }

    func testTopAndSides() {
        let big = bigView()
        let small = smallView()

        big.arrange([.topAndSides(0)], small)
        big.layoutIfNeeded()

        XCTAssertEqual(small.frame, CGRect(x: 0, y: 0, width: 100, height: 10))
    }

    func testCustomExtension() {
        let view = bigView()
        view.arrange([.hidden])
        assert(view.isHidden)
    }

    func testViewControllerArrange() {
        let viewController = UIViewController()
        viewController.view = bigView()
        let view = smallView()

        viewController.arrange([.topAndSides(0)], view)

        viewController.view.layoutIfNeeded()

        XCTAssertEqual(view.superview, viewController.view)
        XCTAssertEqual(view.frame, CGRect(x: 0, y: 0, width: 100, height: 10))
        //smallView should be aligned to layoutGuides, but offsets will not be visible in the test
    }

    func testCustomAnchor() {
        let big = bigView()
        let center = smallView()
        big.arrange([.centered], center)

        let other = smallView()
        let closure : Arrangement.Closure = {
            $0.bottomAnchor = center.topAnchor
        }
        big.arrange([.before(closure)], other)

        big.layoutIfNeeded()
        XCTAssertEqual(other.frame, CGRect(x: 0, y: 0, width: 100, height: 45))
    }

    func testStackViewCustomization() {
        let big = bigView()
        let a = smallView()
        let b = smallView()

        let closure : Arrangement.Closure = {
            $0.stackView?.spacing = 20
        }
        big.arrange([.after(closure), .equalSizes], a, b)
        big.layoutIfNeeded()

        XCTAssertEqual(a.frame, CGRect(x: 0, y: 0, width: 100, height: 40))
    }
}

extension ArrangementItem {
    static var hidden : ArrangementItem {
        return .after({ context in
            context.superview.isHidden = true
        })
    }
}
