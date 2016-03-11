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
    var statusToPass: Friend!
    var newCar: String = ""
    var flag: Int!
    var progVar:Status!

    
    var username:String!
    var showname:String!
    
    var title1:String!
    var detail1:String!
    var location1:String!
    
    
    @IBOutlet weak var txtUsername: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        someInts += delegate.yourFriends
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return self.someInts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 3
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
        
        cell.textLabel?.text = self.someInts[indexPath.row].friendname
        print("TableView: " + self.someInts[indexPath.row].friendname)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let select = self.someInts[indexPath.row].selected
        
        if(select == false){
            self.someInts[indexPath.row].selected = true
            tableView.cellForRowAtIndexPath(indexPath)?.setSelected(true, animated: true)        }
        if(select == true){
            self.someInts[indexPath.row].selected = false
            tableView.cellForRowAtIndexPath(indexPath)?.setSelected(false, animated: true)
        }
    }
    
        
    @IBAction func onBackTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
        
    @IBAction func sendTapped(sender: UIButton) {
        var arr = [AnyObject]()
        var friendarr = [AnyObject]()

        let userObject = ["username": self.username, "showname": self.showname]
        arr.append(userObject)
        let statusObject = ["title": title1, "detail": detail1, "location": location1]
        arr.append(statusObject)
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        for friend in self.someInts{
            if(friend.selected == true){
                let friendObj = ["username": friend.username, "showname": friend.friendname]
                friendarr.append(friendObj)
                
                let emitobj = ["id": self.progVar.id, "friend": friend.username, "title": title1, "detail": detail1, "location": location1, "timefor": self.progVar.timefor, "type": self.progVar.type, "response": 0]
                delegate.friendarr.append(emitobj)


                
                /*//lets try this way... cheeky fire
                let post:[NSObject : AnyObject] = ["chatstatus": statusObject]
                NSNotificationCenter.defaultCenter().postNotificationName(emitRendezKey, object: self, userInfo: post)
                
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                delegate.emitRendez(friend.username, title: title1, detail: detail1, location: location1)
                //fuck this socket shit we are using events now mofoka
                */
            }
           
        }
        
        if(friendarr.count == 0){
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "You have not chosen any friends!!"
            alertView.message = "Choose a friend loser"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        else{
        delegate.events.trigger("emitRendez")
        let friendarray = ["array": friendarr]
        arr.append(friendarray)
        let finalNSArray:NSArray = arr
        let finalarr:NSDictionary = ["json": finalNSArray]
        NSLog("PostData: %@",finalarr);
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/sentRSwift.php")!
        let da:NSData = try! NSJSONSerialization.dataWithJSONObject(finalarr, options: [])
        print(da)
        let postLength:NSString = String( da.length )
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = da
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        var reponseError: NSError?
        var response: NSURLResponse?
        
        var urlData: NSData?
        do {
            urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
        } catch let error as NSError {
            reponseError = error
            urlData = nil
        }
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            NSLog("Response code: %ld", res.statusCode);
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                NSLog("sent!!!!!!!")
            } else {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection Failed"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
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
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
    }

}