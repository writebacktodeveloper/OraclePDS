//
//  ButtonExtension.swift
//  OraclePDS
//
//  Created by Arun CP on 25/05/21.
//

import UIKit
extension UIButton {
    func setButtonEnabledTheme(){
        layer.borderWidth = 1.25
        layer.borderColor = tintColor.cgColor
        layer.cornerRadius = 2.2
        clipsToBounds = true
        isEnabled = true
    }
    func setButtonDisabledTheme(){
        layer.borderWidth = 1.25
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 2.2
        clipsToBounds = true
        isEnabled = false
    }
}
