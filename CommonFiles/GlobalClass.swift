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
    
    func formatDate(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return dateString
    }
}
