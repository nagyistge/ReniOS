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
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var flag:Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLabel.text = "Me"
        if(flag == -1){
            friendLabel.text = showfriend
        }else{
            friendLabel.text = friendname
        }
        //lets assume we need all this bs for now
        tableVie.delegate = self
       tableVie.dataSource = self
        tableVie.estimatedRowHeight = 60.0
        tableVie.rowHeight = UITableViewAutomaticDimension
        txtChatBox.delegate = self
        
        //NSNotificaiton thingy set
        NotificationCenter.default.addObserver(self, selector: #selector(chattingR.updateChattingNotif(_:)), name: NSNotification.Name(rawValue: chattingNotifKey), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let statuslist = self.delegate.theWozMap[friendname]!
        let rendez = statuslist?.allDeesChat
        self.messagesArray.removeAll()
        self.messagesArray.append( rendez)
        updateTableview()
        NSLog("\n THE CHAT HAS RETRIEVED THE STATIC LIST FROM THE WOZ")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.messagesArray.removeAll()
        self.messagesArray.append(contentsOf: delegate.theWozMap[friendname]!.allDeesChat! )
        updateTableview()
       print("\n THE CHAT HAS RETRIEVED THE STATIC LIST FROM THE WOZ")
    }
    
    //NSNotificationStuff---NSNotificationStuff---
    //-ON RECIEVE
    //should be called by the app delegate when it gets new emit by the NSNotificationCenter
    internal func updateChattingNotif(_ notification:Notification){
        print("is the update in rendezChat even called??")
        //get the friend param and set it
        let postparam = notification.userInfo as? [String: AnyObject]
        print(postparam)
        let friendNotif:Chat = postparam!["chatstatus"]! as! Chat
        if(friendNotif.username == friendname){
            self.messagesArray.append(friendNotif)
            self.updateTableview()
        }
    }
    
    //----------ON SEND
    @IBAction func onChatSend(_ sender: UIButton) {
        if((self.txtChatBox.text!.isEmpty)){
            
        }
        else{
            let postMsg = self.txtChatBox.text!
            let chatobj = ["friend": friendname, "detail": postMsg]
            let chatMsg = Chat(username: username, details: postMsg, time: Date(), toUser: friendname)
            let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            //emit the message
            delegate.chatarr.append(chatobj as AnyObject)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableVie.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
        var senderLabelText: String!
        var senderColor: UIColor!
        //set the time to local
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeStyle = DateFormatter.Style.medium
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeZone = TimeZone()

        let currentMessage = messagesArray[indexPath.row] as Chat
        let date = dateFormatter.string(from: currentMessage.time as Date)
        
        if currentMessage.username == username {
                senderLabelText = "I said at:" + date
                senderColor = UIColor.blue
            print("Chat set to user")
        }
        else{
            if(flag == -1){
                senderLabelText = showfriend + " said at:" + date
                senderColor = UIColor.red
                print("Chat set to friend")
            }else{
                senderLabelText = currentMessage.username + " said at:" + date
                senderColor = UIColor.red
                print("Chat set to friend")
            }
        }
        print(senderLabelText)
        cell.detailTextLabel?.text = senderLabelText
        cell.detailTextLabel?.textColor = senderColor
        cell.textLabel?.text = currentMessage.details as String
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //Just a method for refreshes tableview data and scrolls down to the bottom of the screen
    func updateTableview(){
        self.tableVie.reloadData()
        if self.tableVie.contentSize.height > self.tableVie.frame.size.height {
            tableVie.scrollToRow(at: IndexPath(row: messagesArray.count - 1, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    //ugly mofo sql query that needs to insert the chat into the database for reference
    func sentToDatabase(_ messege:String){
        //this is the meta array... contains all 3 values[sender, msg, reciever]
        var arr = [AnyObject]()
        //array that holds friends, but in this case should only be one friend...
        var friendarr = [AnyObject]()
        //create and add the user object here
        let userObject = ["username": self.username, "showname": self.showuser]
        arr.append(userObject as AnyObject)
        //create the chat message
        let statusObject = ["detail": messege]
        arr.append(statusObject as AnyObject)
        let friendObj = ["username": friendname, "showname": showfriend]
        friendarr.append(friendObj as AnyObject)
        if(friendarr.count == 0){
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "You have not chosen any friends!!"
            alertView.message = "Choose a friend loser"
            alertView.delegate = self
            alertView.addButton(withTitle: "OK")
            alertView.show()
        }
        else{
            let friendarray = ["array": friendarr]
            arr.append(friendarray as AnyObject)
            let aNSArray:NSArray = arr as NSArray
            let final:NSDictionary = ["json": aNSArray]
            NSLog("PostData: %@",final);
            let url:URL = URL(string: "http://www.jjkbashlord.com/sendChatRSwift.php")!
            let da:Data = try! JSONSerialization.data(withJSONObject: final, options: [])
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
            }catch _{
                urlData = nil
            }
            if ( urlData != nil ) {
                let res = response as! HTTPURLResponse!;
                NSLog("Response code: %ld", res?.statusCode);
                if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
                {
                    NSLog("sent!!!!!!!")
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
