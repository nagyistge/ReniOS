import UIKit
import GoogleMaps

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
    internal var grouparr = [AnyObject]()
    
    var printFlag = false
    var badgeCount = 0
    var statusNotification:UILocalNotification = UILocalNotification()
    var rendezNotification:UILocalNotification = UILocalNotification()
    var chatNotification:UILocalNotification = UILocalNotification()
    
    var window: UIWindow?
    var timer: Timer?
    internal var mSocket:SocketIOClient = SocketIOClient(socketURL: URL(fileURLWithPath: Constants.CHAT_SERVER_URL))
    var namesDictionary=Dictionary<String,String>()
    
    /*Array that consists of Friend elements.
     Friend element consists of:
     .username
     .showname
     .time (last instance of when you last check notificaitons from them.  Should only he referenced on login since prefs will keep these values updated on the device afterwards, and later updated to a sql table on logout)
     */
    internal var yourFriends = [Friend]()
    internal var yourGroups = [Groups]()
    internal var yourLocs = Dictionary<String, [FromLocation]!>()
    internal var friendMap = Dictionary<String, Friend!>()
    internal var groupResponses = Dictionary<Int, [GResps]!>()
    
    //for now ill just have these to store in order of time recieved for notifications
    internal var status = [Status]()
    internal var rendezstatus = [RendezStatus]()
    internal var chat = [Chat]()
    
    //There is an issue of using just rendezstatus and status for inRange,
    //since those sent/made by a user should be able to be pinged as well
    //........... feels iffy to have so much repeated data but will
    //set arrays for now x_x
    internal var r_status = [Status]()
    internal var r_rendezstatus = [RendezStatus]()
    
    
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
    internal var theNotifHelper = NotificationHelper()
    internal var frame: CGRect?
    //EVENT MANAGER CAUSE SOCKETS BEING CHEEKY
    internal var events = EventManager()
    //END OF VARIABLE DECLARATIONS, NOW ONTO THE APPLICATION LIFECYCLE FUNCTIONS>>>>>>>>>>>>
    //>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<~~^*%^*%*@$&*(^*($@*()$*()&$()&()@$&*()@*()
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~APPLICATION STATE STUFF DEALING WITH ITS LIFECYCLE~~~~~~~~~
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey("AIzaSyCtZkaftILPjennmNLcm5iiIFatU3Lgglg")
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))  // types are UIUserNotificationType members
        
        //NSNOTIFICATION OBSERVER INITILIZER
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.emitRendezNotif(_:)), name: NSNotification.Name(rawValue: emitRendezKey), object: nil)
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //window = UIWindow(frame: UIScreen.main.bounds)
        //frame = UIScreen.main.bounds
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        //the old foolish notification system elegiggle
        //var updateTimer = NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: Selector("getNotification"), userInfo: nil, repeats: true)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.\
        let prefs:UserDefaults = UserDefaults.standard
        
        if let username = prefs.value(forKey: "USERNAME") as? String{
            if(self.theWozMap[username] == nil){
                starting()
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    //~~~~~~~END OF THE APPLICATION LIFECYCLES STATES~~~~~~~~
    
//--------------------------------------------------------------------------------------------------
    
    //^^^^^^^^^^^ NSNOTIFICATION CENTER STUFF THAT ALERTS VIEWCONTROLLERS FROM THE APPDELEGATE
    
    func notifyFriendsActivity(_ friend:Friend){
        let friend1: Friend = Friend(username: friend.username, showname: friend.friendname, timestamp: Date())
        let post:[AnyHashable: Any] = ["friend": friend1]
        NotificationCenter.default.post(name: Notification.Name(rawValue: FriendActivityNotifKey), object: self, userInfo: post)
    }
    
    func notifyRendezChat(_ chatStatus: RendezStatus){
        //chatstatus should be perfectly contructed and passed along with no changed from the parameter
        let post:[AnyHashable: Any] = ["chatstatus": chatStatus]
        NotificationCenter.default.post(name: Notification.Name(rawValue: rendezChatNotifKey), object: self, userInfo: post)
    }
    
    func notifyChatting(_ chatStatus: Chat){
        //chatstatus should be perfectly contructed and passed along with no changed from the parameter
        let post:[AnyHashable: Any] = ["chatstatus": chatStatus]
        NotificationCenter.default.post(name: Notification.Name(rawValue: chattingNotifKey), object: self, userInfo: post)
    }
    
    //^^^^^^^^^^^^^^^^^^END OF THE NOTIFICAIOTN CENTER STUFF
    //--------------------------------------------------------------------------------------------------
    //~*************THE BEGINNING OF ALL THE AMAZING WOZ/SOCKET STUFF :]]]]]]]]]]]]]]]]]]]]]]]]]]]
    //used just to load your friends from a query.  Stores them in an array in app delegate
    func loadFriends(_ friendlist:[Friend]){
        self.yourFriends.append( contentsOf: friendlist)
    }
    
    func getGroup(_ name:String)->Groups{
        for i in 0..<yourGroups.count{
            if(yourGroups[i].groupname == name){
                return yourGroups[i]
            }
        }
        return Groups()
    }
    
    //need to get your friends from somewhere, should be called when you login or mainactivity crashes/restarts
    func queryFriends(_ username:String){
        //depreciated, moved down south
    }
    
    /*
     *   Default call to allocate all the rendez and whatnot, is called whenever the app starts
     *   again but the user is logged in but the phone terminates it or something
     */
    func starting(){
        let prefs:UserDefaults = UserDefaults.standard
        let username = prefs.value(forKey: "USERNAME") as! String
        let initRendezChatD:rendezChatDictionary = onStart(username)
        self.theWozMap[username] = rendezChatDictionary()
        for i in 0..<initRendezChatD.allDeesStatus.count{
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
            self.r_status.append(initRendezChatD.allDeesStatus[i])
        }
        
        for i in 0..<initRendezChatD.allDeesRendez.count{
            //theWozMap is a map of string names to rendezdictionaries so need to make sure that the correct stuff maps to the right names
            let name:String = initRendezChatD.allDeesRendez[i].fromuser//RECIEVER
            let uname:String = initRendezChatD.allDeesRendez[i].username//SENDER
            let showname:String = initRendezChatD.allDeesRendez[i].showname
            
            if( uname != username && name != username){
                //IT MUST BE A GROUP RENDEZ
                //this means that someone in the group sent one to the group, thus fromuser is the
                //groupname and username is the name of the member of the group that sent it
                if( self.theWozMap[name] == nil ){
                    self.theWozMap[name] = rendezChatDictionary()
                }
                
                if(!self.theNotifHelper.isInNotifMap(name))
                {
                    self.theNotifHelper.addToNotfifs(NotificationNode(username: name, showname: showname,g: true))
                }
                
                var timeS:String = initRendezChatD.allDeesRendez[i].timeset
                if(timeS.characters.count < 18){
                    timeS += ":00"
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                var timefor = dateFormatter.date(from: timeS as String)
                if let t = (prefs.value(forKey: name) as? Date ){
                    if printFlag{
                        print("APP DELEGATE new on click prefs time set for " + name)
                    }
                }else{
                    prefs.set(Date(), forKey: name)
                }
                
                if( (prefs.value(forKey: name) as! Date ).compare(timefor!) == ComparisonResult.orderedAscending ){
                    self.theNotifHelper.incrementRendez(name)
                }
                
                self.theNotifHelper.setMaxtime(name, time: timefor!)
                self.theWozMap[name]!.allDeesRendez.append(initRendezChatD.allDeesRendez[i])
                
                //added to notification
                self.rendezstatus.append(initRendezChatD.allDeesRendez[i])
                
            }
            else if( uname == username){
                //setting the variable since using index and whatnot is so long and confusing
                if( self.theWozMap[initRendezChatD.allDeesRendez[i].fromuser] == nil ){
                    self.theWozMap[initRendezChatD.allDeesRendez[i].fromuser] = rendezChatDictionary()
                }
                
                if(!self.theNotifHelper.isInNotifMap(name))
                {
                    var flag = false
                    for g in 0..<initRendezChatD.allDeesGroups.count{
                        if( initRendezChatD.allDeesGroups[g].groupname == name){
                            flag = true
                        }
                    }
                    
                    //is a group
                    if( flag){
                        self.theNotifHelper.addToNotfifs(NotificationNode(username: name, showname: showname, g: true))
                    }else{//not a group
                        self.theNotifHelper.addToNotfifs(NotificationNode(username: name, showname: showname))
                    }
                }
                
                self.theWozMap[initRendezChatD.allDeesRendez[i].fromuser]!.allDeesRendez.append(initRendezChatD.allDeesRendez[i])
            }else{
                if( self.theWozMap[initRendezChatD.allDeesRendez[i].username] == nil ){
                    self.theWozMap[initRendezChatD.allDeesRendez[i].username] = rendezChatDictionary()
                }
                
                if(!self.theNotifHelper.isInNotifMap(uname))
                {
                    self.theNotifHelper.addToNotfifs(NotificationNode(username: uname, showname: showname))
                }
                var timeS:String = initRendezChatD.allDeesRendez[i].timeset
                if(timeS.characters.count < 18){
                    timeS += ":00"
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                var timefor = dateFormatter.date(from: timeS as String)
                
                if let a = (prefs.value(forKey: uname) as? Date ){
                    if( (prefs.value(forKey: uname) as! Date ).compare(timefor!) == ComparisonResult.orderedAscending ){
                        self.theNotifHelper.incrementRendez(uname)
                    }
                }
                
                self.theNotifHelper.setMaxtime(uname, time: timefor!)
                self.theWozMap[initRendezChatD.allDeesRendez[i].username]!.allDeesRendez.append(initRendezChatD.allDeesRendez[i])
                
                //added to notification
                self.rendezstatus.append(initRendezChatD.allDeesRendez[i])
            }
            self.r_rendezstatus.append(initRendezChatD.allDeesRendez[i])
            
        }
        
        //allocate all the chats send and recieved by you
        for i in 0..<initRendezChatD.allDeesChat.count{
            let uname = initRendezChatD.allDeesChat[i].username//SENDER
            let touser = initRendezChatD.allDeesChat[i].toUser//RECIEVER
            let name = initRendezChatD.allDeesChat[i].toUser
            var showname: String!
            //IF THE USERNAME IS YOUR USERNAME, THEN THE TOUSER IS THE SENDER
            if( uname != username && name != username){
                //IT MUST BE A GROUP RENDEZ
                //this means that someone in the group sent one to the group, thus fromuser is the
                //groupname and username is the name of the member of the group that sent it
                if( self.theWozMap[name] == nil ){
                    self.theWozMap[name] = rendezChatDictionary()
                }
                
                if(!self.theNotifHelper.isInNotifMap(name))
                {
                    self.theNotifHelper.addToNotfifs(NotificationNode(username: name, showname: showname,g: true))
                }
                
                let timeS = initRendezChatD.allDeesChat[i].time
                if let a = prefs.value(forKey: name) as? Date{
                    if( (prefs.value(forKey: name) as! Date ).compare(timeS as Date) == ComparisonResult.orderedAscending ){
                        self.theNotifHelper.incrementChat(name)
                    }
                    self.theNotifHelper.setMaxtime(name, time: timeS)
                    self.theWozMap[name]!.allDeesChat.append(initRendezChatD.allDeesChat[i])
                }else{
                    self.theNotifHelper.setMaxtime(name, time: timeS)
                    self.theWozMap[name]!.allDeesChat.append(initRendezChatD.allDeesChat[i])
                }
                
                //for notifications
                self.chat.append(initRendezChatD.allDeesChat[i])
            }//END OF GROUP CHECKING
            else if( initRendezChatD.allDeesChat[i].username == username){
                for x in self.yourFriends{
                    if(x.username == touser){
                        showname = x.friendname
                    }
                }
                if( self.theWozMap[initRendezChatD.allDeesChat[i].toUser] == nil ){
                    self.theWozMap[initRendezChatD.allDeesChat[i].toUser] = rendezChatDictionary()
                }
                
                if(!self.theNotifHelper.isInNotifMap(touser))
                {
                    self.theNotifHelper.addToNotfifs(NotificationNode(username: touser, showname: showname))
                    // print(initRendezChatD.allDeesChat[i])
                }
                let timeS = initRendezChatD.allDeesChat[i].time
                self.theWozMap[initRendezChatD.allDeesChat[i].toUser]!.allDeesChat.append(initRendezChatD.allDeesChat[i])
            }else{//ELSE THE USERNAME IS THE SENDER
                if( self.theWozMap[initRendezChatD.allDeesChat[i].username] == nil ){
                    self.theWozMap[initRendezChatD.allDeesChat[i].username] = rendezChatDictionary()
                }
                for x in self.yourFriends{
                    if(x.username == uname){
                        showname = x.friendname
                    }
                }
                if(!self.theNotifHelper.isInNotifMap(uname))
                {
                    self.theNotifHelper.addToNotfifs(NotificationNode(username: uname, showname: showname))
                    // print(initRendezChatD.allDeesChat[i])
                }
                let timeS = initRendezChatD.allDeesChat[i].time
                if let a = prefs.value(forKey: uname) as? Date{
                    if( (prefs.value(forKey: uname) as! Date ).compare(timeS as Date) == ComparisonResult.orderedAscending ){
                        self.theNotifHelper.incrementChat(uname)
                    }
                    self.theNotifHelper.setMaxtime(uname, time: timeS)
                    self.theWozMap[initRendezChatD.allDeesChat[i].username]!.allDeesChat.append(initRendezChatD.allDeesChat[i])
                }else{
                    self.theNotifHelper.setMaxtime(uname, time: timeS)
                    self.theWozMap[initRendezChatD.allDeesChat[i].username]!.allDeesChat.append(initRendezChatD.allDeesChat[i])
                }
                
                self.chat.append(initRendezChatD.allDeesChat[i])//END OF ELSE FOR CHAT
            }
            
        }
        //print(initRendezChatD.allDeezLoc.count
        for i in 0..<initRendezChatD.allDeezLoc.count{
            if( initRendezChatD.allDeezLoc[i].id != username){
                if( yourLocs[initRendezChatD.allDeezLoc[i].id] == nil){
                    yourLocs[initRendezChatD.allDeezLoc[i].id] = [initRendezChatD.allDeezLoc[i]]
                }else{
                    yourLocs[initRendezChatD.allDeezLoc[i].id]!.append(initRendezChatD.allDeezLoc[i])
                    //print(yourLocs[initRendezChatD.allDeezLoc[i].id]!.count
                }
            }else{
                if( yourLocs[initRendezChatD.allDeezLoc[i].username] == nil){
                    yourLocs[initRendezChatD.allDeezLoc[i].username] = [initRendezChatD.allDeezLoc[i]]
                }else{
                    yourLocs[initRendezChatD.allDeezLoc[i].username]!.append(initRendezChatD.allDeezLoc[i])
                    //print(yourLocs[initRendezChatD.allDeezLoc[i].username]!.count
                }
            }
        }
        
        self.yourGroups.append(contentsOf: initRendezChatD.allDeesGroups)
        //initRendezChatD.allDeesReps
        for i in 0..<initRendezChatD.allDeesReps.count{
            //check each response.  if it exists as a key, append to key->values arr
            //else create the key as well as the array value
            let id = initRendezChatD.allDeesReps[i].id
            let name = initRendezChatD.allDeesReps[i].name
            let resp = initRendezChatD.allDeesReps[i].resp
            
            let sid = String(describing: id)
            let sresp = String(describing: resp)
            
            if printFlag{ print("===allDeesReps at iteration: " + String(i) + " id/name/resp ")
                print( sid + "/" + name! + "/" + sresp )}
            //key exists, append to the value array
            if let check = groupResponses[initRendezChatD.allDeesReps[i].id]{
                
                self.groupResponses[initRendezChatD.allDeesReps[i].id]!.append(GResps(id: id!,name: name!,resp: resp! ))
            }else{
                //groupResponses.
                
                self.groupResponses[initRendezChatD.allDeesReps[i].id] = Array<GResps>()
                self.groupResponses[initRendezChatD.allDeesReps[i].id]!.append(GResps(id: id!,name: name!,resp: resp! ))
            }
        }
    }
    
    //parameter should be the username of the friend that you are checking
    func isTheFriendInTheWoz(_ friendname:String) -> Bool{
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
    
    // on START on STARTon STARTon STARTon STARTon STARTon STARTon STARTon STARTon STARTon START
    //on STARTon STARTon STARTon STARTon STARTon STARTon STARTon STARTon START
    //
    
    func onStart(_ username:String ) -> rendezChatDictionary{
        //initialize the rendez and chat arrays that will be stored in the rendezChatDictionary later
        
        var someRendez = [RendezStatus]()
        var someStatus = [Status]()
        var someChat = [Chat]()
        //the rendezChatDictionary to be returned at the end as well as inserted into theWoz
        let returnDic: rendezChatDictionary = rendezChatDictionary()
        let post:NSString = "username=\(username)" as NSString
        if printFlag{NSLog("PostData: %@",post);}
        let url:URL = URL(string: "http://www.jjkbashlord.com/onLoginAndroid.php")!
        let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
        let postLength:NSString = String( postData.count ) as NSString
        let request:NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postData
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
                if printFlag{NSLog("Response ==> %@", responseData);}
                let jsonData:NSObject = (try! JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers )) as! NSObject
                //this is the forloop of every single rendez and chat in the table
                //They are looped through and sorted and put into their respected containers
                let jsonDataStatus: NSArray = jsonData.value(forKey: "Status") as! NSArray
                let jsonDataRendez: NSArray = jsonData.value(forKey: "RendezStatus") as! NSArray
                let jsonDataChat: NSArray = jsonData.value(forKey: "RendezChat") as! NSArray
                let jsonDataFriends: NSArray = jsonData.value(forKey: "Friends") as! NSArray
                let jsonDataGroups: NSArray = jsonData.value(forKey: "Groups") as! NSArray
                let jsonDataGroupsR: NSArray = jsonData.value(forKey: "GResponses") as! NSArray
                // let jsonLoc: NSArray = jsonData.valueForKey("RendezLoc") as! NSArray
                for index in 0..<jsonDataStatus.count{
                    //if((jsonDataStatus[index].valueForKey("title") as! NSString).length > 0){
                    //gets the variables for a rendezvous
                    let id:Int = (jsonDataStatus[index] as AnyObject).value(forKey: "id") as! Int
                    let username1:NSString = (jsonDataStatus[index] as AnyObject).value(forKey: "username") as! NSString
                    let title1:NSString = (jsonDataStatus[index] as AnyObject).value(forKey: "title") as! NSString
                    let detail1:NSString = (jsonDataStatus[index] as AnyObject).value(forKey: "details") as! NSString
                    let location1:NSString = (jsonDataStatus[index] as AnyObject).value(forKey: "location") as! NSString
                    let timeset:NSString = (jsonDataStatus[index] as AnyObject).value(forKey: "timeset") as! NSString
                    let timefor:NSString = (jsonDataStatus[index] as AnyObject).value(forKey: "timefor") as! NSString
                    let type:Int = (jsonDataStatus[index] as AnyObject).value(forKey: "type") as! Int
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                    var date1 = dateFormatter.date(from: timeset as String)
                    date1 = dateFormatter.date(from: timeset as String)
                    var date2 = dateFormatter.date(from: timefor as String)
                    date2 = dateFormatter.date(from: timefor as String)
                    
                    //if this is true, it is a status by you, meaning get the array of friend responses from your friends
                    if(username1 as String == username){
                        let fromuser:NSArray = (jsonDataStatus[index] as AnyObject).value(forKey: "fromuser") as! NSArray
                        var fu = [fromUser]()
                        for b in 0..<fromuser.count{
                            let fu1:NSObject = fromuser[b] as! NSObject
                            fu.append( fromUser( username: fu1.value(forKey: "friendname") as! String ,response: fu1.value(forKey: "response") as! Int  ))
                        }
                        
                        let visable: Int = (jsonDataStatus[index] as AnyObject).value(forKey: "visable") as! Int
                        let status = Status(id: id, username: username1 as String, title: title1 as String, detail: detail1 as String, location: location1 as String, timeset: timeset as String, timefor: timefor as String, type: type, fromuser:fu , visable: visable)
                        someStatus.append(status)
                    }else{
                        let fromusername:NSString = (jsonDataStatus[index] as AnyObject).value(forKey: "fromuser") as! NSString
                        let response: Int = (jsonDataStatus[index] as AnyObject).value(forKey: "response") as! Int
                        let status = Status(id: id, username: username1 as String, title: title1 as String, detail: detail1 as String, location: location1 as String, timeset: timeset as String, timefor: timefor as String, type: type,visable: 1, fromusername:fromusername as String, response: response)
                        someStatus.append(status)
                    }
                }
                
                for index in 0..<jsonDataRendez.count{
                    let id:Int = (jsonDataRendez[index] as AnyObject).value(forKey: "id") as! Int
                    let username1:NSString = (jsonDataRendez[index] as AnyObject).value(forKey: "username") as! NSString
                    let title1:NSString = (jsonDataRendez[index] as AnyObject).value(forKey: "title") as! NSString
                    let detail1:NSString = (jsonDataRendez[index] as AnyObject).value(forKey: "detail") as! NSString
                    let location1:NSString = (jsonDataRendez[index] as AnyObject).value(forKey: "location") as! NSString
                    let timeset:NSString = (jsonDataRendez[index] as AnyObject).value(forKey: "timeset") as! NSString
                    let timefor:NSString = (jsonDataRendez[index] as AnyObject).value(forKey: "timefor") as! NSString
                    let type:Int = (jsonDataRendez[index] as AnyObject).value(forKey: "type") as! Int
                    let response:Int = (jsonDataRendez[index] as AnyObject).value(forKey: "response") as! Int
                    let fromuser:String = (jsonDataRendez[index] as AnyObject).value(forKey: "fromuser") as! NSString as String
                    var showname1:String = ""
                    if let showname:String = (jsonDataRendez[index] as AnyObject).value(forKey: "showname") as?String!{
                        showname1 = (jsonDataRendez[index] as AnyObject).value(forKey: "showname") as! String!
                    }else{
                        showname1 = fromuser
                    }
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                    var date1 = dateFormatter.date(from: timeset as String)
                    date1 = dateFormatter.date(from: timeset as String)
                    
                    var date2 = dateFormatter.date(from: timefor as String)
                    date2 = dateFormatter.date(from: timefor as String)
                    let status = RendezStatus(id: id, username: username1 as String, title: title1 as String, details: detail1 as String, location: location1 as String, timeset: timeset as String, timefor: timefor as String, type: type, response:response, fromuser:fromuser, showname:showname1)
                    someRendez.append(status)
                }
                
                for index in 0..<jsonDataChat.count{
                    let username1:NSString = (jsonDataChat[index] as AnyObject).value(forKey: "username") as! NSString
                    let detail1:NSString = (jsonDataChat[index] as AnyObject).value(forKey: "chat") as! NSString
                    let status1:NSString = (jsonDataChat[index] as AnyObject).value(forKey: "time") as! NSString
                    let touser:NSString = (jsonDataChat[index] as AnyObject).value(forKey: "friendname") as! NSString
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                    var date = dateFormatter.date(from: status1 as String)
                    date = dateFormatter.date(from: status1 as String)
                    
                    let status = Chat(username: username1 as String, details: detail1 as String, time: date!, toUser: touser as String)
                    //print("ADDED TO CHAT")
                    someChat.append(status)
                }
                
                //var someStatus = [Status]()
                var someGroups = [Groups]()
                var friendMap1 = Dictionary<String, Friend!>()
                for index in 0..<jsonDataFriends.count{
                    let u = (jsonDataFriends[index] as AnyObject).value(forKey: "username") as! NSString
                    let f = (jsonDataFriends[index] as AnyObject).value(forKey: "friendname") as! NSString
                    let t = (jsonDataFriends[index] as AnyObject).value(forKey: "time") as! NSString
                    
                    var lt:String = ""
                    var l:String = ""
                    if let lt1 = (jsonDataFriends[index] as AnyObject).value(forKey: "loctime") as? NSString{
                        lt = (jsonDataFriends[index] as AnyObject).value(forKey: "loctime") as! NSString as String
                    }
                    
                    if let l1 = (jsonDataFriends[index] as AnyObject).value(forKey: "location") as? NSString{
                        l = (jsonDataFriends[index] as AnyObject).value(forKey: "location") as! NSString as String
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                    var date = dateFormatter.date(from: t as String)
                    date = dateFormatter.date(from: t as String)
                    
                    let friend = Friend(username: u as String,showname: f as String,timestamp: date!,loctime: lt as! String,location: l as! String)
                    
                    if printFlag{print( "friendMap1; " + (u as String) )}
                    friendMap1[u as String] = friend
                    self.yourFriends.append(friend)
                }
                
                for index in 0..<jsonDataGroups.count{
                    var somef = [Friend]()
                    let id = (jsonDataGroups[index] as AnyObject).value(forKey: "id") as! Int
                    let status1 = (jsonDataGroups[index] as AnyObject).value(forKey: "groupname") as! NSString
                    let detail1 = (jsonDataGroups[index] as AnyObject).value(forKey: "groupdetail") as! NSString
                    let touser = (jsonDataGroups[index] as AnyObject).value(forKey: "friends") as! NSArray
                    
                    
                    //theres always some sort of error here because something keeps deleteing
                    //apple1 account from the db... am i getting attacked O_o
                    for i in 0..<touser.count{
                        if printFlag{print(touser[i] as! String)}
                        somef.append( friendMap1[touser[i] as! String]!);
                    }
                    
                    someGroups.append(Groups(id: id,groupname: status1 as String, groupdetail: detail1 as String, members: somef))
                }
                for i in 0..<jsonDataGroupsR.count{
                    
                    let id = (jsonDataGroupsR[i] as AnyObject).value(forKey: "id") as! Int
                    let name = (jsonDataGroupsR[i] as AnyObject).value(forKey: "username") as! NSString
                    let resp = (jsonDataGroupsR[i] as AnyObject).value(forKey: "response") as! Int
                    
                    returnDic.allDeesReps.append(GResps(id: id,name: name as String,resp: resp))
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                //this marks the end of the forloop.  someRendez and someChat SHOULD be populated by now...
                returnDic.allDeesRendez = someRendez
                returnDic.allDeesChat = someChat
                returnDic.allDeesStatus = someStatus
                returnDic.allDeesFriendsMap = friendMap1
                returnDic.allDeesGroups = someGroups
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
        return returnDic
    }
    
    func isGroup(_ name:String)->Bool{
        for i in 0..<self.yourGroups.count {
            if(self.yourGroups[i].groupname == name){
                return true
            }
        }
        return false
    }
    
    
    //should be called whenever a rendez is sent to ALL selected recipients
    func emitRendez(_ information: Any?){
        let postparam:Dictionary<String, String?> = information as! Dictionary<String, String?>
        if printFlag{print("is emitrendez called")}
        let id = postparam["id"]
        let friend = postparam["friend"] as! SocketData
        let title = postparam["title"] as! SocketData
        let details = postparam["detail"] as! SocketData
        let location = postparam["location"] as! SocketData
        let timefor = postparam["timefor"] as! SocketData
        let type = postparam["type"] as! SocketData
        let response = 0
        
        self.mSocket.emit( id!!, friend, title, details, location, Date() as! SocketData, timefor, type, response)
    }
    //should be called whenever a chat msg is sent to
    func emitChat(_ reciever:String, detail:String){
        self.mSocket.emit("send chat", reciever, detail, Date() as! SocketData)
    }
    
    /*
     TURNS ON YO LISTENERS
     should be called when login occurs/user is logged in.  This turns on the listeners for new messeges
     Parameters:
     username1: username of the user
     showname1: display of the user
     These should be set to log in the server with identifiers
     */
    func letsGetDatSocketRollin(_ username1:String, showname1:String){
        let username = username1
        
        //default initial connection to the socket server
        self.mSocket.on("connect") {data, ack in
            print("socket connected")
            self.mSocket.emit("joinserver", username, showname1)
            
            //emit listener that is set to emit a rendez once it has been made and sent off
            //THIS IS TRIGGERED IN sendToFriends.swift
            self.events.listenTo(eventName: "emitRendez", action: {
                
                for friend in self.friendarr{
                    print("friend array count")
                    //print(self.friendarr.count
                    let title = friend.value(forKey: "title") as! String
                    let detail = friend.value(forKey: "detail") as! String
                    let location = friend.value(forKey: "location") as! String
                    let timefor = friend.value(forKey: "timefor") as! String
                    let type = friend.value(forKey: "type") as! Int
                    
                    print("title: " + title)
                    print("detail: " + detail)
                    print("locaiton: "  + location)
                    
                    let name = friend.value(forKey: "friend") as! String
                    if(self.isGroup(name)){
                        let members = self.getGroup(name)
                        
                        for m in members.members{
                            self.mSocket.emit("send", name, title, detail, location, "0",timefor, type, 0, m.username)
                        }
                    }
                    else{
                        self.mSocket.emit("send", name, title, detail, location, "0",timefor, type, 0, "")
                    }
                }
                
                for friend in self.grouparr{
                    print("friend array count")
                    //print(self.friendarr.count
                    let title = friend.value(forKey: "title") as! String
                    let detail = friend.value(forKey: "detail") as! String
                    let location = friend.value(forKey: "location") as! String
                    let timefor = friend.value(forKey: "timefor") as! String
                    let type = friend.value(forKey: "type") as! Int
                    
                    print("title: " + title)
                    print("detail: " + detail)
                    print("locaiton: "  + location)
                    
                    let name = friend.value(forKey: "friend") as! String
                    if(self.isGroup(name)){
                        let members = self.getGroup(name)
                        
                        for m in members.members{
                            self.mSocket.emit("send", name, title, detail, location, "0",timefor, type, 0, m.username)
                        }
                    }
                    else{
                        self.mSocket.emit("send", name, title, detail, location, "0",timefor, type, 0, "")
                    }
                }
                self.friendarr.removeAll()
                self.grouparr.removeAll()
            } as! ((Any?)->()))
            
            //same as earlier, but for chats this time
            self.events.listenTo(eventName: "emitChat", action: {
                for cfriend in self.chatarr{
                    let detail = cfriend.value(forKey: "detail") as! String//actual message
                    print("detail: " + detail)
                    let name = cfriend.value(forKey: "friend") as! String//person its goin to
                    if(self.isGroup(name)){
                        //if we are sending a group message, we cant use the group's name, thus we
                        //are required to fetch the members of the group and from there do our emits
                        let members = self.getGroup(name)
                        for m in members.members{
                            self.mSocket.emit("send chat", name, detail, "00", m.username)
                        }
                    }else{
                        self.mSocket.emit("send chat", name, detail, "00", "")
                    }
                }
                self.chatarr.removeAll()
            } as! ((Any?)->()))
        }
        
        //LISTENERS TO RECIEVE EMITS THAT HAVE BEEN SENT BY FRIENDS, HANDLES RENDEZ AND CHATS, NEEDS TO
        //IMPLEMENT RESPONSES AS WELL?
        //When or if the user is logged in, turn on the socket listeners here
        self.mSocket.on("new chat"){data, ack in
            if let cur:NSDictionary = data[0] as? NSDictionary {
                print("----=== NEW CHAT INTERCEPTED ===----")
                self.badgeCount += 1
                UIApplication.shared.applicationIconBadgeNumber = self.badgeCount
                let friendname = cur.object(forKey: "username") as! String
                let message = cur.object(forKey: "detail") as! String
                let pgm = cur.object(forKey: "pgm") as! String
                
                let touser = username
                var theReal = ""
                if(pgm.isEmpty){
                    theReal = friendname
                }else{
                    theReal = pgm
                }
                if(!self.isTheFriendInTheWoz(theReal)){
                    self.makeFriendsWithWoz(username, friendname: theReal)
                }
                
                let temp:rendezChatDictionary = self.theWozMap[theReal]!
                temp.putInChat(Chat(username: friendname, details: message, time: Date(),toUser: touser))
                self.theWozMap[theReal] = temp
                let localNotification: UILocalNotification = UILocalNotification()
                localNotification.alertAction = "YO BOI GOT THAT MUTHASOCKET EMIT WOOOOOOOOOOO"
                localNotification.alertBody = "YA GOT A CHAT CHICO"
                localNotification.fireDate = Date(timeIntervalSinceNow: 5)
                //this should fire off the update in friends activity...
                UIApplication.shared.scheduleLocalNotification(localNotification)
                let friend = Friend(username: theReal as String, showname: showname1 as String, timestamp: Date())
                self.notifyFriendsActivity(friend)
                let rendezChat = Chat(username: theReal, details: message, time: Date(), toUser: username)
                self.notifyChatting(rendezChat)
            }
            else{
                print("something shoulda happened")
            }
        }
        
        self.mSocket.on("new rendez"){data, ack in
            let whatisit = data[0]
            print(whatisit)
            if let cur:NSDictionary = data[0] as? NSDictionary {
                self.badgeCount += 1
                UIApplication.shared.applicationIconBadgeNumber = self.badgeCount
                let id = cur.object(forKey: "id") as! Int
                let friendname = cur.object(forKey: "username") as! NSString
                let showname1 = cur.object(forKey: "showname") as! NSString
                let title1 = cur.object(forKey: "title") as! NSString
                let message = cur.object(forKey: "detail") as! NSString
                let location1 = cur.object(forKey: "location") as! NSString
                let time = cur.object(forKey: "timefor") as! NSString
                let type = cur.object(forKey: "type") as! Int
                let response = cur.object(forKey: "response") as! Int
                let fromuser = username
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                var timefor = dateFormatter.date(from: time as String)
                var timeset = dateFormatter.string(from: Date())
                print(friendname, title1, message, location1)
                
                if(!self.isTheFriendInTheWoz(friendname as String)){
                    self.makeFriendsWithWoz(username, friendname: friendname as String)
                }
                
                let temp:rendezChatDictionary = self.theWozMap[friendname as String]!
                temp.putInRendez(RendezStatus(id: id, username: friendname as String, title: title1 as String, details: message as String, location: location1 as String, timeset: timeset, timefor: time as String, type: type, response: response, fromuser: fromuser as String))
                self.theWozMap[friendname as String] = temp
                let localNotification: UILocalNotification = UILocalNotification()
                localNotification.alertAction = "YO BOI GOT THAT MUTHA SOCKET EMIT WOOOOOOOOOOO"
                localNotification.alertBody = "Woww it works!!"
                localNotification.fireDate = Date(timeIntervalSinceNow: 5)
                //this should fire off the update in friends activity...
                UIApplication.shared.scheduleLocalNotification(localNotification)
                let friend = Friend(username: friendname as String, showname: showname1 as String, timestamp: Date())
                self.notifyFriendsActivity(friend)
                //$$$$$$$ YOU LEFT OFF HERE BECAUSE IT WAS CHATSTATUS BEFORE BUT NEEDS TO BE
                // RENDEZSTATUS NOW WHICH REQUIRES THE ID AND STUFF
                let rendezChat = RendezStatus(id: id, username: friendname as String, title: title1 as String, details: message as String, location: location1 as String, timeset: timeset, timefor: time as String, type: type, response: response, fromuser: fromuser as String)
                self.notifyRendezChat(rendezChat)
            }
            else{
                print("something shoulda happened")
            }
        }
        self.mSocket.connect()
        self.mSocket.emit("joinserver", username, showname1)
    }
    
    //NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---
    //should be called by the app delegate when it gets new emit by the NSNotificationCenter
    //all this should do is change the friend notif time and update the table
    internal func emitRendezNotif(_ notification:Notification){
        print("is the update in rendezChat even called??")
        //get the friend param and set it
        let postparam:Dictionary<String, RendezStatus?> = notification.userInfo as! Dictionary<String, RendezStatus?>
        let friendNotif:RendezStatus = postparam["chatstatus"]!!
    }
    
    internal func logoutSocket(){
        self.mSocket.disconnect()
    }
    
    func makeFriendsWithWoz(_ username:String, friendname:String) -> rendezChatDictionary{
        //initialize the rendez and chat arrays that will be stored in the rendezChatDictionary later
        var someRendez = [RendezStatus]()
        var someStatus = [Status]()
        var someChat = [Chat]()
        //the rendezChatDictionary to be returned at the end as well as inserted into theWoz
        let returnDic: rendezChatDictionary = rendezChatDictionary()
        return returnDic
    }

}
