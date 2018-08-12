//
//  SimpleExample.swift
//  App
//
//  Created by krzat on 12/08/2018.
//  Copyright © 2018 szotp. All rights reserved.
//

import UIKit
import Arrange

class CenterExample: ExampleViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.arrange(
            .center(),
            UIView().styleAndLayout { v, c in
                v.backgroundColor = UIColor.red
                c.setSize(100)
            }
        )
    }
}

class FillExample: ExampleViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.arrange(
            .fillVertically { c in
                c.setPadding(16)
                c.relativeToSafeArea()
            },
            UIView().styleAndLayout { v, c in
                v.backgroundColor = UIColor.red
            }
        )
    }
}
