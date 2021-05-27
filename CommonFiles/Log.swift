//
//  Log.swift
//  OraclePDS
//
//  Created by Arun CP on 26/05/21.
//

import UIKit

func print(_ object: Any) {
    // Only allowing in DEBUG mode
    #if DEBUG
    Swift.print(object)
    #endif
}

class Log {
    
    static let file = "logFile.txt" //this is the file. we will write to and read from it
    static let userName = Global.sharedInstance.getLoggedInUserName()
    //Format date
    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    private static var isLoggingEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    class func info( _ object: Any, filename: String = #file, funcName: String = #function) {
        if isLoggingEnabled {
            let logText = "Datetime : \(Date().toString())\nFile Name : \(sourceFileName(filePath: filename))\nEvent type : \(funcName)\nUserName :\(userName ?? "")\n*****"
            self.writeToFile(logText: logText)
        }
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
    
    private class func writeToFile(logText:String){
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            let path = fileURL.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path){
                self.appendToExistingLogFile(fileURL: fileURL, logText: logText)
            }else{
                self.createNewFileAndWrite(fileURL: fileURL, newText: logText)
            }
        }
    }
    private class func appendToExistingLogFile(fileURL : URL, logText : String){
        do {
            let existingText = try String(contentsOf: fileURL, encoding: .utf8)
            let newText = "\(existingText)\n\(logText)"
            try newText.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch {
            print("Error writing to file\(error.localizedDescription)")
        }
    }
    private class func createNewFileAndWrite(fileURL : URL, newText : String){
        do {
            try newText.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch {
            print("Error writing to file\(error.localizedDescription)")
        }
    }
}
    internal extension Date {
    func toString() -> String {
        return Log.dateFormatter.string(from: self as Date)
    }
}
