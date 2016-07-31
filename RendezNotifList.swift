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
           //cell.textLabel?.text = "Status: " + self.someStatus[indexPath.row].title
            cell.textLabel?.text = self.someStatus[indexPath.row].username + " did some sorta something with a status."
        }else if(listType == 1){//rendezes
             cell.textLabel?.text = self.someRendez[indexPath.row].username + " sent ya a Rendez at " + self.someRendez[indexPath.row].timeset
        }else{//chat
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
            
            var timefor = dateFormatter.stringFromDate(self.someChat[indexPath.row].time)
            
            cell.textLabel?.text = self.someChat[indexPath.row].username + " sent ya a message at " + timefor

            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
    }
    
    
}
