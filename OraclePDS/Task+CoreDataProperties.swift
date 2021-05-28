//
//  Task+CoreDataProperties.swift
//  
//
//  Created by Arun CP on 28/05/21.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var barcode: String?
    @NSManaged public var createddate: String?
    @NSManaged public var id: Int32
    @NSManaged public var image: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var name: String?
    @NSManaged public var status: Int16
    @NSManaged public var user: String?

}
