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
    
    var createGroupVC: onCreateGroupVC!
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
        //if self.delegate.yourFriends.count == 0{
        
        
        //done with the initial fetch~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.someInts.removeAll()
        self.someInts.appendContentsOf(self.delegate.theNotifHelper.returnFriendNotif())
        print(someInts)
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
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        NSLog("DATES BEING COMPARED FROM THE LAST NOTIF CHECKED AND LAST RENDEZ SENT")
        print(self.someInts[indexPath.row].username)
        if(prefs.valueForKey(self.someInts[indexPath.row].username) == nil){
         prefs.setObject(NSDate(), forKey: self.someInts[indexPath.row].username)
        }
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
  
        var name:String = ""
        if(self.someInts[indexPath.row].isGroup){
            name += self.someInts[indexPath.row].username
        }else{
            name += self.someInts[indexPath.row].friendname
        }
        
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        if(self.someInts[indexPath.row].rendezCount != nil){
            print("Printing the rendez and chat notificiation numbers")
            print(self.someInts[indexPath.row].rendezCount)
            print(self.someInts[indexPath.row].chatCount)
            if(self.someInts[indexPath.row].rendezCount != 0){
                name += " " + String(self.someInts[indexPath.row].rendezCount) + " unread Rendezes "
            }
             if(self.someInts[indexPath.row].chatCount != 0){
                name += String(self.someInts[indexPath.row].chatCount) + " unread Chats! "
            }
        }
        
        
        cell.textLabel!.text = name
        cell.detailTextLabel?.text = self.someInts[indexPath.row].time.description
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        tableView.cellForRowAtIndexPath(indexPath)
        vc = self.storyboard?.instantiateViewControllerWithIdentifier("rendezChat") as! rendezChat
        if(!self.someInts[indexPath.row].isGroup){
            print("Friend is NOT a Group!")
            vc.username = prefs.valueForKey("USERNAME") as! String
            vc.friendname = self.someInts[indexPath.row].username
            vc.showuser = prefs.valueForKey("SHOWNAME") as! String
            vc.showfriend = self.someInts[indexPath.row].friendname
            vc.rendezNotifTimeFlag = prefs.valueForKey(self.someInts[indexPath.row].username) as! NSDate
        
            prefs.setObject(NSDate(), forKey: self.someInts[indexPath.row].username)
            print(self.someInts[indexPath.row].username + " prefs time now set to ")
            self.delegate.theNotifHelper.resetCounts(self.someInts[indexPath.row].username)
            //print(NSDate())
            self.presentViewController(vc, animated: true, completion: nil)
        }else{
             print("Friend IS a Group!")
            vc.username = prefs.valueForKey("USERNAME") as! String
            vc.friendname = self.someInts[indexPath.row].username
            vc.showuser = prefs.valueForKey("SHOWNAME") as! String
            vc.showfriend = self.someInts[indexPath.row].friendname
            vc.rendezNotifTimeFlag = prefs.valueForKey(self.someInts[indexPath.row].username) as! NSDate
            vc.flag = 1
            prefs.setObject(NSDate(), forKey: self.someInts[indexPath.row].username)
            print(self.someInts[indexPath.row].username + " prefs time now set to ")
            self.delegate.theNotifHelper.resetCounts(self.someInts[indexPath.row].username)
            //print(NSDate())
            vc.ggroup = self.delegate.getGroup(self.someInts[indexPath.row].username)
            self.presentViewController(vc, animated: true, completion: nil)
            
        }
    }
    

    
    @IBAction func onCreateGroupClicked(sender: UIButton) {
        createGroupVC = self.storyboard?.instantiateViewControllerWithIdentifier("createGroup") as! onCreateGroupVC

        print(NSDate())
        
        
        self.presentViewController(createGroupVC, animated: true, completion: nil)
        
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