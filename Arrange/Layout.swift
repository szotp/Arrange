//
//  Layout.swift
//  LayoutTest
//
//  Created by szotp on 27/10/2016.
//  Copyright © 2016 szotp. All rights reserved.
//

import UIKit

/// Defines desired properties of a layout between view and it's subviews.
public enum ArrangementItem {
    /// Subviews should be pinned to the left, with given margin.
    case left(CGFloat)
    
    /// Subviews should be pinned to the top, with given margin.
    case top(CGFloat)
    
    /// Subviews should be pinned to the bottom, with given margin.
    case bottom(CGFloat)
    
    /// Subviews should be pinned to the right, with given margin.
    case right(CGFloat)
    
    /// Subviews should be pinned from all sides to superview, with given margin.
    case fill(CGFloat)

    /// Subviews should be stacked vertically.
    case vertical
    
    /// Subviews should be stacked horizontally.
    case horizontal
    
    /// Subviews should occupy the same space.
    case overlaying
    
    /// Subviews should all have the same size.
    case equalSizes

    /// Subviews should be centered in both dimensions.
    case centered
    
    /// Subviews should be centered vertically.
    case centeredVertically
    
    /// Subviews should be centered horizontally.
    case centeredHorizontally

    /// Subviews should be pinned from all sides, except bottom, with given margin.
    case topAndSides(CGFloat)

    /// Items in stack should have given spacing. Default is 0.
    case spacing(CGFloat)

    /// Given closure should be executed after main arrangement has been performed.
    case after(Arrangement.Closure)

    case scrollable
}

extension Arrangement {
    private static func equalSizes(context: ArrangementContext) {
        let first = context.subviews.first!

        guard case let .stack(axis, _) = context.arrangement.stacking else {
            assertionFailure()
            return
        }

        for subview in context.subviews {
            if subview !== first {
                if axis == .vertical {
                    subview.heightAnchor.constraint(equalTo: first.heightAnchor).isActive = true
                } else {
                    subview.widthAnchor.constraint(equalTo: first.widthAnchor).isActive = true
                }

            }
        }
    }

    /// Creates Arrangement from collection of given arrengement items.
    public init(_ elements: [ArrangementItem]) {
        var paddedX = false
        var paddedY = false

        for item in elements {
            switch item {
            case let .left(margin):
                paddedX = true
                left = margin

            case let .right(margin):
                paddedX = true
                right = margin

            case let .top(margin):
                paddedY = true
                top = margin

            case let .bottom(margin):
                paddedY = true
                bottom = margin

            case let .fill(margin):
                paddedX = true
                paddedY = true
                bottom = margin
                top = margin
                left = margin
                right = margin

            case .vertical:
                guard case let .stack(_, spacing) = stacking else {
                    assertionFailure()
                    return
                }
                stacking = Stacking.stack(axis: .vertical, spacing: spacing)

            case .horizontal:
                guard case let .stack(_, spacing) = stacking else {
                    assertionFailure()
                    return
                }
                stacking = Stacking.stack(axis: .horizontal, spacing: spacing)

            case let .spacing(spacing):
                guard case let .stack(axis, _) = stacking else {
                    assertionFailure()
                    return
                }
                stacking = Stacking.stack(axis: axis, spacing: spacing)

            case .overlaying:
                stacking = .overlaying

            case .centered:
                paddedX = true
                paddedY = true
                centeredX = true
                centeredY = true

            case .centeredVertically:
                paddedY = true
                centeredY = true

            case .centeredHorizontally:
                paddedX = true
                centeredX = true

            case let .topAndSides(margin):
                top = margin
                left = margin
                right = margin
                paddedY = true
                paddedX = true

            case let .after(closure):
                post.append(closure)

            case .equalSizes:
                post.append(Arrangement.equalSizes)

            case .scrollable:
                post.append(mountScrollView)

            }
        }

        if !paddedX {
            left = 0
            right = 0
        }

        if !paddedY {
            bottom = 0
            top = 0
        }
    }
}

/// Describes how constraints and subviews should be set up during arrangement process.
public struct Arrangement {
    public typealias Closure = (ArrangementContext) -> ()

    enum Stacking {
        case overlaying
        case stack(axis: UILayoutConstraintAxis, spacing: CGFloat)
    }

    var left: CGFloat?
    var right: CGFloat?
    var top: CGFloat?
    var bottom: CGFloat?

    var centeredY = false
    var centeredX = false

    var reuse = false

    var stacking = Stacking.stack(axis: .vertical, spacing: 0)

    var scrollable = false

