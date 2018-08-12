//
//  TableViewExample.swift
//  App
//
//  Created by krzat on 12/08/2018.
//  Copyright © 2018 szotp. All rights reserved.
//

import UIKit
import Arrange

class TableViewExample: ExampleViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.arrange(
            .fill,
            tableView.style { v in
                Cell.register(in: v)
                v.delegate = self
                v.dataSource = self
            }
        )
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Cell.dequeue(from: tableView, at: indexPath)
        cell.setup(viewData: "Cell: \(indexPath)")
        return cell
    }
}

private class BaseCell: ProgrammaticTableViewCell {
    static let identifier = String(describing: self)
    
    static func dequeue(from tableView: UITableView, at indexPath: IndexPath) -> Self {
        func convert<T>(_ input: Any) -> T {
            return input as! T
        }
        
        return convert(tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath))
    }
    
    static func register(in tableView: UITableView) {
        tableView.register(self, forCellReuseIdentifier: identifier)
    }
    
    override func setupLayout() {
        
    }
}

private class Cell: BaseCell {
    let extraLabel = UILabel()
    
    override func setupLayout() {
        contentView.arrange(.fill, extraLabel)
    }
    
    func setup(viewData: String) {
        extraLabel.text = viewData
    }
}


