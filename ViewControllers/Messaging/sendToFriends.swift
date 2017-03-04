//
//  sendToFriends.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/31/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

class sendToFriends: UIViewController,UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var items: [String] = ["We", "Heart", "Swift"]
    var someInts = [Friend]()
    var someGroupInts = [Groups]()
    var statusToPass: Friend!
    var newCar: String = ""
    var flag: Int!
    var progVar:Status!
    var username:String!
    var showname:String!
    var title1:String!
    var detail1:String!
    var location1:String!
    var delegate:AppDelegate!
    @IBOutlet weak var txtUsername: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupTableView: UITableView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.groupTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        delegate = UIApplication.shared.delegate as! AppDelegate
        someInts += delegate.yourFriends
        someGroupInts += delegate.yourGroups
        print("INSIDE SENDTOFRIENDS @@@@@@@@@@@")
        print(someInts)
        print(someGroupInts.count)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.tableView){
            return self.someInts.count
        }else{
            return self.someGroupInts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 3
        if(tableView == self.tableView){
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.someInts[indexPath.row].friendname
        print("TableView: " + self.someInts[indexPath.row].friendname)
        return cell
        }
        else{
            let cell:UITableViewCell = self.groupTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = self.someGroupInts[indexPath.row].groupname
            print("TableView: " + self.someGroupInts[indexPath.row].groupname)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == self.tableView){
        print("You selected cell #\(indexPath.row)!")
        let select = self.someInts[indexPath.row].selected
        
        if(select == false){
            self.someInts[indexPath.row].selected = true
            tableView.cellForRow(at: indexPath)?.setSelected(true, animated: true)        }
        if(select == true){
            self.someInts[indexPath.row].selected = false
            tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
            }
        }else{
            print("You selected cell #\(indexPath.row)!")
            let select = self.someGroupInts[indexPath.row].selected
            
            if(select == false){
                self.someGroupInts[indexPath.row].selected = true
                groupTableView.cellForRow(at: indexPath)?.setSelected(true, animated: true)        }
            if(select == true){
                self.someGroupInts[indexPath.row].selected = false
                groupTableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
            }
        }
    }
    
        
    @IBAction func onBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
        
    @IBAction func sendTapped(_ sender: UIButton) {
        var arr = [AnyObject]()
        var friendarr = [AnyObject]()
        
        let userObject = ["username": self.username, "showname": self.showname]
        arr.append(userObject as AnyObject)
        let statusObject = ["title": title1, "detail": detail1, "location": location1, "type": self.progVar.type, "timefor": self.progVar.timefor, "response": 0] as [String : Any]
        arr.append(statusObject as AnyObject)
        delegate = UIApplication.shared.delegate as! AppDelegate
        for friend in self.someInts{
            if(friend.selected == true){
                let friendObj = ["username": friend.username, "showname": friend.friendname]
                friendarr.append(friendObj as AnyObject)
                let emitobj = ["id": self.progVar.id, "friend": friend.username, "title": title1, "detail": detail1, "location": location1, "timefor": self.progVar.timefor, "type": self.progVar.type, "response": 0] as [String : Any]
                delegate.friendarr.append(emitobj as AnyObject)
            }
        }
        
        for group in self.someGroupInts{
            if(group.selected == true){
                let groupObj = ["username": group.groupname, "showname": group.groupdetail]
                friendarr.append(groupObj as AnyObject)
                let emitobj = ["id": self.progVar.id, "friend": group.groupname, "title": title1, "detail": detail1, "location": location1, "timefor": self.progVar.timefor, "type": self.progVar.type, "response": 0] as [String : Any]
                delegate.grouparr.append(emitobj as AnyObject)
            }
        }
        
        if(friendarr.count == 0){
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "You have not chosen any friends!!"
            alertView.message = "Choose a friend loser"
            alertView.delegate = self
            alertView.addButton(withTitle: "OK")
            alertView.show()
        }
        else{
            delegate.events.trigger(eventName: "emitRendez")
            let friendarray = ["array": friendarr]
            arr.append(friendarray as AnyObject)
            let finalNSArray:NSArray = arr as NSArray
            let finalarr:NSDictionary = ["json": finalNSArray]
            NSLog("PostData: %@",finalarr);
            let url:URL = URL(string: "http://www.jjkbashlord.com/sentRSwift.php")!
            let da:Data = try! JSONSerialization.data(withJSONObject: finalarr, options: [])
            print(da)
            let postLength:NSString = String( da.count ) as NSString
            let request:NSMutableURLRequest = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = da
            request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            var reponseError: NSError?
            var response: URLResponse?
            var urlData: Data?
        do {
            urlData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning:&response)
        } catch let error as NSError {
            reponseError = error
            urlData = nil
        }
        if ( urlData != nil ) {
            let res = response as! HTTPURLResponse!;
            //NSLog("Response code: %ld", res?.statusCode);
            if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                NSLog("Response ==> %@", responseData);
                let jsonData:NSObject = (try! JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers )) as! NSObject
                NSLog("sent!!!!!!!")
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let date = dateFormatter.string(from: Date())
               
                for friend in self.someInts{
                    if(friend.selected == true){
                        if(!(delegate.isTheFriendInTheWoz(friend.username))){
                            delegate.theWozMap[friend.username] = rendezChatDictionary()
                        }
                        let rendezStatus:RendezStatus = RendezStatus(id: jsonData.value(forKey: friend.username) as! Int, username: self.username, title: self.progVar.title, details: self.progVar.detail, location: self.progVar.location, timeset: date, timefor: self.progVar.timefor, type: self.progVar.type, response: self.progVar.response, fromuser: friend.username)
                        delegate.theWozMap[friend.username]!.allDeesRendez.append(rendezStatus)
                        friend.selected = false
                    }
                }
                for group in self.someGroupInts{
                    if(group.selected == true)
                    {
                        if(!(delegate.isTheFriendInTheWoz(group.groupname))){
                            delegate.theWozMap[group.groupname] = rendezChatDictionary()
                        }
            
                        let rendezStatus:RendezStatus = RendezStatus(id: jsonData.value(forKey: group.groupname) as! Int, username: self.username, title: self.progVar.title, details: self.progVar.detail, location: self.progVar.location, timeset: date, timefor: self.progVar.timefor, type: self.progVar.type, response: self.progVar.response, fromuser: group.groupname)
                        delegate.theWozMap[group.groupname]!.allDeesRendez.append(rendezStatus)
                        group.selected = false
                    }
                }
            } else {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection Failed"
                alertView.delegate = self
                alertView.addButton(withTitle: "OK")
                alertView.show()
            }
        } else {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection Failure"
                if let error = reponseError {
                    alertView.message = (error.localizedDescription)
                }
                alertView.delegate = self
                alertView.addButton(withTitle: "OK")
                alertView.show()
            }
        }
    }
}
