//
//  LogView.swift
//  OraclePDS
//
//  Created by Arun CP on 26/05/21.
//

import Foundation
import UIKit

class LogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate{

    var dataSource = [String]()

    private let tableView : UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log"
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.beginUpdates()
        tableView.frame = view.bounds
        tableView.reloadData()
        tableView.endUpdates()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil{
            cell = UITableViewCell(style:.subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.numberOfLines = 0
        print(dataSource[indexPath.row])
        cell?.textLabel?.text = dataSource[indexPath.row]
        return cell!
    }
}
