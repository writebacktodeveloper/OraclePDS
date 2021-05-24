//
//  TaskDetailView.swift
//  OraclePDS
//
//  Created by Arun CP on 24/05/21.
//

import Foundation
import  UIKit

class TaskDetailView: UIViewController {
    
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var lblTaskName: UILabel!
    @IBOutlet weak var lblLatitude: UILabel!
    @IBOutlet weak var lblLongitude: UILabel!
    @IBOutlet weak var lblBarcode: UILabel!
    @IBOutlet weak var imageViewProduct: UIImageView!
    
    var user = User()
    var task = Task()
    var taskStatus : TaskStatus?
    var taskDetailViewPresenter = TaskDetailViewPresenter()

    override func viewDidLoad() {
        self.setViewElements()
    }
    func setViewElements(){
        guard let firstName = user.firstname, let lastName = user.lastname else {
            return
        }
        self.lblTaskName.text = "\(firstName) \(lastName)"
        self.lblTitle.text = "\( taskDetailViewPresenter.highlightTaskStatus(status: task.status))\(self.task.name!)"
        self.lblLatitude.text = String(self.task.lat)
        self.lblLongitude.text = String(self.task.long)
        self.btnAvatar.setTitle(Global.sharedInstance.createAvatar(user: user), for: .normal)
        self.imageViewAvatar.layer.cornerRadius = self.imageViewAvatar.frame.width / 2
        self.imageViewAvatar.clipsToBounds = true
        self.enableOrDisableButtons()
        self.btnStart.isEnabled = !Global.sharedInstance.getGlobalStatusFlag()
    }
    
    func enableOrDisableButtons(){
        let buttonStatus = taskDetailViewPresenter.setButtonStatus(status: task.status)
        self.btnStart.isEnabled = buttonStatus.0
        self.btnCancel.isEnabled = buttonStatus.1
        self.btnComplete.isEnabled = buttonStatus.2
    }
    
    @IBAction func btnActionStart(_ sender: UIButton) {
        self.task.status = TaskStatus.started.rawValue
        self.enableOrDisableButtons()//This should be called after setting task
        taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
        Global.sharedInstance.setGlobalStatusFlag(status: true)
    }
    @IBAction func btnActionCancel(_ sender: UIButton) {
        self.task.status = TaskStatus.cancel.rawValue
        self.enableOrDisableButtons()//This should be called after setting task
        taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
        Global.sharedInstance.setGlobalStatusFlag(status: false)
    }
    @IBAction func btnActionComplete(_ sender: UIButton) {
        self.task.status = TaskStatus.complete.rawValue
        self.enableOrDisableButtons()//This should be called after setting task
        taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
        Global.sharedInstance.setGlobalStatusFlag(status: false)
    }
    
    
    
}
