//
//  NotificationNode.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 3/13/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import Foundation

//individual notification nodes for all those pesky rendez chats that need to be ORDERED AND SET AS NEW AND WHATNOT OJOSFNOWFWEL
class NotificationNode: Comparable {
    var username:String!
    var showname:String!
    var notif:Bool!
    var rendezCount: Int!
    var chatCount:Int!
    var maxtime:NSDate!
    var isGroup: Bool!
    
    init(username:String, showname:String){
        self.username = username
        self.showname = showname
        self.notif = false
        self.rendezCount = 0
        self.chatCount = 0
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
        var date1 = dateFormatter.dateFromString("2000-01-01 01:01:01")
        self.isGroup = false
        self.maxtime = date1
    }
    
    init(username:String, showname:String, g:Bool){
        self.username = username
        self.showname = showname
        self.notif = false
        self.rendezCount = 0
        self.chatCount = 0
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
        var date1 = dateFormatter.dateFromString("2000-01-01 01:01:01")
        self.isGroup = true
        self.maxtime = date1
    }
}

func <(lhs: NotificationNode, rhs: NotificationNode) -> Bool {
    let notifFlag = lhs.maxtime.compare(rhs.maxtime)
    if notifFlag == .OrderedAscending{
        return true
    }else{
        return false
    }
}

func >(lhs: NotificationNode, rhs: NotificationNode) -> Bool {
    let notifFlag = lhs.maxtime.compare(rhs.maxtime)    //print(notifFlag)
    if notifFlag == .OrderedDescending{
        return true
    }else{
        return false
    }
}

func ==(lhs: NotificationNode, rhs: NotificationNode) -> Bool {
    let notifFlag = lhs.maxtime.compare(rhs.maxtime)    //print(notifFlag)
    if notifFlag == .OrderedSame{
        return true
    }else{
        return false
    }
}