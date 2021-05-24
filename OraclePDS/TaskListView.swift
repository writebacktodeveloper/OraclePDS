//
//  TaskListView.swift
//  OraclePDS
//
//  Created by Arun CP on 23/05/21.
//

import UIKit

class TaskListView : UIViewController{
    
    @IBOutlet weak var imageAvatar: UIImageView!
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var tblTaskList: UITableView!
    @IBOutlet weak var lblNoTasksNotification: UILabel!
    
    
    var user = User()
    let presenter = TaskPresenter()
    private var taskList = [Task]()
    override func viewDidLoad() {
        self.tblTaskList.delegate = self
        self.tblTaskList.dataSource = self
        
        self.btnAvatar.titleLabel?.text = "\(String(describing: user.firstname?.startIndex)) \(String(describing: user.lastname?.startIndex))"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.taskList =  self.presenter.fetchTasksFor(date: Date())
    }
    
    @IBAction func btnActionAvatar(_ sender: UIButton) {
        
    }
    @IBAction func btnActionDate(_ sender: UIButton) {
    }
    @IBAction func btnActionAddTask(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toAddnewTask", sender: nil)
    }
    @IBAction func btnActionShowNotifications(_ sender: UIButton) {
    }
    
}
extension TaskListView : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCustomCell", for: indexPath) as! TaskCell
        cell.setCellValues(task: taskList[indexPath.row])
        return cell
    }
    
    
    
}
