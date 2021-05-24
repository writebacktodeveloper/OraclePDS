//
//  ViewController.swift
//  OraclePDS
//
//  Created by Arun CP on 22/05/21.
//

import UIKit

class LoginView: UIViewController {
    @IBOutlet weak var registerSwitch: UISwitch!
    @IBOutlet weak var adminSwitch: UISwitch!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var userNameTextField : UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //DB instance
    let dbManager = DBHandler()
    //Presenter instance
    let loginPresenter = LoginPresenter()
    //Logged in user
    private var loggedInUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.adminSwitch.isHidden = true
        self.registerLabel.isHidden = true
        self.firstNameTextField.isHidden = true
        self.lastNameTextField.isHidden = true
        
        self.loginPresenter.setViewDelegate(delegate: self)
        let results = self.dbManager.fetchAll(User.self)
        print(results.map({$0.username}))
        print(results.map({$0.password}))
        print(results.map({$0.adminuser}))
    }
    @IBAction func btnActionRegister(_ sender: UISwitch) {
        if sender.isOn{
            self.adminSwitch.isHidden = false
            self.registerLabel.isHidden = false
            self.firstNameTextField.isHidden = false
            self.lastNameTextField.isHidden = false
        }else{
            self.adminSwitch.isHidden = true
            self.registerLabel.isHidden = true
            self.firstNameTextField.isHidden = true
            self.lastNameTextField.isHidden = true
        }
    }
    
    @IBAction func btnActionRegisterAsAdmin(_ sender: UISwitch) {
    }
    
    @IBAction func btnActionLogin(_ sender: Any) {
        let isRegistering = self.registerSwitch.isOn
        if isRegistering {
            self.registerUser()
        }else{
        self.authenticateUser()
        }
    }
 
    func registerUser(){
        let isAdmin = adminSwitch.isOn ? true : false
        
        guard let firstName = self.firstNameTextField.text, let lastName = self.lastNameTextField.text, let userName = self.userNameTextField.text, let password = self.passwordTextField.text, firstName != "", lastName != "", userName != "", password != "" else { return }
        self.loginPresenter.addUser(firstName: firstName, lastName: lastName, userName: userName, password: password, isAdmin: isAdmin)
    }
    
    func authenticateUser(){
        guard let userName = self.userNameTextField.text, let password = self.passwordTextField.text, userName != "", password != "" else { return }
        self.loginPresenter.authenticate(useName: userName, password: password)
    }
    
}

extension LoginView : LoginPresenterDelegate{
    
    func authenticationSuccess(user: User) {
        self.loggedInUser = user
        self.performSegue(withIdentifier: "loginToTaskListView", sender: self)
    }
    func registrationSuccess(user: User) {
        self.loggedInUser = user
        self.performSegue(withIdentifier: "loginToTaskListView", sender: user)
    }
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?) {
        if segue.identifier == "loginToTaskListView"{
            let vc = segue.destination as! TaskListView
            vc.user = self.loggedInUser
        }
    }
}

