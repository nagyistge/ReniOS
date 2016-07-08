//
//  rendezChat.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 9/1/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

class rendezChat: UIViewController, UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate{
var locationCoords:String!
    var manager: OneShotLocationManager = OneShotLocationManager()
    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatButton: UIButton!
    let locationManager = CLLocationManager()
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
     var vm: showRMap!
    
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
    userLabel.text = "Me"

}
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        print(friendname)
        self.someInts.removeAll()
     //   let statuslist = delegate.theWozMap[friendname]!
     //   let rendez = statuslist.allDeesRendez
        self.someInts.appendContentsOf(delegate.theWozMap[friendname]!.allDeesRendez! )
        self.tableView.reloadData()
        NSLog("\n THE CHAT HAS RETRIEVED THE STATIC LIST FROM THE WOZ")
        
        locationManager.requestWhenInUseAuthorization()
        manager = OneShotLocationManager()
        manager.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                print(location)
                let lat: Double = loc.coordinate.latitude
                let long: Double = loc.coordinate.longitude
                let coords: String = String(format:"%f", lat)+" : "+String(format:"%f", long)
                self.locationCoords = coords
            } else if let err = error {
                print(err.localizedDescription)
            }
            // self.manager = nil
        }

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
        let postparam = notification.userInfo as! Dictionary<String, AnyObject>
        //let postparam:Dictionary<String, RendezStatus!> = notification.userInfo as! Dictionary<String, RendezStatus!>
        let friendNotif:RendezStatus = postparam["chatstatus"]! as! RendezStatus
        
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
     //   let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = self.storyboard?.instantiateViewControllerWithIdentifier("showRRendez") as! showRRendez
        vc.programVar1 = statusToPass
        vc.username = username
        vc.friendname = friendname
        vc.showuser = showuser
        vc.showfriend = showfriend
        print (statusToPass.username + "  " + username)
        if(statusToPass.username == username){
            vc.isStatusFromYou = true
        }else{
            vc.isStatusFromYou = false
        }
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func onSendLocClicked(sender: UIButton) {
        //send current location to the relational in the database
        
        let post:NSString = "friendname=\(friendname)&username=\(username)&location=\(self.locationCoords)"
        NSLog("PostData: %@",post);
        
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/onLocationUpdate.php")!
        
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
            let res = response as! NSHTTPURLResponse
            
            NSLog("Response code: %ld", res.statusCode);
            
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                
                NSLog("Response ==> %@", responseData);
                
                //   var error: NSError?
                
               
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
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // 2
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(locations.first)
            print(location)
            print(location.coordinate.latitude)
            
            let lat: Double = location.coordinate.latitude
            let long: Double = location.coordinate.longitude
            let coords: String = String(format:"%f", lat)+" : "+String(format:"%f", long)
            self.locationCoords = coords
            
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    @IBAction func onMapLoc(sender: UIButton) {
        
        let post:NSString = "friendname=\(friendname)&username=\(username)"
        NSLog("PostData: %@",post);
        
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/fetchFriendLoc.php")!
        
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
            let res = response as! NSHTTPURLResponse
            
            NSLog("Response code: %ld", res.statusCode);
            
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                let jsonData:NSObject = (try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers )) as! NSObject
                NSLog("Response ==> %@", responseData);
                
                //   var error: NSError?
                vm = self.storyboard?.instantiateViewControllerWithIdentifier("showRMap") as! showRMap
                let coords = jsonData.valueForKey("location") as? String
                let title = friendname
                let detail = jsonData.valueForKey("loctime") as? String
                vm.name = friendname
                vm.coords = coords
                vm.title1 = title
                vm.detail = detail
                
                
                self.presentViewController(vm, animated: true, completion: nil)

                
                
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
