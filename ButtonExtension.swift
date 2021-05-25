//
//  ButtonExtension.swift
//  OraclePDS
//
//  Created by Arun CP on 25/05/21.
//

import UIKit
extension UIButton {
    func setButtonTheme(){
        layer.borderWidth = 1
        layer.borderColor = UIColor.blue.cgColor
        layer.cornerRadius = 2.2
        clipsToBounds = true
    }
}
