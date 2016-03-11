//
//  ChatStatus.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 9/18/15.
//  Copyright © 2015 John Jin Woong Kim. All rights reserved.
//

import Foundation

public class ChatStatus{
    var username: NSString!
    var title: NSString!
    var detail: NSString!
    var location: NSString!
    var time: NSDate!
    
    init(username:NSString, detail:NSString, time:NSDate){
        self.username = username
        self.detail = detail
        self.time = time
    }
    
    init(username:NSString, title:NSString, detail:NSString, location:NSString, time:NSDate){
        self.username = username
        self.title = title
        self.detail = detail
        self.location = location
        self.time = time
    }










}



