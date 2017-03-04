//
//  Groups.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 3/10/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import Foundation

class Groups {
    var id: Int
    var groupname: String
    var groupdetail: String
    var members: [Friend]!
    var selected: Bool
    
    init(){
        self.id = -1
        self.groupname = ""
        self.groupdetail = ""
        self.selected = false
    }
    
    init(id:Int, groupname:String, groupdetail:String, members : [Friend]){
        self.id = id
        self.groupname = groupname
        self.groupdetail = groupdetail
        self.members = members
        self.selected = false
    }
}