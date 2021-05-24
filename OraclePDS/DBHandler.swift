//
//  DBHandler.swift
//  OraclePDS
//
//  Created by Arun CP on 23/05/21.
//

import UIKit
import CoreData

class DBHandler {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getEntity<T:NSManagedObject>(_ type: T.Type) -> T? {
        guard let entityName = T.entity().name else {return nil}
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return nil }
        let object = T.init(entity: entity, insertInto: context)
        return object
    }
    func fetchAll<T: NSManagedObject>(_ type : T.Type)->[T]{
        let request = T.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results as! [T]
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    func fetchRecord<T: NSManagedObject>(_ type : T.Type, date:String)->[T]{
        let request = T.fetchRequest()
        request.predicate = NSPredicate(format: "createddate == %@", date)
        do {
            let results = try context.fetch(request)
            return results as! [T]
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func fetchSingleRecord<T: NSManagedObject>(_ type : T.Type, date:String, id:Int32)->T{
        let request = T.fetchRequest()
        request.predicate = NSPredicate(format: "createddate == %@ AND id == %i", date, id)
        do {
            let results = try context.fetch(request)
            return results.first as! T
        } catch {
            print(error.localizedDescription)
            return T.self as! T
        }
    }
    func save(){
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
