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
    private var loggedInUser = Global.sharedInstance.getLoggedInUserName()
    var delegate:AddTaskDelegate?
    
    func setViewDelegate(delegate:AddTaskDelegate){
        self.delegate = delegate
    }
    
    public func addNewTask(date:String, name:String, lat:Double, long:Double){
        let task = dbManager.getEntity(Task.self)
        task?.id = Int32.random(in: 0...999)
        task?.createddate = date
        task?.name = name
        task?.lat = lat
        task?.long = long
        task?.status = TaskStatus.pending.rawValue
        task?.user = loggedInUser
        dbManager.save()
        
        delegate?.dismissNewTaskPage()
    }
}
