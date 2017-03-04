//
//  Contact.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/31/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import Foundation
import Contacts

class Contact: NSObject {
    var firstName : String
    var lastName : String
    var phonenumber = [String]()
    var email = [String]()
    var birthday: Date?
    var thumbnailImage: Data?
    var originalImage: Data?
    var image: UIImage?
    
    // these two contain emails and phones in <label> = <value> format
    var emailsArray: Array<Dictionary<String, String>>?
    var phonesArray: Array<Dictionary<String, String>>?
    
    override var description: String { get {
        return "\(firstName) \(lastName) \nBirthday: \(birthday) \nPhones: \(phonesArray) \nEmails: \(emailsArray)\n\n"}
    }
    
    init(firstName: String, lastName: String, birthday: Date?, phonenumber: Array<String>, email: Array<String>) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthday = birthday
        self.phonenumber = phonenumber
        self.email = email
    }
    
    @available(iOS 9.0, *)
    init?(cnContact: CNContact) {
        // name
        if !cnContact.isKeyAvailable(CNContactGivenNameKey) && !cnContact.isKeyAvailable(CNContactFamilyNameKey) { return nil }
        self.firstName = (cnContact.givenName)
        self.lastName = cnContact.familyName
        // image
        self.image = (cnContact.isKeyAvailable(CNContactImageDataKey) && cnContact.imageDataAvailable) ? UIImage(data: cnContact.imageData!) : nil
        // email
        if cnContact.isKeyAvailable(CNContactEmailAddressesKey) {
            for possibleEmail in cnContact.emailAddresses {
                let properEmail = possibleEmail.value as String
                if properEmail.isEmail() { self.email.append(properEmail); break }
            }
        }
        // phone
        if cnContact.isKeyAvailable(CNContactPhoneNumbersKey) {
            if cnContact.phoneNumbers.count > 0 {
                let phone = cnContact.phoneNumbers.first?.value
                self.phonenumber.append((phone?.stringValue)!)
            }
        }
    }
}
