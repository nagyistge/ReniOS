//
//  MapCell.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 2/14/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import Foundation

class MapCell{
    var additionalRows: Int
    var cellIdentifier: String
    var isExpandable: Int
    var isExpanded: Int
    var isVisable: Int
    var primaryTitle: String
    var secondaryTitle: String
    var value: NSObject
    
    init(username: Int, title: String, detail: Int, location: Int, timeset:Int, timefor:String, type:String,  fromuser:NSObject){
        self.additionalRows = username
        self.cellIdentifier = title
        self.isExpandable = detail
        self.isExpanded = location
        self.isVisable = timeset
        self.primaryTitle = timefor
        self.secondaryTitle = type
        self.value = fromuser
        
    }
    
}