//
//  LoginPresenter.swift
//  OraclePDS
//
//  Created by Arun CP on 23/05/21.
//

import Foundation

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
    
    public func addUser(firstName:String, lastName:String, userName:String, password:String, isAdmin:Bool){
        guard let user = dbManager.getEntity(User.self) else{return}
        user.firstname = firstName
        user.lastname = lastName
        user.username = userName
        user.password = password
        user.adminuser = isAdmin
        dbManager.save()
        
        self.delegate?.registrationSuccess(user: user)
    }
}
