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
    
    @IBOutlet weak var deets: UIButton!
    
    let locationManager = CLLocationManager()
    var username: String!
    var friendname: String!
    var someInts = [RendezStatus]()
    var someChats = [Chat]()
    var showuser: String!
    var showfriend: String!
    var rendezNotifTimeFlag: Date!
    
    var statusToPass: RendezStatus!
    var vc: showRRendez!
    var toViewController:chattingR!
    var temp:rendezChatDictionary!
    
    var groupdeet:GroupDeets!
     var vm: showRMap!
    
    var ffriend:Friend!
    var ggroup:Groups!
    
    var flag:Int = -1//IF THIS IS -1 IT IS NORMAL, ELSE IT IS A GROUPCHAT
    
    ///operator that handles the custom side effect when presenting the chat view
    var transitionOperator = TransitionOperator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
        
        //NSNOTIFICATION OBSERVER INITILIZER
        NotificationCenter.default.addObserver(self, selector: #selector(rendezChat.updateRendezChatNotif(_:)), name: NSNotification.Name(rawValue: rendezChatNotifKey), object: nil)
        print("This notifcation observer should be set now for this friend... it should be called every time")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    //set the user display names in the respective labels
    if(flag == -1){
        friendLabel.text = showfriend
    }else{
        friendLabel.text = friendname
    }
    
    userLabel.text = "Me"

}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        print(friendname)
        self.someInts.removeAll()
     //   let statuslist = delegate.theWozMap[friendname]!
     //   let rendez = statuslist.allDeesRendez
        self.someInts.append(contentsOf: delegate.theWozMap[friendname]!.allDeesRendez! )
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
    @IBAction func onBackTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onChatTapped(_ sender: UIButton) {
            //self.performSegueWithIdentifier("presentNav", sender: self)
        
        toViewController = self.storyboard?.instantiateViewController(withIdentifier: "chattingR") as! chattingR
       // toViewController = segue.destinationViewController as! chattingR
        toViewController.username = username
        toViewController.friendname = friendname
        toViewController.showuser = showuser
        toViewController.showfriend = showfriend
        self.modalPresentationStyle = UIModalPresentationStyle.custom
        toViewController.transitioningDelegate = self.transitionOperator
        toViewController.flag = flag
        self.present(toViewController, animated: true, completion: nil)
    }
    
    //NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---NSNotificationStuff---

    //should be called by the app delegate when it gets new emit by the NSNotificationCenter
    //all this should do is change the friend notif time and update the table
    internal func updateRendezChatNotif(_ notification:Notification){
        print("is the update in rendezChat even called??")
        
        //get the friend param and set it
        let postparam = notification.userInfo as! Dictionary<String, AnyObject>
        //let postparam:Dictionary<String, RendezStatus!> = notification.userInfo as! Dictionary<String, RendezStatus!>
        let friendNotif:RendezStatus = postparam["chatstatus"]! as! RendezStatus
        
        if(friendNotif.username == friendname){
            self.someInts.insert(friendNotif, at: 0)
            self.tableView.reloadData()
        }
    }

    //TABLEVIEW INITIALIZATION STUFF, HANDLES MAKING THE LIST AND ONCLICKS ON THE LIST
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return self.someInts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 3
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = DateFormatter.Style.full
        //let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        let datee = self.someInts[indexPath.row].timeset as NSString as String
        let showdate = datee.replacingOccurrences(of: "-", with: "/")
        //SETS THEE RENDEZ THAT IS FROM YOU
        if(self.someInts[indexPath.row].username == username){
            let cell1 = self.tableView.dequeueReusableCell(withIdentifier: "rightcell", for: indexPath) as! RightView
            cell1.title.text = self.someInts[indexPath.row].title as NSString as String
            let date = self.someInts[indexPath.row].timeset as NSString as String
            let showdate = date.replacingOccurrences(of: "-", with: "/")
             cell1.detail.text = showdate
            return cell1
        }
        else{//ELSE THE RENDEZ IS FROM THE FRIEND
            if(flag == -1){
                
                let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
                cell.textLabel?.textAlignment = .left
                cell.detailTextLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.blue
                cell.detailTextLabel?.textColor = UIColor.blue
                cell.textLabel!.text = self.someInts[indexPath.row].title as NSString as String
                
                cell.detailTextLabel?.text = showdate
            //check with the LAST TIME THAT FRIEND WAS CHECKED TIME with the time of the redenz from the friend to see if it is new and should be highlighted or not
            
                let dateFormatter = DateFormatter()
                if self.someInts[indexPath.row].timeset.characters.count == 19 {
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                }else{
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                }
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                var date = dateFormatter.date(from: self.someInts[indexPath.row].timeset)
                date = dateFormatter.date(from: self.someInts[indexPath.row].timeset)
                print(self.someInts[indexPath.row].timeset)
                print(date)
                let notifFlag = rendezNotifTimeFlag.compare(date!)
            
                if notifFlag == .orderedAscending{
                    cell.backgroundColor = UIColor.yellow
                }
                    return cell
            }else{
                let cell2 = self.tableView.dequeueReusableCell(withIdentifier: "lefter", for: indexPath) as! LeftRendez
                
                cell2.from.text = self.someInts[indexPath.row].title as NSString as String
                cell2.fromtime.text = showdate
                cell2.fromfrom.text = "from " + (self.someInts[indexPath.row].username as NSString as String)
                //cell2.fromfrom.text += self.someInts[indexPath.row].username as NSString as String
                return cell2
            }
         
        }
        //return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let currentCell = self.someInts[indexPath.row] as RendezStatus
        statusToPass = currentCell
     //   let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = self.storyboard?.instantiateViewController(withIdentifier: "showRRendez") as! showRRendez
        vc.programVar1 = statusToPass
        vc.username = username
        vc.friendname = friendname
        vc.showuser = showuser
        vc.showfriend = showfriend
        if(flag != -1){
            vc.flag = 1
        }
        vc.id = currentCell.id
        print (statusToPass.username + "  " + username)
        if(statusToPass.username == username){
            vc.isStatusFromYou = true
        }else{
            vc.isStatusFromYou = false
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func onSendLocClicked(_ sender: UIButton) {
        //send current location to the relational in the database
        if(self.locationCoords == nil){
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Location not found!"
            alertView.message = "Connection is faulty. Try another area."
            alertView.delegate = self
            alertView.addButton(withTitle: "OK")
            alertView.show()
            
        }else{
        let post:NSString = "friendname=\(friendname)&username=\(username)&location=\(self.locationCoords)" as NSString
        NSLog("PostData: %@",post);
        
        let url:URL = URL(string: "http://www.jjkbashlord.com/onLocationUpdate.php")!
        
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
            let res = response as! HTTPURLResponse
            
            NSLog("Response code: %ld", res.statusCode);
            
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                
                NSLog("Response ==> %@", responseData);
                
                //   var error: NSError?
                
               
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 2
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
    
    @IBAction func onMapLoc(_ sender: UIButton) {
        
        let post:NSString = "friendname=\(friendname)&username=\(username)" as NSString
        NSLog("PostData: %@",post);
        
        let url:URL = URL(string: "http://www.jjkbashlord.com/fetchFriendLoc.php")!
        
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
            let res = response as! HTTPURLResponse
            
            NSLog("Response code: %ld", res.statusCode);
            
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                let jsonData:NSObject = (try! JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers )) as! NSObject
                NSLog("Response ==> %@", responseData);
                
                //   var error: NSError?
                vm = self.storyboard?.instantiateViewController(withIdentifier: "showRMap") as! showRMap
                if(flag == -1){
                    if let coords1 = jsonData.value(forKey: "location") as? String{
                        let coords = jsonData.value(forKey: "location") as? String
                        let title = friendname
                        let detail = jsonData.value(forKey: "loctime") as? String
                        vm.name = friendname
                        vm.coords = coords
                        vm.title1 = title
                        vm.detail = detail
                        vm.gflag = flag
                
                        self.present(vm, animated: true, completion: nil)
                    }
                }else{
                    let coords = jsonData.value(forKey: "location") as? String
                    let title = friendname
                    let detail = jsonData.value(forKey: "loctime") as? String
                    vm.name = friendname
                    vm.coords = coords
                    vm.title1 = title
                    vm.detail = detail
                    vm.gflag = flag
                    self.present(vm, animated: true, completion: nil)
                }

                
                
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
    
    
    @IBAction func onDeetsPressed(_ sender: UIButton) {
        
        groupdeet = self.storyboard?.instantiateViewController(withIdentifier: "groupdeet") as! GroupDeets
        
        groupdeet.name = friendname
        groupdeet.deet = showfriend
        groupdeet.someInts = ggroup.members
        self.present(groupdeet, animated: true, completion: nil)
        
        
    }
    
    
    
    
}
