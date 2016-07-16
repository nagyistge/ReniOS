//
//  GResps.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 7/16/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import Foundation
class GResps {
    var id: Int!
    var name: String!
    var resp: Int!
    
    init(){
    }
    
    init(id:Int, name:String, resp: Int){
        self.id = id
        self.name = name
        self.resp = resp
    }
}