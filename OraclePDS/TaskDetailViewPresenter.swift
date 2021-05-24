//
//  TaskDetailViewPresenter.swift
//  OraclePDS
//
//  Created by Arun CP on 24/05/21.
//

import UIKit

class TaskDetailViewPresenter: UIViewController {
    
    private let dbManager = DBHandler()
    
    func setButtonStatus(status:Int16)->(Bool,Bool,Bool){
        switch status {
        case TaskStatus.started.rawValue:
            return (false,true,true)
        case TaskStatus.pending.rawValue:
            return (true,false,false)
        case TaskStatus.cancel.rawValue:
            return (false,false,false)
        case TaskStatus.complete.rawValue:
            return (false,false,false)
        default:
            return (true, true, true)
        }
    }
    
    func highlightTaskStatus(status : Int16)->String{
        switch status {
        case TaskStatus.started.rawValue:
            return "Started : "
        case TaskStatus.pending.rawValue:
            return "Pending : "
        case TaskStatus.cancel.rawValue:
            return "Cancelled : "
        case TaskStatus.complete.rawValue:
            return "Completed : "
        default:
            return " "
        }
    }
    func changeTaskState(updatedTask:Task){
        let object = dbManager.fetchSingleRecord(Task.self, date: updatedTask.createddate!, id: updatedTask.id)
        object.id = updatedTask.id
        object.name = updatedTask.name
        object.createddate = updatedTask.createddate
        object.status = updatedTask.status
        object.lat = updatedTask.lat
        object.long = updatedTask.long
        object.barcode = updatedTask.barcode
        object.image = updatedTask.image
        
        //Save data
        dbManager.save()
    }
}
