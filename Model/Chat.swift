//
//  Chat.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 3/5/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import Foundation

class Chat{
    var username:String
    var details:String
    var time: Date
    var toUser:String

    init(username:String, details:String, time:Date, toUser:String){
        self.username = username
        self.details = details
        self.time = time
        self.toUser = toUser
    
    
    }

}
