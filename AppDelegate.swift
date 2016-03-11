//
//  AppDelegate.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/23/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit
import GoogleMaps
//import SocketIOClientSwift

let FriendActivityNotifKey = "com.jjkbashlord.FriendsActivity"
let rendezChatNotifKey = "com.jjkbashlord.rendezChat"
let chattingNotifKey = "com.jjkbashlord.chatting"
let emitRendezKey = "com.jjkbashlord.emitRendez"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //VARIABLE DECLARATIONS >>>>>>>>>>>>>>>>>
    //tempfriend array to be able to EMIT PROPERLY
    internal var friendarr = [AnyObject]()
    internal var chatarr = [AnyObject]()
    
    
    
    
    var window: UIWindow?
    var timer: NSTimer?
    internal var mSocket:SocketIOClient = SocketIOClient(socketURL: Constants.CHAT_SERVER_URL)
    
    var namesDictionary=Dictionary<String,String>()
    
    /*Array that consists of Friend elements.
        Friend element consists of:
            .username
            .showname
            .time (last instance of when you last check notificaitons from them.  Should only he referenced on login since prefs will keep these values updated on the device afterwards, and later updated to a sql table on logout)
    */
    internal var yourFriends = [Friend]()
    
    /*
                                        -=Xxx> theWozMap <xxX=-
                        Essentially the holy grail data structure for the app
    -Is a DICTIONARY of String <Key> to rendezChatDicionary <value> pairings
        -String key is the username of that specific friend
        -rendezChatDictionary is the value that consists of all the chat data (Rendezes and actual chat messeges)
    - Whenever viewing a friend's rendezes or chat, a viewcontroller container retrieves it all from here.  Rather than initialize multiple
        viewcontrollers for every single chat or whatever.
        -When does it initialize for a certain friend?
            -When an emit from a friend is caught, theWozMap will query and append that messege to the instance of that friend
            -When you do not have any new notifications from that friend since app launch and on the INITIAL click on that friend's name,
                theWoz will call a query for all past messeges
    */
    internal var theWozMap = Dictionary<String,rendezChatDictionary!>()
    internal var newfeed = [Status]()
    
    
    //EVENT MANAGER CAUSE SOCKETS BEING CHEEKY
    internal var events = EventManager()

    //END OF VARIABLE DECLARATIONS, NOW ONTO THE APPLICATION LIFECYCLE FUNCTIONS>>>>>>>>>>>>
    
