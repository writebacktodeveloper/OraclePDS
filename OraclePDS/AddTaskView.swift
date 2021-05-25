//
//  AddTaskView.swift
//  OraclePDS
//
//  Created by Arun CP on 24/05/21.
//

import UIKit

class AddTaskViewController: UIViewController, AddTaskDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var txtTaskName: UITextField!
    @IBOutlet weak var txtLat: UITextField!
    @IBOutlet weak var txtLong: UITextField!
    
    let presenter = AddTaskPresenter()

    override func viewDidLoad() {
        self.txtTaskName.delegate = self
        self.txtLat.delegate = self
        self.txtLong.delegate = self
        //set view delegate for the presenter
        presenter.setViewDelegate(delegate: self)
    }
    @IBAction func btnActionDone(_ sender: UIButton) {
        
        guard let name = txtTaskName.text, let latitude = txtLat.text, let longi = txtLong.text, name != "", latitude != "", longi != "" else {
            return
        }
        let dateValue = Global.sharedInstance.formatDate(date:self.datePicker.date)
        let latDouble = Double(latitude)!
        let longiDouble = Double(longi)!
        self.presenter.addNewTask(date: dateValue, name: name, lat: latDouble, long: longiDouble)
    }
    func dismissNewTaskPage() {
//        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
extension AddTaskViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
