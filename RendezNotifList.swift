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
    func numberOfSections(in tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        if(listType == 0){
            return someStatus.count
        }else if(listType == 1){
            return someRendez.count
        }else{
            return someChat.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        //f(!self.someInts[indexPath.row].isGroup){
        
        if(listType == 0){//status
            let cell = tableView.dequeueReusableCell(withIdentifier: "sCell", for: indexPath) as! sCell
            cell.textLabel?.text = self.someStatus[indexPath.row].username + " did some sorta something with a status."
            
            
            return cell
        }else if(listType == 1){//rendezes
            let cell = tableView.dequeueReusableCell(withIdentifier: "rCell", for: indexPath) as! rCell
             //cell.textLabel?.text = self.someRendez[indexPath.row].username + " sent ya a Rendez at " + self.someRendez[indexPath.row].timeset
            cell.time.text = self.someRendez[indexPath.row].timeset
            cell.rTitle.text = self.someRendez[indexPath.row].username + " sent ya a Rendez!"
            
            return cell
        }else{//chat
            let cell = tableView.dequeueReusableCell(withIdentifier: "cCell", for: indexPath) as! cCell
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
            
            let timefor = dateFormatter.string(from: self.someChat[indexPath.row].time as Date)
            
            //cell.textLabel?.text = self.someChat[indexPath.row].username + " sent ya a message at " + timefor

            cell.time.text = timefor
            cell.cTitle.text = self.someChat[indexPath.row].username + " sent ya a message!"
            
            return cell
        }
        
        //return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
    }
    
    
}
