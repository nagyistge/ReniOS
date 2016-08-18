//
//  onSendRendezList.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/14/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit

extension UIColor {
    class func randomColor() -> UIColor {
        
        let hue = CGFloat(arc4random() % 100) / 100
        let saturation = CGFloat(arc4random() % 100) / 100
        let brightness = CGFloat(arc4random() % 100) / 100
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

func generateRandomData() -> [[UIColor]] {
    let numberOfRows = 20
    let numberOfItemsPerRow = 15
    
    return (0..<numberOfRows).map { _ in
        return (0..<numberOfItemsPerRow).map { _ in UIColor.randomColor() }
    }
}

class onSendRendezList: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var collection1: UICollectionView!
    @IBOutlet weak var collection2: UICollectionView!
    
    let model: [[UIColor]] = generateRandomData()
    
    var rendez = [Status]()
    var friends = [Friend]()
    var groups = [Groups]()
    
    var peeps = [AnyObject]()
    
    var username:String!
    
    var currStatus: Status!
    var currFriend:Friend!
    
    @IBOutlet weak var titlee: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var location: UILabel!
    
     var path: NSIndexPath!
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.collection1.registerClass(onSendCell.self, forCellWithReuseIdentifier: "cell4")
        //self.collection2.registerClass(onSendCell2.self, forCellWithReuseIdentifier: "cell5")
        let longpress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        self.collection2.addGestureRecognizer(longpress)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        username = prefs.valueForKey("USERNAME") as! String
let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        print(username)
        
        //self.rendez.appendContentsOf(delegate.theWozMap[username]!.allDeesStatus)
        //self.friends += delegate.yourFriends
        self.collection1.reloadData()
        self.collection2.reloadData()
        // Do any additional setup after loading the view.
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //self.friends += (delegate.yourFriends)
        
        //self.peeps.appendContentsOf(self.friends)
        //self.peeps.appendContentsOf(self.groups)
        //self.peeps += self.friends
        for x in self.friends{
            self.peeps.append(x)
        }
        for x in self.groups{
            self.peeps.append(x)
        }
        
        self.collection1.reloadData()
        self.collection2.reloadData()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.locationInView(self.collection2)
        
        //let indexPath = collection2.indexPathForRowAtPoint(locationInView)
        let indexPath = collection2.indexPathForItemAtPoint(locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            static var initialIndexPath : NSIndexPath? = nil
        }
        
