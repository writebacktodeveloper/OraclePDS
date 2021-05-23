//
//  TaskCustomCell.swift
//  OraclePDS
//
//  Created by Arun CP on 23/05/21.
//

import UIKit
class TaskCell: UITableViewCell {
    
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var lat: UILabel!
    @IBOutlet weak var long: UILabel!
    @IBOutlet weak var taskDate: UILabel!
    @IBOutlet weak var taskStatus: UILabel!
    
    func setCellValues(task:Task){
        self.taskName.text = task.name
        self.lat.text = String(task.lat)
        self.long.text = String(task.long)
        self.taskDate.text = "05/04/29"// task.createddate
        switch task.status {
        case TaskStatus.started.rawValue:
            self.taskStatus.text = "S"
        case TaskStatus.pending.rawValue:
            self.taskStatus.text = "P"
        case TaskStatus.complete.rawValue:
            self.taskStatus.text = "C"
        default:
            self.taskStatus.text = ""
        }
    }
}
