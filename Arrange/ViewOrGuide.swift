//
//  ViewOrGuide.swift
//  Arrange
//
//  Created by krzat on 12/08/2018.
//  Copyright © 2018 szotp. All rights reserved.
//

import UIKit

protocol ViewOrGuide {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: ViewOrGuide {}
extension UILayoutGuide: ViewOrGuide {}

struct ViewControllerGuide: ViewOrGuide {
    let vc: UIViewController
    
    var leadingAnchor: NSLayoutXAxisAnchor {
        return vc.view.leadingAnchor
    }
    
    var trailingAnchor: NSLayoutXAxisAnchor {
        return vc.view.trailingAnchor
    }
    
    var leftAnchor: NSLayoutXAxisAnchor {
        return vc.view.leftAnchor
    }
    
    var rightAnchor: NSLayoutXAxisAnchor {
        return vc.view.rightAnchor
    }
    
    var topAnchor: NSLayoutYAxisAnchor {
        return vc.topLayoutGuide.bottomAnchor
    }
    
    var bottomAnchor: NSLayoutYAxisAnchor {
        return vc.bottomLayoutGuide.topAnchor
    }
    
    var widthAnchor: NSLayoutDimension {
        return vc.view.widthAnchor
    }
    
    var heightAnchor: NSLayoutDimension {
        return vc.view.heightAnchor
    }
    
    var centerXAnchor: NSLayoutXAxisAnchor {
        return vc.view.centerXAnchor
    }
    
    var centerYAnchor: NSLayoutYAxisAnchor {
        return vc.view.centerYAnchor
    }
}
