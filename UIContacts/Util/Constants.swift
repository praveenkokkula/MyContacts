//
//  Constants.swift
//  UIContacts
//
//  Created by Praveen on 01/12/18.
//

import Foundation
let FirstName = "firstName"
let LastName = "lastName"
let Country = "country"
let Email = "email"
let MobileNumber = "mobileNumber"
let ContactImage = "contactImage"
let CountryCellIdentifier = "countryCell"
let ContactCellIdentifier = "contactsCell"
let CountryListAPI = "https://restcountries.eu/rest/v1/all"
let NameValidator = "Enter a Valid Name"
let EmailValidator = "Enter a Valid Email"
let MobileNumberValidator = "Enater a Valid Mobile Number"
let CountryBtnName = "Select Country"
let ContactEntity = "Contacts"

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

