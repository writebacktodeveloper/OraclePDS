//
//  TaskListView.swift
//  OraclePDS
//
//  Created by Arun CP on 23/05/21.
//

import UIKit
import CoreData
class TaskListView : UIViewController{
    //MARK:- class outlets
    @IBOutlet weak var imageAvatar: UIImageView!
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tblTaskList: UITableView!
    @IBOutlet weak var lblNoTasksNotification: UILabel!
    @IBOutlet weak var btnAddTask: UIButton!
    @IBOutlet weak var btnShowNotification: UIButton!
    
    //MARK:- Properties
    var user = User()
    var selectedTask = Task()
    let presenter = TaskPresenter()
    private var addTaskVC = AddTaskViewController()
    private var taskList = [Task]()
    //MARK:- ViewDelegates
    override func viewDidLoad() {
        self.setViewElements()
        Log.info("#### Reached task list page")
    }
    override func viewWillAppear(_ animated: Bool) {
        let newDate = self.datePicker.date
        self.loadTasks(newDate: newDate)
    }
    //MARK:- IBActions
    @IBAction func btnActionAvatar(_ sender: UIButton) {
        
    }

    @IBAction func btnActionAddTask(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toAddnewTask", sender: nil)
    }
    @IBAction func btnActionShowNotifications(_ sender: UIButton) {
        guard let notification = Global.sharedInstance.getAPNStoken() else {
            return
        }
       let alert = Global.sharedInstance.showAlert(title: "Token", message: notification)
        self.present(alert, animated: true, completion: nil)
    }
    
}
//MARK:- Extension
extension TaskListView : UITableViewDelegate, UITableViewDataSource{
    //MARK:- Table delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCustomCell", for: indexPath) as! TaskCell
        cell.setCellValues(task: taskList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTask = self.taskList[indexPath.row]
        self.performSegue(withIdentifier: "toTaskDetails", sender: self)
    }
    //MARK:- Functions
    private func setViewElements(){
        //Table delegate
        self.tblTaskList.delegate = self
        self.tblTaskList.dataSource = self
        //Set avatar
        self.btnAvatar.setTitle(Global.sharedInstance.createAvatar(user: user), for: .normal)
        self.imageAvatar.layer.cornerRadius = self.imageAvatar.frame.width / 2
        self.imageAvatar.clipsToBounds = true
        //Set buttons
        btnAddTask.setButtonEnabledTheme()
        btnShowNotification.setButtonEnabledTheme()
        //set datepicker
        self.datePicker.timeZone = .current
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(nil, action: #selector(self.loadTasksForSelectedDate), for: .valueChanged)
        //hide navigation bar
        navigationItem.hidesBackButton = true
    }
    @objc func loadTasksForSelectedDate() {
        let newDate = self.datePicker.date
        self.loadTasks(newDate: newDate)
    }
    private func loadTasks(newDate:Date){
        self.taskList.removeAll()
        self.taskList =  self.presenter.fetchTasksFor(date:newDate)
        //Hide table if there is no tasks
        if (self.taskList.count == 0){
            self.tblTaskList.isHidden = true
            self.lblNoTasksNotification.isHidden = false
        }else{
            self.tblTaskList.isHidden = false
            self.lblNoTasksNotification.isHidden = true
        }
        
        DispatchQueue.main.async {
            self.tblTaskList.reloadData()
        }
    }
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toTaskDetails"{
                let vc = segue.destination as! TaskDetailView
                vc.task = self.selectedTask
                vc.user = self.user
            }
        }
}