        var cell: UICollectionViewCell!
        var offset:CGFloat = 425
        switch state {
        case UIGestureRecognizerState.Began:
            print("is it here?")
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                //let cell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
                path = indexPath!
                cell = self.collection2.cellForItemAtIndexPath(indexPath!) as UICollectionViewCell!
                My.cellSnapshot  = snapshotOfCell(cell)
                
                var center = cell.center
                print(locationInView.x)
                print(locationInView.y)

                My.cellSnapshot!.center = locationInView
                My.cellSnapshot!.center.y += offset
                //center
                My.cellSnapshot!.alpha = 0.0
                
                self.view.addSubview(My.cellSnapshot!)
                //tableView.addSubview(My.cellSnapshot!)
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    center.y = locationInView.y
                    center.x = locationInView.x
                    
                    center.y += offset
                    
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell.alpha = 0.1
                    }, completion: { (finished) -> Void in
                        if finished {
                            My.cellIsAnimating = false
                            if My.cellNeedToShow {
                                My.cellNeedToShow = false
                                UIView.animateWithDuration(0.25, animations: { () -> Void in
                                    cell.alpha = 1
                                })
                            } else {
                                cell.hidden = true
                            }
                        }
                })
            }
            
        case UIGestureRecognizerState.Changed:
            if My.cellSnapshot != nil {
                
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                center.x = locationInView.x
                center.y += offset
                My.cellSnapshot!.center = center
                
            }
        case UIGestureRecognizerState.Ended:
            print("end?")
             var center = My.cellSnapshot!.center
            center.y -= (offset-100)
            if let indexPath1 = collection1.indexPathForItemAtPoint(center){
                let fcell = self.collection1.cellForItemAtIndexPath(indexPath1) as! onSendCell!
                print( fcell.title.text )
                //only really triggers when released upon a friend cell
                
                if let a = self.peeps[indexPath1.row] as? Friend{
                     sendOnRelease(self.rendez[path!.row], friend: a)
                }else{//else it is a group cell
                    let a = self.peeps[indexPath1.row] as? Groups
                    sendOnRelease(self.rendez[path!.row], group: a!)
                }

                
                //sendOnRelease(self.rendez[path!.row], friend: self.friends[indexPath1.row])
            }
            
            if Path.initialIndexPath != nil {
                //let cell = tableView.cellForRowAtIndexPath(Path.initialIndexPath!) as UITableViewCell!
                cell = self.collection2.cellForItemAtIndexPath(path!) as UICollectionViewCell!
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell.hidden = false
                    cell.alpha = 0.0
                }
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = cell.center
                    My.cellSnapshot!.transform = CGAffineTransformIdentity
                    My.cellSnapshot!.alpha = 0.0
                    cell.alpha = 1.0
                    
                    }, completion: { (finished) -> Void in
                        if finished {
                            Path.initialIndexPath = nil
                            My.cellSnapshot!.removeFromSuperview()
                            My.cellSnapshot = nil
                        }
                })
            }
        default:
            print("default")
            
            if Path.initialIndexPath != nil {
                //let cell = tableView.cellForRowAtIndexPath(Path.initialIndexPath!) as UITableViewCell!
                cell = self.collection2.cellForItemAtIndexPath(path!) as UICollectionViewCell!
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell.hidden = false
                    cell.alpha = 0.0
                }
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = cell.center
                    My.cellSnapshot!.transform = CGAffineTransformIdentity
                    My.cellSnapshot!.alpha = 0.0
                    cell.alpha = 1.0
                    
                    }, completion: { (finished) -> Void in
                        if finished {
                            Path.initialIndexPath = nil
                            My.cellSnapshot!.removeFromSuperview()
                            My.cellSnapshot = nil
                        }
                })
            }
            
        }
    }
    
    func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            if(collectionView == collection1){
                return self.peeps.count
            }else{
                return self.rendez.count
            }
            //return model[collectionView.tag].count
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            if(collectionView == self.collection1){
                let cell = self.collection1.dequeueReusableCellWithReuseIdentifier("cell4", forIndexPath: indexPath) as! onSendCell
                
                //it is a friend cell so need to set up the cell as such
                if let a:Friend = self.peeps[indexPath.row] as? Friend{
                     cell.title.text? = a.username
                }else{//else it is a group cell
                    let a = self.peeps[indexPath.row] as? Groups
                    cell.title.text? = (a?.groupname)!
                }
                //cell.backgroundColor = UIColor.greenColor()
                //cell.title.text? = self.friends[indexPath.row].username
                return cell
            }else{
                let cell = self.collection2.dequeueReusableCellWithReuseIdentifier("cell5", forIndexPath: indexPath) as! onSendCell2

                //cell.backgroundColor = UIColor.redColor()
                
                print(self.rendez[indexPath.row].title)
                
                cell.title.text = self.rendez[indexPath.row].title
                cell.makeItCircle()
                return cell

            }
    }
    
    
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            if(collectionView == self.collection2){
                self.titlee.text = self.rendez[indexPath.row].title
                self.detail.text = self.rendez[indexPath.row].detail
                self.location.text = self.rendez[indexPath.row].location
            }
    }
    
    
    @IBAction func onBackPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func sendOnRelease(status:Status, friend:Friend){
        var arr = [AnyObject]()
        var friendarr = [AnyObject]()
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let showname:String = prefs.valueForKey("SHOWNAME") as! String
        
        let userObject = ["username": self.username, "showname": showname]
        arr.append(userObject)
        let statusObject = ["title": status.title, "detail": status.detail, "location": status.location, "type": status.type, "timefor": status.timefor, "response": 0]
        arr.append(statusObject)

        if let a:Friend = friend{
                let friendObj = ["username": friend.username, "showname": friend.friendname]
                friendarr.append(friendObj)
                let emitobj = [ "friend": friend.username, "title": status.title, "detail": status.detail, "location": status.location, "timefor": status.timefor, "type": status.type, "response": 0]
                delegate.friendarr.append(emitobj)
            }
        
        /*
         if let a:Groups = group{
                let groupObj = ["username": group.groupname, "showname": group.groupdetail]
                friendarr.append(groupObj)
                let emitobj = [ "friend": friend.username, "title": status.title, "detail": status.detail, "location": status.location, "timefor": status.timefor, "type": status.type, "response": 0]
                delegate.grouparr.append(emitobj)
        }*/
        
        delegate.events.trigger("emitRendez")
        let friendarray = ["array": friendarr]
        arr.append(friendarray)
        let finalNSArray:NSArray = arr
        let finalarr:NSDictionary = ["json": finalNSArray]
        NSLog("PostData: %@",finalarr);
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/sentRSwift.php")!
        let da:NSData = try! NSJSONSerialization.dataWithJSONObject(finalarr, options: [])
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
        }
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            NSLog("Response code: %ld", res.statusCode);
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                NSLog("Response ==> %@", responseData);
                let jsonData:NSObject = (try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers )) as! NSObject
                NSLog("sent!!!!!!!")
                let dateFormatter = NSDateFormatter()
                dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let date = dateFormatter.stringFromDate(NSDate())
                
                
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

    func sendOnRelease(status:Status, group:Groups){
        var arr = [AnyObject]()
        var friendarr = [AnyObject]()
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let showname:String = prefs.valueForKey("SHOWNAME") as! String
        
        let userObject = ["username": self.username, "showname": showname]
        arr.append(userObject)
        let statusObject = ["title": status.title, "detail": status.detail, "location": status.location, "type": status.type, "timefor": status.timefor, "response": 0]
        arr.append(statusObject)
        
        /*
        if let a:Friend = friend{
            let friendObj = ["username": friend.username, "showname": friend.friendname]
            friendarr.append(friendObj)
            let emitobj = [ "friend": friend.username, "title": status.title, "detail": status.detail, "location": status.location, "timefor": status.timefor, "type": status.type, "response": 0]
            delegate.friendarr.append(emitobj)
        }*/
        
        
        if let a:Groups = group{
        let groupObj = ["username": group.groupname, "showname": group.groupdetail]
        friendarr.append(groupObj)
        let emitobj = [ "friend": a.groupname, "title": status.title, "detail": status.detail, "location": status.location, "timefor": status.timefor, "type": status.type, "response": 0]
        delegate.grouparr.append(emitobj)
        }
        
        delegate.events.trigger("emitRendez")
        let friendarray = ["array": friendarr]
        arr.append(friendarray)
        let finalNSArray:NSArray = arr
        let finalarr:NSDictionary = ["json": finalNSArray]
        NSLog("PostData: %@",finalarr);
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/sentRSwift.php")!
        let da:NSData = try! NSJSONSerialization.dataWithJSONObject(finalarr, options: [])
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
        }
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            NSLog("Response code: %ld", res.statusCode);
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                NSLog("Response ==> %@", responseData);
                let jsonData:NSObject = (try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers )) as! NSObject
                NSLog("sent!!!!!!!")
                let dateFormatter = NSDateFormatter()
                dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let date = dateFormatter.stringFromDate(NSDate())
                
                
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



