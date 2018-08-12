//
//  SingleViewLayout.swift
//  Arrange
//
//  Created by krzat on 12/08/2018.
//  Copyright © 2018 szotp. All rights reserved.
//

import UIKit

public class SingleViewLayout {
    let subview: UIView
    var constraints: [NSLayoutConstraint] = []
    
    init(_ view: UIView) {
        subview = view
    }
    
    public func setSize(_ value: CGFloat) {
        constraints.append(subview.widthAnchor.constraint(equalToConstant: value))
        constraints.append(subview.heightAnchor.constraint(equalToConstant: value))
    }
    
    public func setAspectRatio(_ widthToHeightRatio: CGFloat) {
        constraints.append(subview.widthAnchor.constraint(equalTo: subview.heightAnchor, multiplier: widthToHeightRatio))
    }
    
    func activate() {
        subview.addConstraints(constraints)
    }
    
    public func setHeight(_ height: CGFloat) {
        constraints.append(subview.heightAnchor.constraint(equalToConstant: height))
    }
    
    public func avoidHeightChanges() {
        subview.setContentHuggingPriority(.required, for: .vertical)
        subview.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    public func avoidWidthChanges() {
        subview.setContentHuggingPriority(.required, for: .horizontal)
        subview.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
