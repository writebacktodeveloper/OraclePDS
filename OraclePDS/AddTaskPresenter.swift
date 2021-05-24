//
//  AddTaskPresenter.swift
//  OraclePDS
//
//  Created by Arun CP on 24/05/21.
//

import UIKit

protocol AddTaskDelegate : AnyObject {
    func dismissNewTaskPage()
}
class AddTaskPresenter: UIViewController {
    
    private var dbManager = DBHandler()
    var delegate:AddTaskDelegate?
    
    func setViewDelegate(delegate:AddTaskDelegate){
        self.delegate = delegate
    }
    
    public func addNewTask(date:String, name:String, lat:Double, long:Double){
        let task = dbManager.getEntity(Task.self)
        task?.createddate = date
        task?.name = name
        task?.lat = lat
        task?.long = long
        dbManager.save()
        
        delegate?.dismissNewTaskPage()
    }
}
