//
//  GlobalClass.swift
//  OraclePDS
//
//  Created by Arun CP on 24/05/21.
//

import UIKit
import Foundation
final class Global{
    
    static let sharedInstance = Global()
    private init(){}
    private var taskStarted = Bool()
    func formatDate(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    public func createAvatar(user:User)->String?{
        guard let firstName = user.firstname else {
            return nil
        }
        guard let lastName = user.lastname else {
            return nil
        }
        let firstChar = firstName.prefix(1)
        let secondChar = lastName.prefix(1)
        return "\(firstChar)\(secondChar)"
    }
    
    func setGlobalStatusFlag(status:Bool) {
        self.taskStarted = status
    }
    func getGlobalStatusFlag()->Bool{
        return self.taskStarted
    }

    func showAlert(title:String, message:String)->UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        return alert
    }
}
