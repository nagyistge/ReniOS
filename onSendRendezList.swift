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
    
     var path: IndexPath!
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.collection1.registerClass(onSendCell.self, forCellWithReuseIdentifier: "cell4")
        //self.collection2.registerClass(onSendCell2.self, forCellWithReuseIdentifier: "cell5")
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(onSendRendezList.longPressGestureRecognized(_:)))
        self.collection2.addGestureRecognizer(longpress)
        
        let prefs:UserDefaults = UserDefaults.standard
        username = prefs.value(forKey: "USERNAME") as! String
let delegate = UIApplication.shared.delegate as! AppDelegate
        
        
        print(username)
        
        //self.rendez.appendContentsOf(delegate.theWozMap[username]!.allDeesStatus)
        //self.friends += delegate.yourFriends
        self.collection1.reloadData()
        self.collection2.reloadData()
        // Do any additional setup after loading the view.
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let delegate = UIApplication.shared.delegate as! AppDelegate
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
    
    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: self.collection2)
        
        //let indexPath = collection2.indexPathForRowAtPoint(locationInView)
        let indexPath = collection2.indexPathForItem(at: locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            static var initialIndexPath : IndexPath? = nil
        }
        
        var cell: UICollectionViewCell!
        let offset:CGFloat = 425
        switch state {
        case UIGestureRecognizerState.began:
            print("is it here?")
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                //let cell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
                path = indexPath!
                cell = self.collection2.cellForItem(at: indexPath!) as UICollectionViewCell!
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
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center.y = locationInView.y
                    center.x = locationInView.x
                    
                    center.y += offset
                    
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell.alpha = 0.1
                    }, completion: { (finished) -> Void in
                        if finished {
                            My.cellIsAnimating = false
                            if My.cellNeedToShow {
                                My.cellNeedToShow = false
                                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                                    cell.alpha = 1
                                })
                            } else {
                                cell.isHidden = true
                            }
                        }
                })
            }
            
        case UIGestureRecognizerState.changed:
            if My.cellSnapshot != nil {
                
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                center.x = locationInView.x
                center.y += offset
                My.cellSnapshot!.center = center
                
            }
        case UIGestureRecognizerState.ended:
            print("end?")
             var center = My.cellSnapshot!.center
            center.y -= (offset-100)
            if let indexPath1 = collection1.indexPathForItem(at: center){
                let fcell = self.collection1.cellForItem(at: indexPath1) as! onSendCell!
                print( fcell?.title.text )
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
                cell = self.collection2.cellForItem(at: path!) as UICollectionViewCell!
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell.isHidden = false
                    cell.alpha = 0.0
                }
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = cell.center
                    My.cellSnapshot!.transform = CGAffineTransform.identity
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
                cell = self.collection2.cellForItem(at: path!) as UICollectionViewCell!
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell.isHidden = false
                    cell.alpha = 0.0
                }
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = cell.center
                    My.cellSnapshot!.transform = CGAffineTransform.identity
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
    
    func snapshotOfCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    func collectionView(_ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            if(collectionView == collection1){
                return self.peeps.count
            }else{
                return self.rendez.count
            }
            //return model[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if(collectionView == self.collection1){
                let cell = self.collection1.dequeueReusableCell(withReuseIdentifier: "cell4", for: indexPath) as! onSendCell
                
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
                let cell = self.collection2.dequeueReusableCell(withReuseIdentifier: "cell5", for: indexPath) as! onSendCell2

                //cell.backgroundColor = UIColor.redColor()
                
                print(self.rendez[indexPath.row].title)
                
                cell.title.text = self.rendez[indexPath.row].title
                cell.makeItCircle()
                return cell

            }
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
            if(collectionView == self.collection2){
                self.titlee.text = self.rendez[indexPath.row].title
                self.detail.text = self.rendez[indexPath.row].detail
                self.location.text = self.rendez[indexPath.row].location
            }
    }
    
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func sendOnRelease(_ status:Status, friend:Friend){
        var arr = [AnyObject]()
        var friendarr = [AnyObject]()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let prefs:UserDefaults = UserDefaults.standard
        let showname:String = prefs.value(forKey: "SHOWNAME") as! String
        
        let userObject = ["username": self.username, "showname": showname]
        arr.append(userObject as AnyObject)
        let statusObject = ["title": status.title, "detail": status.detail, "location": status.location, "type": status.type, "timefor": status.timefor, "response": 0] as [String : Any]
        arr.append(statusObject as AnyObject)

        if let a:Friend = friend{
                let friendObj = ["username": friend.username, "showname": friend.friendname]
                friendarr.append(friendObj as AnyObject)
                let emitobj = [ "friend": friend.username, "title": status.title, "detail": status.detail, "location": status.location, "timefor": status.timefor, "type": status.type, "response": 0] as [String : Any]
                delegate.friendarr.append(emitobj as AnyObject)
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
        arr.append(friendarray as AnyObject)
        let finalNSArray:NSArray = arr as NSArray
        let finalarr:NSDictionary = ["json": finalNSArray]
        NSLog("PostData: %@",finalarr);
        let url:URL = URL(string: "http://www.jjkbashlord.com/sentRSwift.php")!
        let da:Data = try! JSONSerialization.data(withJSONObject: finalarr, options: [])
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
        }
        if ( urlData != nil ) {
            let res = response as! HTTPURLResponse!;
            NSLog("Response code: %ld", res?.statusCode);
            if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                NSLog("Response ==> %@", responseData);
                let jsonData:NSObject = (try! JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers )) as! NSObject
                NSLog("sent!!!!!!!")
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let date = dateFormatter.string(from: Date())
                
                
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

    func sendOnRelease(_ status:Status, group:Groups){
        var arr = [AnyObject]()
        var friendarr = [AnyObject]()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let prefs:UserDefaults = UserDefaults.standard
        let showname:String = prefs.value(forKey: "SHOWNAME") as! String
        
        let userObject = ["username": self.username, "showname": showname]
        arr.append(userObject as AnyObject)
        let statusObject = ["title": status.title, "detail": status.detail, "location": status.location, "type": status.type, "timefor": status.timefor, "response": 0] as [String : Any]
        arr.append(statusObject as AnyObject)
        
        /*
        if let a:Friend = friend{
            let friendObj = ["username": friend.username, "showname": friend.friendname]
            friendarr.append(friendObj)
            let emitobj = [ "friend": friend.username, "title": status.title, "detail": status.detail, "location": status.location, "timefor": status.timefor, "type": status.type, "response": 0]
            delegate.friendarr.append(emitobj)
        }*/
        
        
        if let a:Groups = group{
        let groupObj = ["username": group.groupname, "showname": group.groupdetail]
        friendarr.append(groupObj as AnyObject)
        let emitobj = [ "friend": a.groupname, "title": status.title, "detail": status.detail, "location": status.location, "timefor": status.timefor, "type": status.type, "response": 0] as [String : Any]
        delegate.grouparr.append(emitobj as AnyObject)
        }
        
        delegate.events.trigger("emitRendez")
        let friendarray = ["array": friendarr]
        arr.append(friendarray as AnyObject)
        let finalNSArray:NSArray = arr as NSArray
        let finalarr:NSDictionary = ["json": finalNSArray]
        NSLog("PostData: %@",finalarr);
        let url:URL = URL(string: "http://www.jjkbashlord.com/sentRSwift.php")!
        let da:Data = try! JSONSerialization.data(withJSONObject: finalarr, options: [])
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
        }
        if ( urlData != nil ) {
            let res = response as! HTTPURLResponse!;
            NSLog("Response code: %ld", res?.statusCode);
            if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                NSLog("Response ==> %@", responseData);
                let jsonData:NSObject = (try! JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers )) as! NSObject
                NSLog("sent!!!!!!!")
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let date = dateFormatter.string(from: Date())
                
                
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



