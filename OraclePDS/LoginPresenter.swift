//
//  LoginPresenter.swift
//  OraclePDS
//
//  Created by Arun CP on 23/05/21.
//

import Foundation
import LocalAuthentication

protocol LoginPresenterDelegate : AnyObject{
    func authenticationSuccess(user:User)
    func registrationSuccess(user:User)
    func showAlert(title:String, message:String)
}
class LoginPresenter {
    //Set delegate
    weak var delegate : LoginPresenterDelegate?
    
    private let dbManager = DBHandler()
    
    public func setViewDelegate(delegate:LoginPresenterDelegate){
        self.delegate = delegate
    }
    
    public func authenticate(useName:String, password:String){
        let results = dbManager.fetchAll(User.self)
        for user in results {
            if (user.username == useName && user.password == password){
                self.delegate?.authenticationSuccess(user: user)
                return
            }
        }
        self.delegate?.showAlert(title: "Attention!", message: "Authentication failed!")
    }
    public func biometricAuthentication(){
        let results = dbManager.fetchAll(User.self)
        if results.count == 0 {
            return
        }
        for user in results {
            if (user.biometric){
                self.enableFingerprintId(loggedInUser: user)
                print("FingerPrint: Found biometric enabled user")
                break
            }
        }
    }
    private func enableFingerprintId(loggedInUser : User){
        //Enable touch id
        let context = LAContext()
        var error : NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Login using touch id!") { success, authenticationError in
                if success {
                    self.delegate?.authenticationSuccess(user: loggedInUser)
                }else{
                    self.delegate?.showAlert(title: "Attention!", message: "Biometric authentication failed. Please try again")
                }
            }
        }else{//User didn't have enabled biometric authentication
            self.delegate?.showAlert(title: "Attention!", message: "You don't have permission to use biometrics. Please add your biometrics in device.")
        }
    }
    public func addUser(firstName:String, lastName:String, userName:String, password:String, isAdmin:Bool, enableBiometrics:Bool){
        
        if enableBiometrics {
            let context = LAContext()
            var error : NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Place your finger on touch pad!") { success, authenticationError in
                    if success {
                        self.createUser(firstName: firstName, lastName: lastName, userName: userName, password: password, isAdmin: isAdmin, enableBiometrics: success)
                    }else{
                        self.delegate?.showAlert(title: "Attention!", message: "Biometric authentication failed. Please try again")
                    }
                }
            }else{
                self.delegate?.showAlert(title: "Attention!", message: "You don't have permission to use biometrics. Please add your biometrics in device.")
            }
        }else{
            self.createUser(firstName: firstName, lastName: lastName, userName: userName, password: password, isAdmin: isAdmin, enableBiometrics: enableBiometrics)
        }
    }
    private func createUser(firstName:String, lastName:String, userName:String, password:String, isAdmin:Bool, enableBiometrics:Bool){
        guard let user = self.dbManager.getEntity(User.self) else{return}
        user.firstname = firstName
        user.lastname = lastName
        user.username = userName
        user.password = password
        user.adminuser = isAdmin
        user.biometric = enableBiometrics
        self.dbManager.save()
        self.delegate?.registrationSuccess(user: user)
    }
}
