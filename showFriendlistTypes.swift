//
//  showFriendlistType.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/31/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

class showFriendlistTypes: UIViewController,UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var items: [String] = ["We", "Heart", "Swift"]
    var someInts = [Friend]()
    var statusToPass: Friend!
    var newCar: String = ""
    var flag: Int!
    
    

    @IBOutlet weak var txtUsername: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //self.imageView.image = UIImage(named: self.imageFile)
        // self.titleLabel.text = self.titleText
        //cars = ["BMW","Audi","Volkswagen"]
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //tableView.delegate = self
        //tableView.dataSource = self
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if(isLoggedIn != 1){
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        //self.txtUsername.text = prefs.valueForKey("USERNAME") as? String
        
        
        let username:String = prefs.valueForKey("USERNAME") as! String
        
        
        let post:NSString = "username=\(username)"
        
        NSLog("PostData: %@",post);
        
        var php:String = ""
        
        if(flag == 0){
            php = "showFriendlist.php"
        }
        if(flag == 1){
            php = "addFriendlist.php"
        }
        if(flag == 2){
            php = "addedMeList.php"
        }
        if(flag == 3){
            php = "inviteFriendlist.php"
        }
        
        
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

                    let status1:Int = jsonData[index].valueForKey("status") as! Int
                    
                    print(title1)
                    let status = Friend(username: username1 as String, friendname: title1 as String, phone: "", email: "", status: status1)
                    
                    someInts.append(status)
                    print("Friend Entity: " + status.friendname)
                    
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
        
        
        
        print(self.someInts.count)
        
        
        
        
        
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
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
        
        cell.textLabel?.text = self.someInts[indexPath.row].friendname
        print("TableView: " + self.someInts[indexPath.row].friendname)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        var addFlag: Int = 0
        
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username:String = prefs.valueForKey("USERNAME") as! String
        
        let friendname1: Friend = self.someInts[indexPath.row] as Friend
        
        let post:NSString = "user=\(username)&friend=\(friendname1.username)"
        
        NSLog("PostData: %@",post);
        
        var php:String = ""
        
        if(flag == 0){
           //php = "http://www.jjkbashlord.com/fetchRendevousChat.php"
        }
        if(flag == 1){
            php = "http://www.jjkbashlord.com/addingFriend.php"
            addFlag = 1
            
            let date = NSDate()
           // var dateFormatter = NSDateFormatter()
           // dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           // dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
            
          //  let addDate = dateFormatter.dateFromString(date)
            
            
            prefs.setObject(date, forKey: friendname1.username)
        }
        if(flag == 2){
            php = "http://www.jjkbashlord.com/addingBack.php"
            addFlag = 1

            let date = NSDate()
          //  let dateFormatter = NSDateFormatter()
           // dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           // dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
            
            //let addDate = dateFormatter.dateFromString(date)
            
            
            prefs.setObject(date, forKey: friendname1.username)
        }
        if(flag == 3){

        }
        
        if(addFlag == 1){
        
            
        
        let url:NSURL = NSURL(string: php)!
        
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
                
           
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Add Complete!"
                alertView.message = "You got homies now!"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()

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
        
        
        
        print(self.someInts.count)
        }
        
        

        

        
        
        
    }
    

    @IBAction func onBackTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}
