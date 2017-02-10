//
//  FromLocation.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 4/19/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

//just a simple class to hold id, location, username, and time of whenever someone 
//updates their location to a rendez
import Foundation

class FromLocation{
    var location:String
    var username:String
    var id: String
    var time:Date
    var isSet:Bool
    
    init(username:String, location:String, time:Date){
        self.username = username
        self.id = "who cares"
        self.location = location
        self.time = time
        self.isSet = true
    }
    
    init(username:String, id:String, location:String, time:Date){
        self.username = username
        self.id = id
        self.location = location
        self.time = time
        self.isSet = true
    }
    
    init(){
        self.username = "gwang"
        self.id = "gwang"
        self.location = "gwang"
        self.time = Date()
        self.isSet = false
    }
    
    func isFriendLocSet()->Bool{
        return self.isSet
    }
    
    func updateFriendLoc(_ time:Date, loc:String){
        self.location = loc
        self.time = time
    }
}
