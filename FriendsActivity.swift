//
//  FriendsActivity.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/25/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

class FriendsActivity: UIViewController,UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var createGroupButton: UIButton!
    
    
    var vc: rendezChat!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var someInts = [Friend]()
    var statusToPass: Friend!
    var newCar: String = ""
    let notif:UIImageView = UIImageView.init(frame: CGRectMake(0, 0, 35, 35))
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var notifObj:[NSObject : AnyObject]!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtUsername: UILabel!
    
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        notif.image = UIImage(named: "notification")
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //tableView
        
        //NSNOTIFICATION OBSERVER INITILIZER
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFriendNotif:", name: FriendActivityNotifKey, object: nil)
        if self.delegate.yourFriends.count == 0{
        //init param for the initial list from msqli~~~~~~~~~~~~~~~~~~~~
        let username:String = prefs.valueForKey("USERNAME") as! String
        let post:NSString = "username=\(username)"
        NSLog("PostData: %@",post);
        //random shit needed for the http request
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/fetchRendezChatNotifChecker.php")!
        let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        let postLength:NSString = String( postData.length )
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
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
                let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                NSLog("Response ==> %@", responseData);
                let jsonData:NSArray = (try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers )) as! NSArray
                for(var index = 0; index < jsonData.count; index++ ){

                    
                    let username1:NSString = jsonData[index].valueForKey("username") as! NSString
                    let title1:NSString = jsonData[index].valueForKey("showname") as! NSString
                    var detail1:String = jsonData[index].valueForKey("timestamp") as! NSString as String
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    
                    
                    if(detail1.characters.count < 18){
                        detail1 += ":00"
                    }
                    
                    let date = dateFormatter.dateFromString(detail1 as String)
                    
                    print("Initial friendlist fetch for " + (username1 as String) + "\n")
                    print("showname: " + (title1 as String) + "\n")
                    print("date: " + (date?.description)! + "\n")
                    
                    
                    let status = Friend(username: username1 as String, showname: title1 as String, timestamp: date!)
                    someInts.append(status)
                }
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
            self.delegate.loadFriends(someInts)
        }else{
            print("IS THIS BEING PRINTED")
            //someInts = self.delegate.yourFriends
        }
        
        //done with the initial fetch~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        someInts.removeAll()
        someInts.appendContentsOf(self.delegate.yourFriends)
        self.tableView.reloadData()

    }
    //NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---
    
    
    //should be called by the app delegate when it gets new emit by the NSNotificationCenter
    //all this should do is change the friend notif time and update the table
    internal func updateFriendNotif(notification:NSNotification){
        print("is the update in friend'sactivity even called??")
        
        //get the friend param and set it
        let postparam:Dictionary<String, Friend!> = notification.userInfo as! Dictionary<String, Friend!>
        let friendNotif:Friend = postparam["friend"]!
        var wasItIn = false
        
        //Now you have the friend, you need to insert it into some ints, but what if it is already in someInts?
        for (index, value) in someInts.enumerate(){
            if value.username == friendNotif.username{
                self.someInts.removeAtIndex(index)
                self.someInts.insert(friendNotif, atIndex: 0)
                wasItIn = true
            }
        }
        if(wasItIn == false){
            self.someInts.insert(friendNotif, atIndex: 0)
        }
        
        self.tableView.reloadData()
    }
    
    
    
    
    //TABLE STUFF-----TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------
    

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return self.someInts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        NSLog("Checking if the uitable in friendsactivity gets called before or after");
        // 3
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        NSLog("DATES BEING COMPARED FROM THE LAST NOTIF CHECKED AND LAST RENDEZ SENT")
        print(self.someInts[indexPath.row].username)
        NSLog("TIME LAST CLICKED ==> " + (prefs.valueForKey(self.someInts[indexPath.row].username)?.description)!)
        NSLog("TIME OF LAST RECIEVED ==> " + (self.someInts[indexPath.row].time).description)
        NSLog((self.someInts[indexPath.row].username))
        
        
        let friendLastChecked:NSDate = prefs.valueForKey(self.someInts[indexPath.row].username) as! NSDate
        let friendLastSent: NSDate = self.someInts[indexPath.row].time as NSDate
        
        // NSComparisonResult
        let notifFlag = friendLastChecked.compare(friendLastSent)
        print(notifFlag)
        
        if notifFlag == .OrderedAscending{
        cell.accessoryView = notif
        }else{
        cell.accessoryView = nil
        }
  
        cell.textLabel!.text = self.someInts[indexPath.row].friendname
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        

        
        tableView.cellForRowAtIndexPath(indexPath)
        vc = self.storyboard?.instantiateViewControllerWithIdentifier("rendezChat") as! rendezChat
        vc.username = prefs.valueForKey("USERNAME") as! String
        vc.friendname = self.someInts[indexPath.row].username
        vc.showuser = prefs.valueForKey("SHOWNAME") as! String
        vc.showfriend = self.someInts[indexPath.row].friendname
        vc.rendezNotifTimeFlag = prefs.valueForKey(self.someInts[indexPath.row].username) as! NSDate
        
        prefs.setObject(NSDate(), forKey: self.someInts[indexPath.row].username)
        print(self.someInts[indexPath.row].username + " prefs time now set to ")
        print(NSDate())
        
        
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    

    
    @IBAction func onCreateGroupClicked(sender: UIButton) {
        
        
    }
    
    
    
    
    @IBAction func newR(sender: AnyObject) {
   
    }
    
    
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}