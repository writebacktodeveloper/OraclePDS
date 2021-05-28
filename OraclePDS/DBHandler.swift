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
    func fetchRecord<T: NSManagedObject>(_ type : T.Type, date:String, user:String)->[T]{
        let request = T.fetchRequest()
        request.predicate = NSPredicate(format: "createddate == %@ AND user == %@", date, user)
        do {
            let results = try context.fetch(request)
            return results as! [T]
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func fetchSingleRecord<T: NSManagedObject>(_ type : T.Type, date:String, id:Int32, user:String)->T{
        let request = T.fetchRequest()
        request.predicate = NSPredicate(format: "createddate == %@ AND id == %i AND user == %@", date, id, user)
        do {
            let results = try context.fetch(request)
            return results.first as! T
        } catch {
            print(error.localizedDescription)
            return T.self as! T
        }
    }
    func fetchHistoryRecords<T: NSManagedObject>(_ type : T.Type, id:Int32, user:String, completion:(([T]?)->Void)){
        let request = T.fetchRequest()
        request.predicate = NSPredicate(format: "id == %i AND user == %@", id, user)
        do {
            let results = try context.fetch(request) as? [T]
            completion(results)
        } catch {
            print(error.localizedDescription)
            completion(nil)
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
