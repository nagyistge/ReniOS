//
//  User.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/26/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import Foundation

class Friend:NSObject, Comparable{
    var username: String!
    var friendname: String!
    var selected: Bool = false
    var notification:Bool = false
    var time: Date!
    var rendezCount: Int!//simple counters to see notification numbers
    var chatCount: Int!
    var loctime:String!
    var location:String!
    var isGroup:Bool = false
    
    
    init(username: String, showname: String, timestamp: Date){
        self.username = username
        self.friendname = showname
        self.time = timestamp
        self.isGroup = false
    }
    
    init(username: String, showname: String, timestamp: Date,g:Bool){
        self.username = username
        self.friendname = showname
        self.time = timestamp
        self.isGroup = true
    }
    
    init(username: String, showname: String, timestamp: Date, loctime:String, location:String){
        self.username = username
        self.friendname = showname
        self.time = timestamp
        self.loctime = loctime
        self.location = location
        self.isGroup = false
    }
    
    
    func getUsername()-> String! {
    return self.username
    }
    func getShowname()-> String! {
    return self.friendname
    }
    func getTime()->Date{
        return self.time
    }
    
    func isSelected()-> Bool! {
        return selected
    }
}


func <(lhs: Friend, rhs: Friend) -> Bool {
    let notifFlag = lhs.time.compare(rhs.time)
    //print(notifFlag)
    
    if notifFlag == .orderedAscending{
        return true
    }else{
       return false
    }
    
}

func >(lhs: Friend, rhs: Friend) -> Bool {
    let notifFlag = lhs.time.compare(rhs.time)
    //print(notifFlag)
    
    if notifFlag == .orderedDescending{
        return true
    }else{
        return false
    }
    
}

func ==(lhs: Friend, rhs: Friend) -> Bool {
    let notifFlag = lhs.time.compare(rhs.time)
    //print(notifFlag)
    
    if notifFlag == .orderedSame{
        return true
    }else{
        return false
    }
    
}
