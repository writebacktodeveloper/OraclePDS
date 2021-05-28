//
//  TaskDetailViewPresenter.swift
//  OraclePDS
//
//  Created by Arun CP on 24/05/21.
//

import UIKit
import CoreLocation
class TaskDetailViewPresenter: UIViewController {
    
    private let dbManager = DBHandler()
    private let loggedInUser = Global.sharedInstance.getLoggedInUserName()
    func setButtonStatus(status:Int16)->(Bool,Bool,Bool){
        let startedTaskAvailable = Global.sharedInstance.getGlobalStatusFlag()
        switch status {
        case TaskStatus.started.rawValue:
            return (false,true,true)
        case TaskStatus.pending.rawValue:
            if startedTaskAvailable {
                return (false,false,false)
            }else{
                return (true,false,false)}
        case TaskStatus.cancel.rawValue:
            return (false,false,false)
        case TaskStatus.complete.rawValue:
            return (false,false,false)
        default:
            return (true, true, true)
        }
    }
    
    func highlightTaskStatus(status : Int16)->String{
        switch status {
        case TaskStatus.started.rawValue:
            return "Started : "
        case TaskStatus.pending.rawValue:
            return "Pending : "
        case TaskStatus.cancel.rawValue:
            return "Cancelled : "
        case TaskStatus.complete.rawValue:
            return "Completed : "
        default:
            return " "
        }
    }
    func changeTaskState(updatedTask:Task){
        let object = dbManager.fetchSingleRecord(Task.self, date: updatedTask.createddate!, id: updatedTask.id, user: loggedInUser!)
        object.id = updatedTask.id
        object.name = updatedTask.name
        object.createddate = updatedTask.createddate
        object.status = updatedTask.status
        object.lat = updatedTask.lat
        object.long = updatedTask.long
        object.barcode = updatedTask.barcode
        object.image = updatedTask.image
        object.user = loggedInUser
        
        //Save data
        dbManager.save()
    }
    
    func encodeImage(image:UIImage)->String?{
        let imageData = image.jpegData(compressionQuality: 1)
        guard let imageBase64String = imageData?.base64EncodedString() else {
            return nil
        }
        return imageBase64String
    }
    
    func decodeImage(imageString:String)->UIImage?{
        let imageData = Data(base64Encoded: imageString)
        if let newImage = imageData{
            return UIImage(data: newImage, scale: 1.0)
        }
        return nil
    }
    func setUserLocationToHistoricRecords(user:String, id:Int32, location:CLLocation){
        
        let locationObject = dbManager.getEntity(TaskLocation.self)
        locationObject?.id = id
        locationObject?.user = user
        locationObject?.lat = location.coordinate.latitude
        locationObject?.long = location.coordinate.longitude
        
        dbManager.save()
    }
    func getHistoricRecords(user:String, id:Int32)->[CLLocation]{
        var historyLocations = [CLLocation]()
        dbManager.fetchHistoryRecords(TaskLocation.self, id: id, user: user) { locations in
            guard let all = locations else { return}
            for each in all{
                let cordinate = CLLocation(latitude: each.lat, longitude: each.long)
                historyLocations.append(cordinate)
            }
        }
        return historyLocations
    }
}
