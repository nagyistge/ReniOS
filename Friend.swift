//
//  User.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/26/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import Foundation

class Friend:NSObject{
    var username: String!
    var friendname: String!
    var phone: String!
    var email: String!
    var status: Int!
    var selected: Bool = false
    var notification:Bool = false
    var time: NSDate!
    
    init(username: String, showname: String, timestamp: NSDate){
        self.username = username
        self.friendname = showname
        self.time = timestamp
    }
    
    init(username: String, friendname: String, phone: String, email: String, status: Int){
        self.username = username
        self.friendname = friendname
        self.phone = phone
        self.email =  email
        self.status = status
    }
    
    func getUsername()-> String! {
    return self.username
    }
    func getShowname()-> String! {
    return self.friendname
    }
    func getTime()->NSDate{
        return self.time
    }
    
    
    func isSelected()-> Bool! {
        return selected
    }

    
    
    
}
