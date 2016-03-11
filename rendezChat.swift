//
//  rendezChat.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 9/1/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

class rendezChat: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatButton: UIButton!
    
    var username: String!
    var friendname: String!
    var someInts = [RendezStatus]()
    var someChats = [Chat]()
    var showuser: String!
    var showfriend: String!
    var rendezNotifTimeFlag: NSDate!
    
    var statusToPass: RendezStatus!
    var vc: showRRendez!
    var toViewController:chattingR!
    var temp:rendezChatDictionary!
    
    ///operator that handles the custom side effect when presenting the chat view
    var transitionOperator = TransitionOperator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
        
        //NSNOTIFICATION OBSERVER INITILIZER
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateRendezChatNotif:", name: rendezChatNotifKey, object: nil)
        print("This notifcation observer should be set now for this friend... it should be called every time")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    //set the user display names in the respective labels
    friendLabel.text = showfriend
    userLabel.text = showuser
    
    //get instance of appdelegate
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    //check if the chat you are about to see is in theWoz
    if(!(delegate.isTheFriendInTheWoz(friendname))){
        //not only does this store the chat in theWoz but also returns the rendezchatdictionary
        let niceToMeetYou = delegate.makeFriendsWithWoz(username, friendname: friendname)
        someInts.appendContentsOf(delegate.theWozMap[friendname]!.allDeesRendez)
        print("they had to be introduced first but it is gucci meng now")
    
    }
    else{ //the chat of that friend exists already, so lets just get it from theWozMap and make the lists
        let statuslist = delegate.theWozMap[friendname]!
        let rendez = statuslist.allDeesRendez
        someInts.appendContentsOf(delegate.theWozMap[friendname]!.allDeesRendez)
        NSLog("\n THE CHAT HAS RETRIEVED THE STATIC LIST FROM THE WOZ")
    }
}
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    //~~~~~~~~~~~~~~~~~~Button cases for the View
    @IBAction func onBackTapped(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onChatTapped(sender: UIButton) {
            //self.performSegueWithIdentifier("presentNav", sender: self)
        
        toViewController = self.storyboard?.instantiateViewControllerWithIdentifier("chattingR") as! chattingR
       // toViewController = segue.destinationViewController as! chattingR
        toViewController.username = username
        toViewController.friendname = friendname
        toViewController.showuser = showuser
        toViewController.showfriend = showfriend
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        toViewController.transitioningDelegate = self.transitionOperator
        
        self.presentViewController(toViewController, animated: true, completion: nil)
    }
    
    
    
    //NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---
    
    
    //should be called by the app delegate when it gets new emit by the NSNotificationCenter
    //all this should do is change the friend notif time and update the table
    internal func updateRendezChatNotif(notification:NSNotification){
        print("is the update in rendezChat even called??")
        
        //get the friend param and set it
        let postparam:Dictionary<String, RendezStatus!> = notification.userInfo as! Dictionary<String, RendezStatus!>
        let friendNotif:RendezStatus = postparam["chatstatus"]!
        
        if(friendNotif.username == friendname){
            self.someInts.insert(friendNotif, atIndex: 0)
            self.tableView.reloadData()
        }
    }
    
    
    //TABLEVIEW INITIALIZATION STUFF, HANDLES MAKING THE LIST AND ONCLICKS ON THE LIST
    
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
        
        //SETS THEE RENDEZ THAT IS FROM YOU
        if(self.someInts[indexPath.row].username == username){
            cell.textLabel?.textAlignment = .Right
            cell.textLabel?.textColor = UIColor.redColor()
            cell.textLabel!.text = self.someInts[indexPath.row].title as NSString as String
        }
        else{//ELSE THE RENDEZ IS FROM THE FRIEND
            cell.textLabel?.textAlignment = .Left
            cell.textLabel?.textColor = UIColor.blueColor()
            cell.textLabel!.text = self.someInts[indexPath.row].title as NSString as String
            //if(self.someInts[indexPath.row].time)
            //check with the LAST TIME THAT FRIEND WAS CHECKED TIME with the time of the redenz from the friend to see if it is new and should be highlighted or not
            
            let dateFormatter = NSDateFormatter()
            if self.someInts[indexPath.row].timeset.characters.count == 19 {
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            }else{
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            }
            dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
            var date = dateFormatter.dateFromString(self.someInts[indexPath.row].timeset)
            date = dateFormatter.dateFromString(self.someInts[indexPath.row].timeset)
            print(self.someInts[indexPath.row].timeset)
            print(date)
            let notifFlag = rendezNotifTimeFlag.compare(date!)
            
            if notifFlag == .OrderedAscending{
                cell.backgroundColor = UIColor.yellowColor()
            }else{

            }
         
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let currentCell = self.someInts[indexPath.row] as RendezStatus
        statusToPass = currentCell
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = self.storyboard?.instantiateViewControllerWithIdentifier("showRRendez") as! showRRendez
        vc.programVar1 = statusToPass
        vc.username = username
        vc.friendname = friendname
        vc.showuser = showuser
        vc.showfriend = showfriend
        print (statusToPass.username + "  " + username)
        if(statusToPass.username == username){
        vc.isStatusFromYou == true
        }else{
        vc.isStatusFromYou = false
        }
        self.presentViewController(vc, animated: true, completion: nil)
    }
}
