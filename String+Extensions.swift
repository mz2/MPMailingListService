//
//  String+Extensions.swift
//  MPMailingListService
//
//  Created by Matias Piipari on 09/09/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

import Foundation

public extension String {
    
    // See discussion at http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    // static let stricterEmailRegex = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
    static let emailRegex = ".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*"
    static let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    
    var isValidEmailAddress:Bool {
        return self.dynamicType.emailTest.evaluateWithObject(self)
    }
}
