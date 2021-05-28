//
//  AddTaskView.swift
//  OraclePDS
//
//  Created by Arun CP on 24/05/21.
//

import UIKit

class AddTaskViewController: UIViewController, AddTaskDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var txtTaskName: UITextField!
    @IBOutlet weak var txtLat: UITextField!
    @IBOutlet weak var txtLong: UITextField!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnLocation: UIButton!
    let presenter = AddTaskPresenter()

    override func viewDidLoad() {
        Log.info("#### Reached add task page")
        self.btnLocation.setButtonEnabledTheme()
        self.btnDone.setButtonEnabledTheme()
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
    @IBAction func btnLocationTap(_ sender: UIButton) {
        LocationManager.shared.getUserLocation { [weak self] location in
            DispatchQueue.main.async {
                self?.txtLat.text = String(location.coordinate.latitude)
                self?.txtLong.text = String(location.coordinate.longitude)
            }
        }
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.view.frame.origin.y = -60
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.view.frame.origin.y = 0
        }
        guard let title = self.txtTaskName.text else {
            return
        }
        self.titleLabel.text = title
    }
}
