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
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //tableView.delegate = self
        //tableView.dataSource = self
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let prefs:UserDefaults = UserDefaults.standard
        let isLoggedIn:Int = prefs.integer(forKey: "ISLOGGEDIN") as Int
        if(isLoggedIn != 1){
            self.dismiss(animated: true, completion: nil)
        }
        
        let username:String = prefs.value(forKey: "USERNAME") as! String
        
        
        let post:NSString = "username=\(username)" as NSString
        
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
        
        
        let url:URL = URL(string: "http://www.jjkbashlord.com/" + php)!
        
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
                
                NSLog("Response ==> %@", responseData);
                
                let jsonData1:NSDictionary = (try! JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers )) as! NSDictionary
                
                let jsonData:NSArray = jsonData1.value(forKey: "friends") as! NSArray
                
                
                for index in 0..<jsonData.count{
                    
                    let username1:NSString = (jsonData[index] as AnyObject).value(forKey: "username") as! NSString
                    
                    var title2:NSString = ""
                    if let title1:NSString = (jsonData[index] as AnyObject).value(forKey: "friendname") as? NSString{
                        title2 = ((jsonData[index] as AnyObject).value(forKey: "friendname") as? NSString)!
                    }else{
                        title2 = username1
                    }

                    let status1:Int = (jsonData[index] as AnyObject).value(forKey: "status") as! Int
                    
                    print(title2)
                    let status = Friend(username: username1 as String, showname: title2 as String, timestamp: Date(), loctime: "", location: "")
                    
                    someInts.append(status)
                    print("Friend Entity: " + status.friendname)
                    
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
        
        
        
        print(self.someInts.count)
        
        
        
        
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
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
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
        
        cell.textLabel?.text = self.someInts[indexPath.row].friendname
        print("TableView: " + self.someInts[indexPath.row].friendname)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        var addFlag: Int = 0
        
        
        let prefs:UserDefaults = UserDefaults.standard
        let username:String = prefs.value(forKey: "USERNAME") as! String
        
        let friendname1: Friend = self.someInts[indexPath.row] as Friend
        
        let post:NSString = "user=\(username)&friend=\(friendname1.username)" as NSString
        
        NSLog("PostData: %@",post);
        
        var php:String = ""
        
        if(flag == 0){
           //php = "http://www.jjkbashlord.com/fetchRendevousChat.php"
        }
        if(flag == 1){
            php = "http://www.jjkbashlord.com/addingFriend.php"
            addFlag = 1
            
            let date = Date()
           // var dateFormatter = NSDateFormatter()
           // dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           // dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
            
          //  let addDate = dateFormatter.dateFromString(date)
            
            
            prefs.set(date, forKey: friendname1.username)
        }
        if(flag == 2){
            php = "http://www.jjkbashlord.com/addingBack.php"
            addFlag = 1

            let date = Date()
          //  let dateFormatter = NSDateFormatter()
           // dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           // dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
            
            //let addDate = dateFormatter.dateFromString(date)
            
            
            prefs.set(date, forKey: friendname1.username)
        }
        if(flag == 3){

        }
        
        if(addFlag == 1){
        
            
        
        let url:URL = URL(string: php)!
        
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
                
                NSLog("Response ==> %@", responseData);
                
           
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Add Complete!"
                alertView.message = "You got homies now!"
                alertView.delegate = self
                alertView.addButton(withTitle: "OK")
                alertView.show()

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
        
        
        
        print(self.someInts.count)
        }
        
        

        

        
        
        
    }
    

    @IBAction func onBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
