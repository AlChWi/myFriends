//
//  String+extensions.swift
//  My Friends
//
//  Created by Алексей Перов on 27.09.2019.
//  Copyright © 2019 Алексей Перов. All rights reserved.
//

import Foundation

extension String {
     func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
    func isValidPhoneNumber() -> Bool {
        let phoneRexEx = "^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\\s\\./0-9]*$"
        
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRexEx)
        return phonePredicate.evaluate(with: self)
    }
}
