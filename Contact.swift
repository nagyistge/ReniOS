//
//  Contact.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/31/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import Foundation

class Contact: NSObject {
    var firstName : String
    var lastName : String
    var phonenumber: Array<String>
    var email: Array<String>
    var birthday: Date?
    var thumbnailImage: Data?
    var originalImage: Data?
    
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
}
