//
//  RendezNotifList.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 7/30/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit

class RendezNotifList: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    var someRendez = [RendezStatus]()
    var someChat = [Chat]()
    var someStatus = [Status]()
    var listType:Int!//0 is status list, 1 is rendez, 2 is chat

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

    //TABLE STUFF-----TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        if(listType == 0){
            return someStatus.count
        }else if(listType == 1){
            return someRendez.count
        }else{
            return someChat.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        //f(!self.someInts[indexPath.row].isGroup){
        if(listType == 0){//status
           cell.textLabel?.text = "Status: " + self.someStatus[indexPath.row].title
        }else if(listType == 1){//rendezes
             cell.textLabel?.text = "Rendez: " + self.someRendez[indexPath.row].title
        }else{//chat
             cell.textLabel?.text = "Chat: " + self.someChat[indexPath.row].details
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
    }
    
    
}
