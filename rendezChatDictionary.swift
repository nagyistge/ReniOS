//
//  rendezChatDictionary.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 9/18/15.
//  Copyright © 2015 John Jin Woong Kim. All rights reserved.
//

import Foundation

public class rendezChatDictionary: NSObject{
    var allDeesStatus: Array<Status>!
    var allDeesRendez: Array<RendezStatus>!
    var allDeesChat: Array<Chat>!
    


    
    override init(){
        self.allDeesRendez = Array<RendezStatus>()
        self.allDeesChat = Array<Chat>()
        self.allDeesStatus = Array<Status>()
    }
    
    func rendezChatDictionary(status: Array<Status>, rendez:Array<RendezStatus>, chat: Array<Chat>){
        self.allDeesStatus = status
        self.allDeesRendez = rendez
        self.allDeesChat = chat
    }
    
    func initRendez(initR:Array<RendezStatus>){
        self.allDeesRendez = initR
    }
    func initChat(initC:Array<Chat>){
        self.allDeesChat = initC
    }
    func initStatus(initS:Array<Status>){
        self.allDeesStatus = initS
    }

    func putInRendez(rendez:RendezStatus){
        self.allDeesRendez.append(rendez)
    }

    func putInChat(rendez:Chat){
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
    

}
