//
//  RendezStatus.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 3/5/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import Foundation

class RendezStatus : Equatable{
    var id:Int
    var username:String
    var title:String
    var details:String
    var location: String
    var timeset:String
    var timefor:String
    var type:Int
    var response: Int
    var fromuser:String
    var showname:String!
    var locUpdate:Int!
    
    //i know it says fromuser, but from now on read it as touser
    init(id:Int, username:String, title:String ,details:String, location:String, timeset:String, timefor:String,
        type:Int, response:Int, fromuser:String){
            
            self.id = id
            self.title = title
            self.username = username
            self.details = details
            self.location = location
            self.timeset = timeset
            self.timefor = timefor
            self.type = type
            self.response = response
            self.fromuser = fromuser
            self.locUpdate = 0
    
    }
    
    init(id:Int, username:String, title:String ,details:String, location:String, timeset:String, timefor:String,
        type:Int, response:Int, fromuser:String, showname:String){
            
            self.id = id
            self.title = title
            self.username = username
            self.details = details
            self.location = location
            self.timeset = timeset
            self.timefor = timefor
            self.type = type
            self.response = response
            self.fromuser = fromuser
            self.showname = showname
            self.locUpdate = 0
    }

}

func ==(lhs: RendezStatus, rhs: RendezStatus) -> Bool {
    return lhs.id == rhs.id && lhs.title == rhs.title && lhs.username == rhs.username && lhs.details == rhs.details && lhs.location == rhs.location && lhs.timeset == rhs.timeset && lhs.timefor == rhs.timefor && lhs.type == rhs.type
}