    var post: [Closure] = []

    func apply(context: ArrangementContext) {
        if context.subviews.count > 1 {
            switch stacking {
            case let .stack(axis, spacing):
                let stack = UIStackView()

                for view in context.subviews {
                    stack.addArrangedSubview(view)
                }


                stack.axis = axis
                stack.spacing = spacing
                context.paddedView = stack
                context.superview.addSubview(stack)

            case .overlaying:
                let container = UIView()

                for view in context.subviews {
                    container.arrange([], view)
                }
                context.paddedView = container
                context.superview.addSubview(container)
            }

        } else if let first = context.subviews.first {
            context.paddedView = first
            context.superview.addSubview(first)
        }

        if let paddedView = context.paddedView {
            paddedView.translatesAutoresizingMaskIntoConstraints = false
            
            if let constant = top {
                let topAnchor = context.viewController?.topLayoutGuide.bottomAnchor ?? context.superview.topAnchor
                topAnchor.constraint(equalTo: paddedView.topAnchor, constant: -constant).isActive = true
            }
            if let constant = left {
                context.superview.leftAnchor.constraint(equalTo: paddedView.leftAnchor, constant: -constant).isActive = true
            }
            if let constant = bottom {
                let bottomAnchor = context.viewController?.bottomLayoutGuide.topAnchor ?? context.superview.bottomAnchor
                bottomAnchor.constraint(equalTo: paddedView.bottomAnchor, constant: constant).isActive = true
            }
            if let constant = right {
                context.superview.rightAnchor.constraint(equalTo: paddedView.rightAnchor, constant: constant).isActive = true
            }
            
            if centeredX {
                context.superview.centerXAnchor.constraint(equalTo: paddedView.centerXAnchor).isActive = true
            }
            
            if centeredY {
                context.superview.centerYAnchor.constraint(equalTo: paddedView.centerYAnchor).isActive = true
            }
        }

        for closure in post {
            closure(context)
        }
    }
}

func mountScrollView(context:  ArrangementContext) {
    let scrollView = UIScrollView()
    let contentView = UIView()

    scrollView.arrange([], contentView)
    scrollView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true

    guard let paddedView = context.paddedView else {
        assertionFailure()
        return
    }

    paddedView.removeFromSuperview()

    context.superview.arrange(
        [],
        scrollView
    )

    contentView.arrange(
        [],
        paddedView
    )
}

/// Holds UI objects to use during arrangement setup.
public class ArrangementContext {
    public var superview: UIView
    public var subviews: [UIView]
    public var paddedView: UIView?
    public var arrangement : Arrangement
    public var viewController : UIViewController?


    init(arrangement : Arrangement, superview : UIView, subviews : [UIView]) {
        self.arrangement = arrangement
        self.superview = superview
        self.subviews = subviews
    }
}

public extension UIAppearance {
    /// Apply given closure to the instance. Can be used for chaining, or customization within property initializer.
    @discardableResult public func style(_ styleClosure: (Self) -> ()) -> Self {
        styleClosure(self)
        return self
    }
}

public extension UIView {
    /// Adds views to the view hierarchy, using the provided arrangement.
    /// Arrangement can be also initialized as array of ArrangementTraits.
    /// By default subviews will fill the superview with 0 margin, stacked vertically.
    /// Returns self for chaining.
    @discardableResult public func arrange(_ items: [ArrangementItem], _ subviews: UIView...) -> Self {
        return arrange(items, subviews)
    }

    @discardableResult public func arrange(_ items: [ArrangementItem], _ subviews: [UIView]) -> Self {
        let style = Arrangement(items)
        let context = ArrangementContext(
            arrangement: style,
            superview: self,
            subviews: subviews
        )

        style.apply(context: context)
        return self
    }
}

public extension UIViewController {
    /// Adds views to the view hierarchy, using the provided arrangement.
    /// Arrangement can be also initialized as array of ArrangementTraits.
    /// By default subviews will fill the superview with 0 margin, stacked vertically.
    /// Returns self for chaining.
    /// Uses layout guides of this view controller when arranging to top and bottom.
    @discardableResult public func arrange(_ items: [ArrangementItem], _ subviews: UIView...) -> Self {
        return arrange(items, subviews)
    }

    @discardableResult public func arrange(_ items: [ArrangementItem], _ subviews: [UIView]) -> Self {
        let style = Arrangement(items)
        let context = ArrangementContext(
            arrangement: style,
            superview: self.view,
            subviews: subviews
        )
        context.viewController = self

        style.apply(context: context)
        return self
    }
}