//>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<~~^*%^*%*@$&*(^*($@*()$*()&$()&()@$&*()@*()
    
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~APPLICATION STATE STUFF DEALING WITH ITS LIFECYCLE~~~~~~~~~
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        pageControl.backgroundColor = UIColor.whiteColor()
       // var provideAPIKey:GMSServices = "AIzaSyCtZkaftILPjennmNLcm5iiIFatU3Lgglg"
        
         GMSServices.provideAPIKey("AIzaSyCtZkaftILPjennmNLcm5iiIFatU3Lgglg")
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))  // types are UIUserNotificationType members
        
        
        //NSNOTIFICATION OBSERVER INITILIZER
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "emitRendezNotif:", name: emitRendezKey, object: nil)

        
        
        
        
        
        //self.FriendsActivity.go
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        //the old foolish notification system elegiggle
        //var updateTimer = NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: Selector("getNotification"), userInfo: nil, repeats: true)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.\
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        let username = prefs.valueForKey("USERNAME") as! String
        if(self.theWozMap[username] == nil){
            starting()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    //~~~~~~~END OF THE APPLICATION LIFECYCLES STATES~~~~~~~~
    
//--------------------------------------------------------------------------------------------------
    
    //^^^^^^^^^^^ NSNOTIFICATION CENTER STUFF THAT ALERTS VIEWCONTROLLERS FROM THE APPDELEGATE
    
    func notifyFriendsActivity(friend:Friend){
    
        let friend1: Friend = Friend(username: friend.username, showname: friend.friendname, timestamp: NSDate())
        let post:[NSObject : AnyObject] = ["friend": friend1]
        NSNotificationCenter.defaultCenter().postNotificationName(FriendActivityNotifKey, object: self, userInfo: post)
    
    }
    
    func notifyRendezChat(chatStatus: ChatStatus){
        //chatstatus should be perfectly contructed and passed along with no changed from the parameter
        let post:[NSObject : AnyObject] = ["chatstatus": chatStatus]
        NSNotificationCenter.defaultCenter().postNotificationName(rendezChatNotifKey, object: self, userInfo: post)
    }
    
    func notifyChatting(chatStatus: ChatStatus){
        //chatstatus should be perfectly contructed and passed along with no changed from the parameter
        let post:[NSObject : AnyObject] = ["chatstatus": chatStatus]
        NSNotificationCenter.defaultCenter().postNotificationName(chattingNotifKey, object: self, userInfo: post)
    }

    
    
    
    //^^^^^^^^^^^^^^^^^^END OF THE NOTIFICAIOTN CENTER STUFF
    
//--------------------------------------------------------------------------------------------------
    
    //~*************THE BEGINNING OF ALL THE AMAZING WOZ/SOCKET STUFF :]]]]]]]]]]]]]]]]]]]]]]]]]]]
    
    //used just to load your friends from a query.  Stores them in an array in app delegate
    func loadFriends(friendlist:[Friend]){
        self.yourFriends.appendContentsOf( friendlist)
    }
    
    
    //need to get your friends from somewhere, should be called when you login or mainactivity crashes/restarts
    func queryFriends(username:String){
        let post:NSString = "username=\(username)"
        NSLog("PostData: %@",post);
        var php:String = ""
        php = "showFriendlist.php"
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/" + php)!
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
                    let title1:NSString = jsonData[index].valueForKey("friendname") as! NSString
                    let status = Friend(username: username1 as String, showname: title1 as String, timestamp: NSDate())
                    self.yourFriends.append(status)
                    print("Friend Entity added: " + status.friendname)
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
    
    
    }
    
    func starting(){
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    let username = prefs.valueForKey("USERNAME") as! String
    var initRendezChatD:rendezChatDictionary = onStart(username)
    
    self.theWozMap[username] = rendezChatDictionary()
    
    for(var i = 0; i < initRendezChatD.allDeesStatus.count; i++){
    //theWozMap is a map of string names to rendezdictionaries so need to make sure that the correct stuff maps to the right names
    if( initRendezChatD.allDeesStatus[i].username == username){
    self.theWozMap[username]!.allDeesStatus.append(initRendezChatD.allDeesStatus[i])
    }else{
    if( self.theWozMap[initRendezChatD.allDeesStatus[i].username] == nil ){
    self.theWozMap[initRendezChatD.allDeesStatus[i].username] = rendezChatDictionary()
    }
    self.theWozMap[initRendezChatD.allDeesStatus[i].username]!.allDeesStatus.append(initRendezChatD.allDeesStatus[i])
    self.newfeed.append(initRendezChatD.allDeesStatus[i])
    }
    }
    
    for(var i = 0; i < initRendezChatD.allDeesRendez.count; i++){
    //theWozMap is a map of string names to rendezdictionaries so need to make sure that the correct stuff maps to the right names
    if( initRendezChatD.allDeesRendez[i].username == username){
    if( self.theWozMap[initRendezChatD.allDeesRendez[i].fromuser] == nil ){
    self.theWozMap[initRendezChatD.allDeesRendez[i].fromuser] = rendezChatDictionary()
    }
    self.theWozMap[initRendezChatD.allDeesRendez[i].fromuser]!.allDeesRendez.append(initRendezChatD.allDeesRendez[i])
    
    }else{
    if( self.theWozMap[initRendezChatD.allDeesRendez[i].username] == nil ){
    self.theWozMap[initRendezChatD.allDeesRendez[i].username] = rendezChatDictionary()
    }
    self.theWozMap[initRendezChatD.allDeesRendez[i].username]!.allDeesRendez.append(initRendezChatD.allDeesRendez[i])
    
    }
    }
    
    for(var i = 0; i < initRendezChatD.allDeesChat.count; i++){
    //theWozMap is a map of string names to rendezdictionaries so need to make sure that the correct stuff maps to the right names
    if( initRendezChatD.allDeesChat[i].username == username){
    
    if( self.theWozMap[initRendezChatD.allDeesChat[i].toUser] == nil ){
    self.theWozMap[initRendezChatD.allDeesChat[i].toUser] = rendezChatDictionary()
    }
    self.theWozMap[initRendezChatD.allDeesChat[i].toUser]!.allDeesChat.append(initRendezChatD.allDeesChat[i])
    print(initRendezChatD.allDeesChat[i])
    
    }else{
    if( self.theWozMap[initRendezChatD.allDeesChat[i].username] == nil ){
    self.theWozMap[initRendezChatD.allDeesChat[i].username] = rendezChatDictionary()
    }
    self.theWozMap[initRendezChatD.allDeesChat[i].username]!.allDeesChat.append(initRendezChatD.allDeesChat[i])
    print(initRendezChatD.allDeesChat[i])
    }
    }
}
    
    
    //parameter should be the username of the friend that you are checking
    func isTheFriendInTheWoz(friendname:String) -> Bool{
        NSLog("is he a friend of the WOZ?")
        NSLog(friendname)
        if (self.theWozMap[friendname] == nil){
            NSLog("nah fok this guy")
            return false
        }
        else{
            NSLog("yeah hes coo fam")
            return true
        }
    }
    
    
    func onStart(username:String ) -> rendezChatDictionary{
        //initialize the rendez and chat arrays that will be stored in the rendezChatDictionary later
        var someRendez = [RendezStatus]()
        var someStatus = [Status]()
        var someChat = [Chat]()
        //the rendezChatDictionary to be returned at the end as well as inserted into theWoz
        let returnDic: rendezChatDictionary = rendezChatDictionary()
        let post:NSString = "username=\(username)"
        NSLog("PostData: %@",post);
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/onLoginAndroid.php")!
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
                let jsonData:NSObject = (try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers )) as! NSObject
                //this is the forloop of every single rendez and chat in the table
                //They are looped through and sorted and put into their respected containers
                
                let jsonDataStatus: NSArray = jsonData.valueForKey("Status") as! NSArray
                let jsonDataRendez: NSArray = jsonData.valueForKey("RendezStatus") as! NSArray
                let jsonDataChat: NSArray = jsonData.valueForKey("RendezChat") as! NSArray
                
                
                
                for(var index = 0; index < jsonDataStatus.count; index++ ){
                    //if((jsonDataStatus[index].valueForKey("title") as! NSString).length > 0){
                    //gets the variables for a rendezvous
                    
                    let id:Int = jsonDataStatus[index].valueForKey("id") as! Int
                    let username1:NSString = jsonDataStatus[index].valueForKey("username") as! NSString
                    let title1:NSString = jsonDataStatus[index].valueForKey("title") as! NSString
                    let detail1:NSString = jsonDataStatus[index].valueForKey("details") as! NSString
                    let location1:NSString = jsonDataStatus[index].valueForKey("location") as! NSString
                    let timeset:NSString = jsonDataStatus[index].valueForKey("timeset") as! NSString
                    let timefor:NSString = jsonDataStatus[index].valueForKey("timefor") as! NSString
                    
                    
                    let type:Int = jsonDataStatus[index].valueForKey("type") as! Int
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                    var date1 = dateFormatter.dateFromString(timeset as String)
                    date1 = dateFormatter.dateFromString(timeset as String)
                    
                    var date2 = dateFormatter.dateFromString(timefor as String)
                    date2 = dateFormatter.dateFromString(timefor as String)
                    
                    //if this is true, it is a status by you, meaning get the array of friend responses from your friends
                    if(username1 == username){
                        let fromuser:NSArray = jsonDataStatus[index].valueForKey("fromuser") as! NSArray
                        var fu = [fromUser]()
                        for(var b = 0; b < fromuser.count; b++){
                            let fu1:NSObject = fromuser[b] as! NSObject
                            
                            fu.append( fromUser( username: fu1.valueForKey("friendname") as! String ,response: fu1.valueForKey("response") as! Int  ))
                        }
                        
                        let visable: Int = jsonDataStatus[index].valueForKey("visable") as! Int
                
                        let status = Status(id: id, username: username1 as String, title: title1 as String, detail: detail1 as String, location: location1 as String, timeset: timeset as String, timefor: timefor as String, type: type, fromuser:fu , visable: visable)
                       // print("ADDED TOSTATUS")
                        //print(jsonDataStatus[index])
                        someStatus.append(status)
                    }else{
                        let fromusername:NSString = jsonDataStatus[index].valueForKey("fromuser") as! NSString
                        let response: Int = jsonDataStatus[index].valueForKey("response") as! Int
                        
                        let status = Status(id: id, username: username1 as String, title: title1 as String, detail: detail1 as String, location: location1 as String, timeset: timeset as String, timefor: timefor as String, type: type,visable: 1, fromusername:fromusername as String, response: response)
                        //print("ADDED TO STATUS")
                        //print(jsonDataStatus[index])
                        someStatus.append(status)
                    }
                }
                
                    //  }else{
                    for(var index = 0; index < jsonDataRendez.count; index++ ){
                        
                        let id:Int = jsonDataRendez[index].valueForKey("id") as! Int
                        let username1:NSString = jsonDataRendez[index].valueForKey("username") as! NSString
                        let title1:NSString = jsonDataRendez[index].valueForKey("title") as! NSString
                        let detail1:NSString = jsonDataRendez[index].valueForKey("detail") as! NSString
                        let location1:NSString = jsonDataRendez[index].valueForKey("location") as! NSString
                        let timeset:NSString = jsonDataRendez[index].valueForKey("timeset") as! NSString
                        let timefor:NSString = jsonDataRendez[index].valueForKey("timefor") as! NSString
                        
                        
                        let type:Int = jsonDataRendez[index].valueForKey("type") as! Int
                        let response:Int = jsonDataRendez[index].valueForKey("response") as! Int
                        let fromuser:String = jsonDataRendez[index].valueForKey("fromuser") as! NSString as String
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                        var date1 = dateFormatter.dateFromString(timeset as String)
                        date1 = dateFormatter.dateFromString(timeset as String)
                        
                        var date2 = dateFormatter.dateFromString(timefor as String)
                        date2 = dateFormatter.dateFromString(timefor as String)
                        let status = RendezStatus(id: id, username: username1 as String, title: title1 as String, details: detail1 as String, location: location1 as String, timeset: timeset as String, timefor: timefor as String, type: type, response:response, fromuser:fromuser)
                     //   print("ADDED TO RENDEZ")
                      //  print(jsonDataRendez[index])
                        someRendez.append(status)
                        
                    }
                    
                    
                    for(var index = 0; index < jsonDataChat.count; index++ ){
                        let username1:NSString = jsonDataChat[index].valueForKey("username") as! NSString
                        let detail1:NSString = jsonDataChat[index].valueForKey("chat") as! NSString
                        let status1:NSString = jsonDataChat[index].valueForKey("time") as! NSString
                        let touser:NSString = jsonDataChat[index].valueForKey("friendname") as! NSString
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                        var date = dateFormatter.dateFromString(status1 as String)
                        date = dateFormatter.dateFromString(status1 as String)
                        
                        let status = Chat(username: username1 as String, details: detail1 as String, time: date!, toUser: touser as String)
                        //print("ADDED TO CHAT")
                        someChat.append(status)
                    }
                //this marks the end of the forloop.  someRendez and someChat SHOULD be populated by now...
                returnDic.allDeesRendez = someRendez
                returnDic.allDeesChat = someChat
                returnDic.allDeesStatus = someStatus
               // self.theWozMap[friendname] = returnDic
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
        return returnDic
    }
    
    
    
    
    
    
    //--- THIS METHOD WILL BE DEPRECIATED
    //-------ITS SORT OF POINTLESS TO GET EACH FRIEND THIS DYNAMICALLY SINCE INITIALIZING HTTPS HANDSHAKES AND WHATNOT COST MORE THAN JUST
    //GETTING ALL THE DATA FROM THE START SO SCREW IT
    /*Should be called every time a friend is picked from the friendlist for the first time
        PARMETERS: username of the user, Friendname of the person you are initiating
        RETURNS: rendezChatDictionary of the friend from the sql database
        Extra info: Reason for this is to dynamically allocate the rendez chats of each friend.
                Rather than load all the messages at once, the messeges of each friend are queried
                and retrieved THE FIRST TIME you click on their name to see the chats.
                It should return the rendezChatDictionary to the viewcontroller initially, but
                it should also store it into theWoz, so the next time that friend is opened, it does
                not to a HTTP mysqli query request
    */
    func makeFriendsWithWoz(username:String, friendname:String) -> rendezChatDictionary{
        //initialize the rendez and chat arrays that will be stored in the rendezChatDictionary later
        var someRendez = [RendezStatus]()
        var someStatus = [Status]()
        var someChat = [Chat]()
        //the rendezChatDictionary to be returned at the end as well as inserted into theWoz
        let returnDic: rendezChatDictionary = rendezChatDictionary()
        let post:NSString = "username=\(username)&friend=\(friendname)"
        NSLog("PostData: %@",post);
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/.php")!
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
                let jsonData:NSObject = (try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers )) as! NSObject
                //this is the forloop of every single rendez and chat in the table
                //They are looped through and sorted and put into their respected containers
                
                let jsonDataStatus: NSArray = jsonData.valueForKey("Status") as! NSArray
                let jsonDataRendez: NSArray = jsonData.valueForKey("RendezStatus") as! NSArray
                let jsonDataChat: NSArray = jsonData.valueForKey("RendezChat") as! NSArray
                
                
                
                for(var index = 0; index < jsonDataStatus.count; index++ ){
                    //if((jsonDataStatus[index].valueForKey("title") as! NSString).length > 0){
                        //gets the variables for a rendezvous
                        
                        let id:Int = jsonDataStatus[index].valueForKey("id") as! Int
                        let username1:NSString = jsonDataStatus[index].valueForKey("username") as! NSString
                        let title1:NSString = jsonDataStatus[index].valueForKey("title") as! NSString
                        let detail1:NSString = jsonDataStatus[index].valueForKey("detail") as! NSString
                        let location1:NSString = jsonDataStatus[index].valueForKey("location") as! NSString
                        let timeset:NSString = jsonDataStatus[index].valueForKey("timeset") as! NSString
                        let timefor:NSString = jsonDataStatus[index].valueForKey("timefor") as! NSString
                        
                        
                        let type:Int = jsonDataStatus[index].valueForKey("type") as! Int
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                        var date1 = dateFormatter.dateFromString(timeset as String)
                        date1 = dateFormatter.dateFromString(timeset as String)
                        
                        var date2 = dateFormatter.dateFromString(timefor as String)
                        date2 = dateFormatter.dateFromString(timefor as String)
                        
                        //if this is true, it is a status by you, meaning get the array of friend responses from your friends
                        if(username1 == username){
                            let fromuser:NSArray = jsonDataStatus[index].valueForKey("fromuser") as! NSArray
                            let visable: Int = jsonDataStatus[index].valueForKey("visable") as! Int
                            
                           // let status = Status(id: id, username: username1 as String, title: title1 as String, detail: detail1 as String, location: location1 as String, timeset: timeset as String, timefor: timefor as String, type: type, fromuser:fromuser, visable: visable)
                            print("ADDED TO RENDEZ")
                            //someStatus.append(status)
                        }else{
                            let fromusername:NSString = jsonDataStatus[index].valueForKey("fromuser") as! NSString
                            let response: Int = jsonDataStatus[index].valueForKey("response") as! Int
                            
                            let status = Status(id: id, username: username1 as String, title: title1 as String, detail: detail1 as String, location: location1 as String, timeset: timeset as String, timefor: timefor as String, type: type,visable: 1, fromusername:fromusername as String, response: response)
                            print("ADDED TO RENDEZ")
                            someStatus.append(status)
                        }
                        
                  //  }else{
                    for(var index = 0; index < jsonDataRendez.count; index++ ){
                        
                        let id:Int = jsonDataRendez[index].valueForKey("id") as! Int
                        let username1:NSString = jsonDataRendez[index].valueForKey("username") as! NSString
                        let title1:NSString = jsonDataRendez[index].valueForKey("title") as! NSString
                        let detail1:NSString = jsonDataRendez[index].valueForKey("detail") as! NSString
                        let location1:NSString = jsonDataRendez[index].valueForKey("location") as! NSString
                        let timeset:NSString = jsonDataRendez[index].valueForKey("timeset") as! NSString
                        let timefor:NSString = jsonDataRendez[index].valueForKey("timefor") as! NSString
                        
                        
                        let type:Int = jsonDataRendez[index].valueForKey("type") as! Int
                        let response:Int = jsonDataRendez[index].valueForKey("response") as! Int
                        let fromuser:String = jsonDataRendez[index].valueForKey("fromuser") as! NSString as String
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                        var date1 = dateFormatter.dateFromString(timeset as String)
                        date1 = dateFormatter.dateFromString(timeset as String)
                        
                        var date2 = dateFormatter.dateFromString(timefor as String)
                        date2 = dateFormatter.dateFromString(timefor as String)
                        let status = RendezStatus(id: id, username: username1 as String, title: title1 as String, details: detail1 as String, location: location1 as String, timeset: timeset as String, timefor: timefor as String, type: type, response:response, fromuser:fromuser)
                        print("ADDED TO RENDEZ")
                        someRendez.append(status)
                        
                    }
        
                    
                    for(var index = 0; index < jsonDataChat.count; index++ ){
                        let username1:NSString = jsonDataChat[index].valueForKey("username") as! NSString
                        let detail1:NSString = jsonDataChat[index].valueForKey("detail") as! NSString
                        let status1:NSString = jsonDataChat[index].valueForKey("timestamp") as! NSString
                        let touser:NSString = jsonDataChat[index].valueForKey("touser") as! NSString
                
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                        var date = dateFormatter.dateFromString(status1 as String)
                        date = dateFormatter.dateFromString(status1 as String)
                        
                        let status = Chat(username: username1 as String, details: detail1 as String, time: date!, toUser: touser as String)
                        print("ADDED TO CHAT")
                        someChat.append(status)
                    }
                }//this marks the end of the forloop.  someRendez and someChat SHOULD be populated by now...
                returnDic.allDeesRendez = someRendez
                returnDic.allDeesChat = someChat
                returnDic.allDeesStatus = someStatus
                self.theWozMap[friendname] = returnDic
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
        return returnDic
    }
    
    //should be called whenever a rendez is sent to ALL selected recipients
    func emitRendez(information: Any?){
        let postparam:Dictionary<String, String!> = information as! Dictionary<String, String!>
        
        
        print("is emitrendez called")
        let id = postparam["id"]
        let friend = postparam["friend"]
        let title = postparam["title"]
        let details = postparam["detail"]
        let location = postparam["location"]
        let timefor = postparam["timefor"]
        let type = postparam["type"]
        let response = 0
        
        self.mSocket.emit( id!, friend!, title!, details!, location!, NSDate(), timefor!, type!, response)
    }
    //should be called whenever a chat msg is sent to
    func emitChat(reciever:String, detail:String){
        self.mSocket.emit("send chat", reciever, detail, NSDate())
    }
    
    /*
        TURNS ON YO LISTENERS
        should be called when login occurs/user is logged in.  This turns on the listeners for new messeges
        Parameters:
            username1: username of the user
            showname1: display of the user
        These should be set to log in the server with identifiers
    */
    func letsGetDatSocketRollin(username1:String, showname1:String){
        let username = username1
        
        self.mSocket.on("connect") {data, ack in
            print("socket connected")
            self.mSocket.emit("joinserver", username, showname1)
            
            self.events.listenTo("emitRendez", action: {
                print("friend array count")
                print(self.friendarr.count)
                let title = self.friendarr[0].valueForKey("title") as! String
                let detail = self.friendarr[0].valueForKey("detail") as! String
                let location = self.friendarr[0].valueForKey("location") as! String
                print("title: " + title)
                print("detail: " + detail)
                print("locaiton: "  + location)
                
                for friend in self.friendarr{
                    let name = friend.valueForKey("friend") as! String
                    self.mSocket.emit("send", name, title, detail, location, "0")
                }
                self.friendarr.removeAll()
            })
            
            self.events.listenTo("emitChat", action: {
                let detail = self.chatarr[0].valueForKey("detail") as! String
                print("detail: " + detail)
                let name = self.chatarr[0].valueForKey("friend") as! String
                self.mSocket.emit("send chat", name, detail, "00")

                self.friendarr.removeAll()
            })
        }


        
        //When or if the user is logged in, turn on the socket listeners here
        self.mSocket.on("new chat"){data, ack in
            if let cur:NSDictionary = data?[0] as? NSDictionary {
                
               let friendname = cur.objectForKey("username") as! String
                let message = cur.objectForKey("detail") as! String
               // let touser = cur.objectForKey("touser") as! String
               // let time = cur.objectForKey("time") as! NSDate
                let touser = username
                if(!self.isTheFriendInTheWoz(friendname)){
                    self.makeFriendsWithWoz(username, friendname: friendname)
                }
                
                let temp:rendezChatDictionary = self.theWozMap[friendname]!
                temp.putInChat(Chat(username: friendname, details: message, time: NSDate(),toUser: touser))
                self.theWozMap[friendname] = temp
                
                let localNotification: UILocalNotification = UILocalNotification()
                localNotification.alertAction = "YO BOI GOT THAT MUTHA FUCKIN SOCKET EMIT WOOOOOOOOOOO"
                localNotification.alertBody = "YA GOT A CHAT CHICO"
                localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
                
                //this should fire off the update in friends activity...
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                let friend = Friend(username: friendname as String, showname: showname1 as String, timestamp: NSDate())
                self.notifyFriendsActivity(friend)
                let rendezChat = ChatStatus(username: friendname, detail: message, time: NSDate())
                self.notifyChatting(rendezChat)
            }
            else{
                print("something shoulda happened")
            }
        }
        
        self.mSocket.on("new rendez"){data, ack in
            let whatisit = data?[0]
            print(whatisit)
            if let cur:NSDictionary = data?[0] as? NSDictionary {
                let id = cur.objectForKey("id") as! Int
                let friendname = cur.objectForKey("username") as! NSString
                let showname1 = cur.objectForKey("showname") as! NSString
                let title1 = cur.objectForKey("title") as! NSString
                let message = cur.objectForKey("detail") as! NSString
                let location1 = cur.objectForKey("location") as! NSString
                let time = cur.objectForKey("timefor") as! NSString
                let type = cur.objectForKey("type") as! Int
                let response = cur.objectForKey("response") as! Int
                let fromuser = username
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                var timefor = dateFormatter.dateFromString(time as String)
               // timefor = dateFormatter.dateFromString(time as String)
                
                var timeset = dateFormatter.stringFromDate(NSDate())
                //timeset = dateFormatter.dateFromString(time asg)
                
                print(friendname, title1, message, location1)
                if(!self.isTheFriendInTheWoz(friendname as String)){
                    self.makeFriendsWithWoz(username, friendname: friendname as String)
                }
                
        

                
                let temp:rendezChatDictionary = self.theWozMap[friendname as String]!
                temp.putInRendez(RendezStatus(id: id, username: friendname as String, title: title1 as String, details: message as String, location: location1 as String, timeset: timeset, timefor: time as String, type: type, response: response, fromuser: fromuser as String))
                self.theWozMap[friendname as String] = temp
                let localNotification: UILocalNotification = UILocalNotification()
                localNotification.alertAction = "YO BOI GOT THAT MUTHA FUCKIN SOCKET EMIT WOOOOOOOOOOO"
                localNotification.alertBody = "Woww it works!!"
                localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
                //this should fire off the update in friends activity...
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                let friend = Friend(username: friendname as String, showname: showname1 as String, timestamp: NSDate())
                self.notifyFriendsActivity(friend)
                let rendezChat = ChatStatus(username: friendname, title: title1, detail: message, location: location1, time: NSDate())
                self.notifyRendezChat(rendezChat)
                
            }
            else{
                print("something shoulda happened")
                
            }
        }

    //}
        //after listeners are on, connect to the URI and emit a join server
        //mSocket.emit("joinserver", username)
        self.mSocket.connect()
        self.mSocket.emit("joinserver", username, showname1)
    }
    
    
    //NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---

    //should be called by the app delegate when it gets new emit by the NSNotificationCenter
    //all this should do is change the friend notif time and update the table
    internal func emitRendezNotif(notification:NSNotification){
        print("is the update in rendezChat even called??")
        
        //get the friend param and set it
        let postparam:Dictionary<String, ChatStatus!> = notification.userInfo as! Dictionary<String, ChatStatus!>
        let friendNotif:ChatStatus = postparam["chatstatus"]!
        
    }

}