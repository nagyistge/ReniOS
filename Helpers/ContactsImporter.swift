//
//  ContactsImporter.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/31/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import Foundation
import Contacts
import AddressBook
import UIKit

@available(iOS 9.0, *)
class ContactsImporter {
    var contactStore = CNContactStore()
    var contacts = [Contact]()
    static let sharedInstance = ContactsImporter()
    private init(){}
    
    fileprivate class func extractABAddressBookRef(_ abRef: Unmanaged<ABAddressBook>!) -> ABAddressBook? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    func requestAccessToContacts(_ completion: @escaping (_ success: Bool) -> Void) {
            let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
            switch authorizationStatus {
            case .authorized: completion(true) // authorized previously
            case .denied, .notDetermined: // needs to ask for authorization
                contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (accessGranted, error) -> Void in
                    completion(accessGranted)
                })
            default: // not authorized.
                completion(false)
            }
    
    }
    
    func retrieveContacts(_ completion: (_ success: Bool, _ contacts: [Contact]?) -> Void) {
            do {
                let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
            
                try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, error) in
                    if let contact = Contact(cnContact: cnContact) { self.contacts.append(contact) }
                })
                completion(true, contacts)
            } catch {
            completion(false, nil)
            }
    }
    
    class func importContacts(_ callback: @escaping (Array<Contact>) -> Void) {

    }
    
}
