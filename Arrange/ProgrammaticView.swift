//
//  ProgrammaticView.swift
//  Arrange
//
//  Created by krzat on 12/08/2018.
//  Copyright © 2018 szotp. All rights reserved.
//

import UIKit

/// Protocol for boilerplate code for doing setup
public protocol Programmatic {
    func setupLayout()
    func setupLayoutIfNeeded()
}

// Note: this is the same code copied three times for each class

open class ProgrammaticView: UIView, Programmatic {
    private var setupDone = false
    
    open func setupLayout() {
        
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupLayoutIfNeeded()
    }
    
    public final func setupLayoutIfNeeded() {
        if setupDone {
            return
        }
        setupDone = true
        setupLayout()
    }
}

open class ProgrammaticTableViewCell: UITableViewCell, Programmatic {
    private var setupDone = false
    
    open func setupLayout() {
        
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupLayoutIfNeeded()
    }
    
    public final func setupLayoutIfNeeded() {
        if setupDone {
            return
        }
        setupDone = true
        setupLayout()
    }
}

open class ProgrammaticCollectionViewCell: UITableViewCell, Programmatic {
    private var setupDone = false
    
    open func setupLayout() {
        
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupLayoutIfNeeded()
    }
    
    public final func setupLayoutIfNeeded() {
        if setupDone {
            return
        }
        setupDone = true
        setupLayout()
    }
}
