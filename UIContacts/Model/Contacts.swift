//
//  Contacts.swift
//  UIContacts
//
//  Created by Praveen on 29/11/18.
//

import Foundation
import CoreData

struct Contact {
    var firstName:String?
    var lastName:String?
    var contactImage: Data?
    var country: String?
    var email: String?
    var mobileNumber: String?
    init(detail:NSManagedObject) {
        if let imageData = detail.value(forKey: "contactImage") as? Data, let firstName = detail.value(forKey: "firstName") as? String, let lastName = detail.value (forKey: "lastName") as? String,let mobileNumber = detail.value(forKey: "mobileNumber") as? String, let country = detail.value(forKey: "country") as? String,let email = detail.value(forKey: "email") as? String {
            self.contactImage = imageData
            self.firstName = firstName
            self.lastName = lastName
            self.country = country
            self.email = email
            self.mobileNumber = mobileNumber
        } else {
            self.contactImage = nil
            self.firstName = ""
            self.lastName = ""
            self.country = ""
            self.email = ""
            self.mobileNumber = ""
        }

    }
}
