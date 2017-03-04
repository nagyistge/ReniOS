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
    let notif:UIImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var notifObj:[AnyHashable: Any]!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtUsername: UILabel!
    
    
    let prefs:UserDefaults = UserDefaults.standard
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        notif.image = UIImage(named: "notification")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //tableView
        
        //NSNOTIFICATION OBSERVER INITILIZER
        NotificationCenter.default.addObserver(self, selector: #selector(FriendsActivity.updateFriendNotif(_:)), name: NSNotification.Name(rawValue: FriendActivityNotifKey), object: nil)
        //if self.delegate.yourFriends.count == 0{
        
        print("WHAT THE EFF")
        //done with the initial fetch~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.someInts.removeAll()
        self.someInts.append(contentsOf: self.delegate.theNotifHelper.returnFriendNotif())
        print(someInts)
        self.tableView.reloadData()

    }
    
    //NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---
    //should be called by the app delegate when it gets new emit by the NSNotificationCenter
    //all this should do is change the friend notif time and update the table
    internal func updateFriendNotif(_ notification:Notification){
        print("is the update in friend'sactivity even called??")
        
        //get the friend param and set it
        let postparam:Dictionary<String, Friend?> = notification.userInfo as! Dictionary<String, Friend?>
        let friendNotif:Friend = postparam["friend"]!!
        var wasItIn = false
        
        //Now you have the friend, you need to insert it into some ints, but what if it is already in someInts?
        for (index, value) in someInts.enumerated(){
            if value.username == friendNotif.username{
                self.someInts.remove(at: index)
                self.someInts.insert(friendNotif, at: 0)
                wasItIn = true
            }
        }
        if(wasItIn == false){
            self.someInts.insert(friendNotif, at: 0)
        }
        
        self.tableView.reloadData()
    }
    
    
    
    
    //TABLE STUFF-----TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------
    func numberOfSections(in tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return self.someInts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        NSLog("Checking if the uitable in friendsactivity gets called before or after");
        // 3
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        NSLog("DATES BEING COMPARED FROM THE LAST NOTIF CHECKED AND LAST RENDEZ SENT")
        print(self.someInts[indexPath.row].username)
        if(prefs.value(forKey: self.someInts[indexPath.row].username) == nil){
         prefs.set(Date(), forKey: self.someInts[indexPath.row].username)
        }
        NSLog("TIME LAST CLICKED ==> " + ((prefs.value(forKey: self.someInts[indexPath.row].username) as AnyObject).description)!)
        NSLog("TIME OF LAST RECIEVED ==> " + (self.someInts[indexPath.row].time).description)
        NSLog((self.someInts[indexPath.row].username))
        
        
        let friendLastChecked:Date = prefs.value(forKey: self.someInts[indexPath.row].username) as! Date
        let friendLastSent: Date = self.someInts[indexPath.row].time as Date
        
        // NSComparisonResult
        let notifFlag = friendLastChecked.compare(friendLastSent)
        print(notifFlag)
        
        if notifFlag == .orderedAscending{
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
        
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
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
        //print("wat")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        tableView.cellForRow(at: indexPath)
        vc = self.storyboard?.instantiateViewController(withIdentifier: "rendezChat") as! rendezChat
        if(!self.someInts[indexPath.row].isGroup){
            print("Friend is NOT a Group!")
            vc.username = prefs.value(forKey: "USERNAME") as! String
            vc.friendname = self.someInts[indexPath.row].username
            vc.showuser = prefs.value(forKey: "SHOWNAME") as! String
            vc.showfriend = self.someInts[indexPath.row].friendname
            vc.rendezNotifTimeFlag = prefs.value(forKey: self.someInts[indexPath.row].username) as! Date
        
            prefs.set(Date(), forKey: self.someInts[indexPath.row].username)
            print(self.someInts[indexPath.row].username + " prefs time now set to ")
            self.delegate.theNotifHelper.resetCounts(self.someInts[indexPath.row].username)
            //print(NSDate())
            self.present(vc, animated: true, completion: nil)
        }else{
             print("Friend IS a Group!")
            vc.username = prefs.value(forKey: "USERNAME") as! String
            vc.friendname = self.someInts[indexPath.row].username
            vc.showuser = prefs.value(forKey: "SHOWNAME") as! String
            vc.showfriend = self.someInts[indexPath.row].friendname
            vc.rendezNotifTimeFlag = prefs.value(forKey: self.someInts[indexPath.row].username) as! Date
            vc.flag = 1
            prefs.set(Date(), forKey: self.someInts[indexPath.row].username)
            print(self.someInts[indexPath.row].username + " prefs time now set to ")
            self.delegate.theNotifHelper.resetCounts(self.someInts[indexPath.row].username)
            //print(NSDate())
            vc.ggroup = self.delegate.getGroup(self.someInts[indexPath.row].username)
            self.present(vc, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func onCreateGroupClicked(_ sender: UIButton) {
        createGroupVC = self.storyboard?.instantiateViewController(withIdentifier: "createGroup") as! onCreateGroupVC

        print(Date())
        
        
        self.present(createGroupVC, animated: true, completion: nil)
        
    }
    
    @IBAction func newR(_ sender: AnyObject) {
   
    }
}
