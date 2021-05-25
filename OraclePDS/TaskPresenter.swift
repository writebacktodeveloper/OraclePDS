//
//  TaskPresenter.swift
//  OraclePDS
//
//  Created by Arun CP on 23/05/21.
//

import UIKit

public enum TaskStatus : Int16 {
    case pending = 0, started, cancel, complete
}
class TaskPresenter: UIViewController {
   
    private let dbManager = DBHandler()
    

    public func fetchTasksFor(date:Date)-> [Task]{
        let dateString = Global.sharedInstance.formatDate(date: date)
        let results = dbManager.fetchRecord((Task.self), date: dateString)
        for task in results {
            
            if (task.status == TaskStatus.started.rawValue){
                Global.sharedInstance.setGlobalStatusFlag(status: true)
//                break
            }
            print("Name \(task.name!)")
            print("Status \(task.status)")
            print("lat \(task.lat)")
            print("lon \(task.long)")
            print("created date \(task.createddate!)")
            print("Barcode \(task.barcode)")
            print("######")
        }
        return results
    }
}
