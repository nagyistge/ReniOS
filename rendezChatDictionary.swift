//
//  rendezChatDictionary.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 9/18/15.
//  Copyright © 2015 John Jin Woong Kim. All rights reserved.
//

import Foundation

open class rendezChatDictionary: NSObject{
    var allDeesStatus: Array<Status>!
    var allDeesRendez: Array<RendezStatus>!
    var allDeesChat: Array<Chat>!
    var allDeezLoc: Array<FromLocation>!
    var allDeesFriends: Array<Friend>!
    var allDeesFriendsMap:  Dictionary<String, Friend?> = Dictionary<String, Friend!>()
    var allDeesGroups: Array<Groups>!
    //when will it end
    var allDeesReps: Array<GResps>!

    
    
    override init(){
        self.allDeesRendez = Array<RendezStatus>()
        self.allDeesChat = Array<Chat>()
        self.allDeesStatus = Array<Status>()
        self.allDeezLoc = Array<FromLocation>()
        self.allDeesFriends = Array<Friend>()
        self.allDeesGroups = Array<Groups>()
        self.allDeesReps = Array<GResps>()
    }
    
    func rendezChatDictionary(_ status: Array<Status>, rendez:Array<RendezStatus>, chat: Array<Chat>){
        self.allDeesStatus = status
        self.allDeesRendez = rendez
        self.allDeesChat = chat
    }
    
    func initRendez(_ initR:Array<RendezStatus>){
        self.allDeesRendez = initR
    }
    func initChat(_ initC:Array<Chat>){
        self.allDeesChat = initC
    }
    func initStatus(_ initS:Array<Status>){
        self.allDeesStatus = initS
    }

    func putInRendez(_ rendez:RendezStatus){
        self.allDeesRendez.append(rendez)
    }

    func putInChat(_ rendez:Chat){
        self.allDeesChat.append(rendez)
    }

    func getDemRendezes() -> Array<RendezStatus>{
        return self.allDeesRendez
    }
    
    func getDemChat() -> Array<Chat>{
        return self.allDeesChat
    }
    func getDemStatus() -> Array<Status>{
        return self.allDeesStatus
    }
    
    func getDemFriends() -> Array<Friend>{
        return self.allDeesFriends
    }
    
    func getDemGroups() -> Array<Groups>{
        return self.allDeesGroups
    }
}
