//
//  chattingR.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 9/2/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

class chattingR: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    //usernames
    var username: String!
    var friendname: String!
    //display names
    var showuser: String!
    var showfriend: String!
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var friendLabel: UILabel!
    
    @IBOutlet weak var tableVie: UITableView!
    @IBOutlet weak var txtChatBox: UITextField!

    let transitionOperator = TransitionOperator()
   
    @IBOutlet weak var customCell: UITableViewCell!
    

    var messagesArray = [Chat]()
    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userLabel.text = showuser
        friendLabel.text = showfriend
        
        //lets assume we need all this bs for now
        tableVie.delegate = self
       tableVie.dataSource = self
        tableVie.estimatedRowHeight = 60.0
        tableVie.rowHeight = UITableViewAutomaticDimension
        txtChatBox.delegate = self
        
        
        

        //NSNotificaiton thingy set
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateChattingNotif:", name: chattingNotifKey, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        let statuslist = self.delegate.theWozMap[friendname]!
        let rendez = statuslist.allDeesChat
        self.messagesArray.appendContentsOf( rendez)
        //self.messagesArray = messagesArray.reverse()
        
        //self.tableVie.reloadData()
        updateTableview()
        NSLog("\n THE CHAT HAS RETRIEVED THE STATIC LIST FROM THE WOZ")
        
    }
    



    
    //NSNotificationStuff---NSNotificationStuff---
    
    //-ON RECIEVE
    //should be called by the app delegate when it gets new emit by the NSNotificationCenter
    internal func updateChattingNotif(notification:NSNotification){
        print("is the update in rendezChat even called??")
        
        //get the friend param and set it
        let postparam:Dictionary<String, Chat!> = notification.userInfo as! Dictionary<String, Chat!>
        let friendNotif:Chat = postparam["chatstatus"]!
        
        if(friendNotif.username == friendname){
            self.messagesArray.append(friendNotif)
            self.updateTableview()
        }
    }
    
    //----------ON SEND
    @IBAction func onChatSend(sender: UIButton) {
        if((self.txtChatBox.text!.isEmpty)){
            
        }
        else{
            let postMsg = self.txtChatBox.text!
            let chatobj = ["friend": friendname, "detail": postMsg]
            let chatMsg = Chat(username: username, details: postMsg, time: NSDate(), toUser: friendname)
            let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            //emit the message
            delegate.chatarr.append(chatobj)
            //send it to the db
            self.sentToDatabase(postMsg)
            //append it to the msg list
            self.messagesArray.append(chatMsg)
            self.updateTableview()
            delegate.events.trigger("emitChat")
            self.delegate.theWozMap[friendname]!.allDeesChat.append(chatMsg)
        }
        self.txtChatBox.text = ""
    }
  
    //--TABLE STUFF ------TABLE STUFF ------TABLE STUFF ------TABLE STUFF ------TABLE STUFF ------
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableVie.dequeueReusableCellWithIdentifier("customCell", forIndexPath: indexPath)

        
        var senderLabelText: String!
        var senderColor: UIColor!
        
        //set the time to local
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeZone = NSTimeZone()

        
        let currentMessage = messagesArray[indexPath.row] as Chat
        let date = dateFormatter.stringFromDate(currentMessage.time)
        
        if currentMessage.username == username {
                senderLabelText = "I said at:" + date
                senderColor = UIColor.blueColor()
            print("Chat set to user")
        }
        else{
                senderLabelText = showfriend + " said at:" + date
                senderColor = UIColor.redColor()
                print("Chat set to friend")
        }
        print(senderLabelText)

            cell.detailTextLabel?.text = senderLabelText
            cell.detailTextLabel?.textColor = senderColor
            cell.textLabel?.text = currentMessage.details as String
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Just a method for refreshes tableview data and scrolls down to the bottom of the screen
    func updateTableview(){
        self.tableVie.reloadData()
        if self.tableVie.contentSize.height > self.tableVie.frame.size.height {
            tableVie.scrollToRowAtIndexPath(NSIndexPath(forRow: messagesArray.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    
    //ugly mofo sql query that needs to insert the chat into the database for reference
    func sentToDatabase(messege:String){
        //this is the meta array... contains all 3 values[sender, msg, reciever]
        var arr = [AnyObject]()
        
        //array that holds friends, but in this case should only be one friend...
        var friendarr = [AnyObject]()
        
        //create and add the user object here
        let userObject = ["username": self.username, "showname": self.showuser]
        arr.append(userObject)
        
        //create the chat message
        let statusObject = ["detail": messege]
        arr.append(statusObject)
        

        let friendObj = ["username": friendname, "showname": showfriend]
        friendarr.append(friendObj)


        if(friendarr.count == 0){
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "You have not chosen any friends!!"
            alertView.message = "Choose a friend loser"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        else{
            let friendarray = ["array": friendarr]
            arr.append(friendarray)
            let fuckingNSArray:NSArray = arr
            let fuckingfinal:NSDictionary = ["json": fuckingNSArray]
            NSLog("PostData: %@",fuckingfinal);
            let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/sendChatRSwift.php")!
            let da:NSData = try! NSJSONSerialization.dataWithJSONObject(fuckingfinal, options: [])
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
            }catch _{
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
