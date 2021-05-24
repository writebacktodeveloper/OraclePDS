//
//  TaskPresenter.swift
//  OraclePDS
//
//  Created by Arun CP on 23/05/21.
//

import UIKit

public enum TaskStatus : Int16 {
    case started = 0, pending, complete
}
class TaskPresenter: UIViewController {
   
    private let dbManager = DBHandler()
    
    public func fetchTasksFor(date:Date)-> [Task]{
        let dateString = Global.sharedInstance.formatDate(date: date)
        let results = dbManager.fetchRecord((Task.self), date: dateString)
        return results
    }
}
