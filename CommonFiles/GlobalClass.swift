//
//  GlobalClass.swift
//  OraclePDS
//
//  Created by Arun CP on 24/05/21.
//

import UIKit
import Foundation

protocol GlobalDelegate : NSObject {
    func navigateToLogs()
    func logout()
}
final class Global{
    
    private init(){}
    weak var delegate : GlobalDelegate?
    static let sharedInstance = Global()
    private var taskStarted = Bool()
    private var apnsNotificationToken = String()
    private var loggedInUser : String?
//    private let taskDetailPage = TaskDetailView()
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
        return "\(firstChar.capitalized)\(secondChar.capitalized)"
    }
    public func avatarTapped(user:User)->UIAlertController{
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if user.adminuser {
            alert.addAction(UIAlertAction(title: "Show log", style: .cancel, handler: {[weak self] alert in
                self?.delegate?.navigateToLogs()
            }))
            alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: {[weak self] alert in
                self?.delegate?.logout()
            }))
        }else{
            alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: {[weak self] alert in
                self?.delegate?.logout()
            }))
        }

        return alert
    }
    func setLoggedInUserName(userName:String?) {
        self.loggedInUser = userName
    }
    func getLoggedInUserName()->String?{
        return self.loggedInUser
    }
    func setGlobalStatusFlag(status:Bool) {
        self.taskStarted = status
    }
    func getGlobalStatusFlag()->Bool{
        return self.taskStarted
    }
    func setAPNStoken(token:String) {
        self.apnsNotificationToken = token
    }
    func getAPNStoken()->String?{
        return self.apnsNotificationToken
    }
    func showAlert(title:String, message:String)->UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        return alert
    }
    func readLogFromFile()->[String]{
        var logArray = [String]()
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let fileURL = dir.appendingPathComponent("logFile.txt")
            let path = fileURL.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path){
                //reading
                do {
                    let logText = try String(contentsOf: fileURL, encoding: .utf8)
                   logArray = logText.components(separatedBy: "*****")
                    
                }
                catch {
                    print("Error reading file\(error.localizedDescription)")
                }
            }else{
                print("Log file doesn't exist")
            }
        }
        return logArray
    }
    func deleteLogFile(){
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("logFile.txt")
            let path = fileURL.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path){
                do {
                    try fileManager.removeItem(atPath: path)
                } catch {
                    print("Error deleting log file.")
                }
                
            }
        }
    }
  
}
