//
//  NotificationHelper.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 3/13/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import Foundation

class NotificationHelper {
    var NotifMap = Dictionary<String,NotificationNode!>()
    func isInNotifMap(name:String)->Bool{
        if(self.NotifMap[name] == nil){
            return false
        }else{
            return true
        }
    }
    
    func addToNotfifs(node:NotificationNode){
        self.NotifMap[node.username] = node
    }
    
    func setMaxtime(username:String, time:NSDate){
        let notifFlag = self.NotifMap[username]!.maxtime.compare(time)
        if notifFlag == .OrderedAscending{
        //if notifFlag == .OrderedDescending{
            self.NotifMap[username]!.maxtime = (time)
        }
        
    }
    
    func incrementRendez(username:String){
        self.NotifMap[username]!.rendezCount = self.NotifMap[username]!.rendezCount + 1
    }
    
    func incrementChat(username:String){
        self.NotifMap[username]!.chatCount =  self.NotifMap[username]!.chatCount + 1
    }
    
    func resetCounts(username:String){
        self.NotifMap[username]!.rendezCount = 0
        self.NotifMap[username]!.chatCount = 0
    }
    
    func returnFriendNotif()->[Friend]{
        var friends = [Friend]()
        for (x,y) in self.NotifMap{
            if(y.isGroup == true){
                let friend = Friend(username: y.username, showname: y.showname, timestamp: y.maxtime,g: true)
                friend.chatCount = y.chatCount
                friend.rendezCount = y.rendezCount
                friends.append(friend)

            }else{
                let friend = Friend(username: y.username, showname: y.showname, timestamp: y.maxtime)
                friend.chatCount = y.chatCount
                friend.rendezCount = y.rendezCount
                friends.append(friend)
            }
        }
        friends.sortInPlace()
        return friends.reverse()
    }
}