//
//  TaskLocation+CoreDataProperties.swift
//  
//
//  Created by Arun CP on 28/05/21.
//
//

import Foundation
import CoreData


extension TaskLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskLocation> {
        return NSFetchRequest<TaskLocation>(entityName: "TaskLocation")
    }

    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var id: Int32
    @NSManaged public var user: String?

}
