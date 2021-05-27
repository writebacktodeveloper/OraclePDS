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
    @IBOutlet weak var enableFIngerprint: UISwitch!
    @IBOutlet weak var btnLogin: UIButton!
    
    //DB instance
    let dbManager = DBHandler()
    //Presenter instance
    let loginPresenter = LoginPresenter()
    //Logged in user
    var loggedInUser : User?
    override func viewWillAppear(_ animated: Bool) {
        self.loginPresenter.biometricAuthentication()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.userNameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.adminSwitch.isHidden = true
        self.registerLabel.isHidden = true
        self.firstNameTextField.isHidden = true
        self.lastNameTextField.isHidden = true
        self.loginPresenter.setViewDelegate(delegate: self)
        self.btnLogin.setButtonEnabledTheme()
        let results = self.dbManager.fetchAll(User.self)
        for result in results{
            print("***********")
            print("user \(result)")
        }
    }
    @IBAction func btnActionRegister(_ sender: UISwitch) {
        UIView.animate(withDuration: 1.5) {
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
        self.registerSwitch.isOn = false
        self.adminSwitch.isHidden = true
        self.registerLabel.isHidden = true
        self.firstNameTextField.isHidden = true
        self.lastNameTextField.isHidden = true
    }
 
    func registerUser(){
        let isAdmin = adminSwitch.isOn ? true : false
        let isBiometricEnabled = enableFIngerprint.isOn ? true : false
        
        guard let firstName = self.firstNameTextField.text, let lastName = self.lastNameTextField.text, let userName = self.userNameTextField.text, let password = self.passwordTextField.text, firstName != "", lastName != "", userName != "", password != "" else { return }
        self.loginPresenter.addUser(firstName: firstName, lastName: lastName, userName: userName, password: password, isAdmin: isAdmin, enableBiometrics: isBiometricEnabled)
    }
    
    func authenticateUser(){
        guard let userName = self.userNameTextField.text, let password = self.passwordTextField.text, userName != "", password != "" else { return }
        self.loginPresenter.authenticate(useName: userName, password: password)
    }
    
}

extension LoginView : LoginPresenterDelegate{
    
    func authenticationSuccess(user: User) {
        DispatchQueue.main.async {
        self.loggedInUser = user
        Global.sharedInstance.setLoggedInUserName(userName: user.username)
        self.performSegue(withIdentifier: "loginToTaskListView", sender: self)
        }
    }
    func registrationSuccess(user: User) {
        DispatchQueue.main.async {
        self.loggedInUser = user
        Global.sharedInstance.setLoggedInUserName(userName: user.username)
        self.performSegue(withIdentifier: "loginToTaskListView", sender: user)
        }
    }
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?) {
        if segue.identifier == "loginToTaskListView"{
            let vc = segue.destination as! TaskListView
            guard let loggedIn = self.loggedInUser else {
                return
            }
            vc.user = loggedIn
        }
    }
}
extension LoginView : UITextFieldDelegate{
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

    }
}
