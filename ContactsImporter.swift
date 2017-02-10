//
//  ContactsImporter.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/31/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import Foundation

import AddressBook
import UIKit

class ContactsImporter {
    
    fileprivate class func extractABAddressBookRef(_ abRef: Unmanaged<ABAddressBook>!) -> ABAddressBook? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    class func importContacts(_ callback: @escaping (Array<Contact>) -> Void) {
        if(ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.denied || ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.restricted) {
            let alert = UIAlertView(title: "Address Book Access Denied", message: "Please grant us access to your Address Book in Settings -> Privacy -> Contacts", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.notDetermined) {
            var errorRef: Unmanaged<CFError>? = nil
            let addressBook: ABAddressBook? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
            ABAddressBookRequestAccessWithCompletion(addressBook, { (accessGranted: Bool, error: CFError!) -> Void in
                if(accessGranted) {
                    let contacts = self.copyContacts()
                    callback(contacts)
                }
            })
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.authorized) {
            let contacts = self.copyContacts()
            callback(contacts)
        }
    }
    
    class func copyContacts() -> Array<Contact> {
        var errorRef: Unmanaged<CFError>? = nil
        let addressBook: ABAddressBook? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        let contactsList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
        print("\(contactsList.count) records in the array")
        
        var importedContacts = Array<Contact>()
        
        for record:ABRecord in contactsList {
            let contactPerson: ABRecordRef = record
            
            var firstName:String = ""
            
            if let firstNameTemp = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty){
                firstName += Unmanaged<NSObject>.fromOpaque(firstNameTemp.toOpaque()).takeRetainedValue() as! NSString as String
            }
            else{
                
            }
            
            
            var lastName:String = ""
            
            if let lastNameTemp = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty){
                lastName += Unmanaged<NSObject>.fromOpaque(lastNameTemp.toOpaque()).takeRetainedValue() as! NSString as String
            }
            else{
                
            }
            

        /*
            if let lastName = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty).takeRetainedValue() as! NSString{
                lastName1 += lastName as String
            }else{
                //let lastName1 = ""
            }
            */
            print("-------------------------------")
            print("\(firstName) \(lastName)")
            
            let phonesRef: ABMultiValueRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty).takeRetainedValue() as ABMultiValueRef
            var phonesArray  = Array<Dictionary<String,String>>()
            var phones:Array<String> = Array<String>()
            for var i:Int = 0; i < ABMultiValueGetCount(phonesRef); i++ {
                let label: String = ABMultiValueCopyLabelAtIndex(phonesRef, i).takeRetainedValue() as NSString as String
                let value: String = ABMultiValueCopyValueAtIndex(phonesRef, i).takeRetainedValue() as! NSString as String
                
                print("Phone: \(label) = \(value)")
                
                let phone = [label: value]
                phonesArray.append(phone)
                phones.append(value)
            }
            
            print("All Phones: \(phonesArray)")
            var email1:Array<String> = Array<String>()
            let emailsRef: ABMultiValueRef = ABRecordCopyValue(contactPerson, kABPersonEmailProperty).takeRetainedValue() as ABMultiValueRef
            var emailsArray = Array<Dictionary<String, String>>()
            for var i:Int = 0; i < ABMultiValueGetCount(emailsRef); i++ {
                let label = "no one"
                let value = "uses email"
                
                print("Email: \(label) = \(value)")
                
                let email = [label: value]
                emailsArray.append(email)
                email1.append(value)
            }
            
            print("All Emails: \(emailsArray)")

            
            var thumbnail: Data? = nil
            var original: Data? = nil
            if ABPersonHasImageData(contactPerson) {
                thumbnail = ABPersonCopyImageDataWithFormat(contactPerson, kABPersonImageFormatThumbnail).takeRetainedValue() as Data
                original = ABPersonCopyImageDataWithFormat(contactPerson, kABPersonImageFormatOriginalSize).takeRetainedValue() as Data
            }
            
            let currentContact = Contact(firstName: firstName, lastName: lastName, birthday: Date(), phonenumber: phones, email: email1)
            currentContact.phonesArray = phonesArray
            currentContact.emailsArray = emailsArray
            currentContact.thumbnailImage = thumbnail
            currentContact.originalImage = original
            currentContact.phonenumber = phones
            currentContact.email = email1
            importedContacts.append(currentContact)
            
        }
        
        return importedContacts
    }
    
}
