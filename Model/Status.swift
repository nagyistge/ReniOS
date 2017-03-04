//
//  User.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/26/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import Foundation

class Status : Equatable{
    //tThere are two types of statuses
    //a status made by you would have all the same variables, but rather than a single
    //response it would be an array of friend responses
    //fromuser is an array.  Also it has the visable cariable
    
    //else if it is a friend's status then it would be just your response to the status
    //fromusername is the username and response is your response
    //this would not use the visable variable since only public statuses would even be revealed to you
    var id:Int
    var username: String
    var title: String
    var detail: String
    var location: String
    var timeset: String
    var timefor: String
    var type: Int
    var fromuser: [fromUser]//array of fromusers to denote the responses to a status or your own response
    var visable: Int
    var fromusername: String
    var response:Int
    
    
    
    //intializing a status made by you
    init(id: Int, username: String, title: String, detail: String, location: String, timeset:String, timefor:String, type:Int,  fromuser:[fromUser], visable: Int){
        self.id = id
        self.username = username
        self.title = title
        self.detail = detail
        self.location = location
        self.timeset = timeset
        self.timefor = timefor
        self.type = type
        self.fromuser = fromuser
        self.visable = visable
        
        self.response = -1
        self.fromusername = "Its your status"

    }
    
    //this is a status from afriend
    init(id: Int, username: String, title: String, detail: String, location: String, timeset:String, timefor:String, type:Int, visable: Int, fromusername:String, response:Int){
        self.id = id
        self.username = username
        self.title = title
        self.detail = detail
        self.location = location
        self.timeset = timeset
        self.timefor = timefor
        self.type = type
        self.fromuser = [fromUser]()
        self.visable = visable
        
        self.response = response
        self.fromusername = fromusername
        
    }
    
}

func ==(lhs: Status, rhs: Status) -> Bool {
    return lhs.id == rhs.id && lhs.title == rhs.title && lhs.username == rhs.username && lhs.detail == rhs.detail && lhs.location == rhs.location && lhs.timeset == rhs.timeset && lhs.timefor == rhs.timefor && lhs.type == rhs.type 
}