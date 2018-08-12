//
//  Layout.swift
//  LayoutTest
//
//  Created by szotp on 27/10/2016.
//  Copyright © 2016 szotp. All rights reserved.
//

import UIKit

public struct Arrangement {
    public typealias Closure = (ArrangementContext) -> Void
    public let closure: Closure
    
    func apply(context: ArrangementContext) {
        closure(context)
        context.complete()
    }
    
    public static func custom(_ closure: @escaping Closure) -> Arrangement {
        return Arrangement(closure: closure)
    }
    
    /// Pins subviews to all edges.
    public static let fill: Arrangement = .custom { c in
        c.fill()
    }
    
    /// Pins subviews to all edges, contained inside vertical stack view.
    public static func fillVertically(_ closure: Closure? = nil) -> Arrangement {
        return .custom { c in
            closure?(c)
            c.fill()
        }
    }
    
    /// Pins subviews to all edges, contained inside vertical stack view.
    public static func fillHorizontally(_ closure: Closure? = nil) -> Arrangement {
        return .custom { c in
            closure?(c)
            c.fill()
            if c.subviews.count > 1 {
                c.stack.axis = .horizontal
            }
        }
    }
    
    /// Centers subviews in Y axis, pinning on both sides.
    public static func centerY(_ closure: Closure? = nil) -> Arrangement {
        return .custom { c in
            closure?(c)
            c.pin(.centerY, .leading, .trailing)
        }
    }
    
    /// Centers subviews.
    public static func center(_ closure: Closure? = nil) -> Arrangement {
        return .custom { c in
            closure?(c)
            c.pinCenter()
        }
    }
}
    
/// Holds UI objects to use during arrangement setup.
public class ArrangementContext {
    public enum ConstraintIdentifier: String {
        case leading, trailing, bottom, top, centerX, centerY, width
    }
    
    /// Outer view used in pinX methods.
    public let superview: UIView
    public let subviews: [UIView]
    
    /// Values used when pinning to edges.
    public var insets = UIEdgeInsets()
    var guide: ViewOrGuide
    
    /// Inner view used in pinX methods. By default stack of provided subviews.
    public lazy var subview: UIView = {
        if subviews.count == 1 {
            return subviews[0]
        } else {
            return stack
        }
    }()
    
    /// Default subview for containing provided subviews.
    public lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: self.subviews)
        stack.axis = .vertical
        return stack
    }()
    
    init(superview : UIView, subviews : [UIView]) {
        self.superview = superview
        self.subviews = subviews
        self.guide = superview
    }
    
    func complete() {
        subview.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(subview)
        superview.addConstraints(constraints)
    }

    public private(set) var constraints: [NSLayoutConstraint] = []
    
    public func constraint(for identifier: ConstraintIdentifier) -> NSLayoutConstraint? {
        return constraints.first { $0.identifier == identifier.rawValue}
    }
    
    // MARK: - Padding
    
    public func setPadding(insets: UIEdgeInsets) {
        self.insets = insets
    }
    
    public func setPadding(_ value: CGFloat) {
        self.insets = UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }
    
    public func setHorizontalPadding(_ value: CGFloat) {
        insets.top = value
        insets.bottom = value
    }
    
    public func setVerticalPadding(_ value: CGFloat) {
        insets.left = value
        insets.right = value
    }
    
    public func setMargins(padding: CGFloat, spacing: CGFloat) {
        setPadding(padding)
        stack.spacing = spacing
    }
    
    // MARK: - Pinning
    
    public func fill() {
        pinTop()
        pinBottom()
        pinLeading()
        pinTrailing()
    }
    
    public func pin(_ constraints: ConstraintIdentifier...) {
        for c in constraints {
            switch c {
            case .leading:
                pinLeading()
            case .trailing:
                pinTrailing()
            case .bottom:
                pinBottom()
            case .top:
                pinTop()
            case .centerX:
                pinCenterX()
            case .centerY:
                pinCenterY()
            case .width:
                pinWidth()
            }
        }
    }
    
    public func pinCenterX() {
        append(
            constraint: subview.centerXAnchor.constraint(equalTo: guide.centerXAnchor, constant: 0),
            identifier: .centerX
        )
    }
    
    public func pinCenterY() {
        append(
            constraint: subview.centerYAnchor.constraint(equalTo: guide.centerYAnchor, constant: 0),
            identifier: .centerY
        )
    }
    
    public func pinCenter() {
        pinCenterX()
        pinCenterY()
    }
    
    public func pinLeading() {
        append(
            constraint: subview.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: insets.left),
            identifier: .leading
        )
    }
    
    public func pinTrailing() {
        append(
            constraint: guide.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: insets.left),
            identifier: .trailing
        )
    }
    
    public func pinTop() {
        append(
            constraint: subview.topAnchor.constraint(equalTo: guide.topAnchor, constant: insets.left),
            identifier: .top
        )
    }
    
    public func pinBottom() {
        append(
            constraint: guide.bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: insets.left),
            identifier: .bottom
        )
    }
    
    /// Superview will have the same height as subview. Mostly useful for scroll views.
    public func pinWidth() {
        append(
            constraint: superview.widthAnchor.constraint(equalTo: subview.widthAnchor, multiplier: 1.0),
            identifier: .width
        )
    }
    
    func append(constraint: NSLayoutConstraint, identifier: ConstraintIdentifier) {
        assert(self.constraint(for: identifier) == nil)
        constraints.append(constraint)
        constraints.last?.identifier = identifier.rawValue
    }
    
    // MARK: - Guides
    
    public func relativeToSafeArea() {
        if #available(iOS 11.0, *) {
            guide = superview.safeAreaLayoutGuide
        } else {
            relativeToViewControllerGuides()
        }
    }
    
    @available(iOS, deprecated: 11.0, message: "Use relativeToSafeArea()")
    public func relativeToViewControllerGuides() {
        guard let vc = superview.next as? UIViewController else {
            assertionFailure("Could not find UIViewController")
            return
        }
        guide = ViewControllerGuide(vc: vc)
    }
    
    public func relativeToLayoutMargins() {
        guide = superview.layoutMarginsGuide
    }
}

public extension UIAppearance where Self: UIView  {
    /// Apply given closure to the instance. Can be used for chaining, or customization within property initializer.
    @discardableResult public func style(_ styleClosure: (Self) -> ()) -> Self {
        styleClosure(self)
        return self
    }

    @discardableResult public func styleAndLayout(_ styleClosure: (Self, SingleViewLayout) -> ()) -> Self {
        let layout = SingleViewLayout(self)
        styleClosure(self, layout)
        layout.activate()
        return self
    }
}

public extension UIView {
    /// Adds views to the view hierarchy, using the provided arrangement.
    /// Arrangement can be also initialized as array of ArrangementTraits.
    /// By default subviews will fill the superview with 0 margin, stacked vertically.
    /// Returns self for chaining.
    @discardableResult public func arrange(_ style: Arrangement, _ subviews: UIView...) -> Self {
        return arrange(style, subviews)
    }

    @discardableResult public func arrange(_ style: Arrangement, _ subviews: [UIView]) -> Self {
        let context = ArrangementContext(
            superview: self,
            subviews: subviews
        )

        style.apply(context: context)
        return self
    }
}
