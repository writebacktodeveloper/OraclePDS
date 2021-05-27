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
    private let loggedInUser = Global.sharedInstance.getLoggedInUserName()

    public func fetchTasksFor(date:Date)-> [Task]{
        let dateString = Global.sharedInstance.formatDate(date: date)
        let results = dbManager.fetchRecord((Task.self), date: dateString, user: loggedInUser!)
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
            print("Barcode \(String(describing: task.barcode))")
            print("######")
        }
        return results
    }
}
