//
//  User+CoreDataProperties.swift
//  OraclePDS
//
//  Created by Arun CP on 23/05/21.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
    @NSManaged public var firstname: String?
    @NSManaged public var lastname: String?
    @NSManaged public var username: String?
    @NSManaged public var password: String?
    @NSManaged public var adminuser: Bool

}

extension User : Identifiable {

}
