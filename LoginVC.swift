//
//  LoginVC.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/24/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signinTapped(sender: UIButton) {
        //Authentication 
        let username:NSString = txtUsername.text!
        let password:NSString = txtPassword.text!
        
        if ( username.isEqualToString("") || password.isEqualToString("") ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign in Failed!"
            alertView.message = "Please enter Username and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            
            let post:NSString = "username=\(username)&password=\(password)"
            
            NSLog("PostData: %@",post);
            
            let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/FetchUserData.php")!
            
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
                    
                  //  var error: NSError?
                    
                    let jsonData:NSArray = (try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers )) as! NSArray

                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    let success:NSString = jsonData[0].valueForKey("username") as! NSString

                    NSLog("Success: %ld", success);
                    
                    if(success == username)
                    {
                        NSLog("Login SUCCESS");
                        
                        if let showname = jsonData[0].valueForKey("showname") as? NSString{
                            prefs.setObject(showname, forKey: "SHOWNAME")
                        }
                        else{
                            prefs.setObject("null", forKey: "SHOWNAME")
                        }
                        
                        if let phone = jsonData[0].valueForKey("phonenumber") as? NSString{
                            prefs.setObject(phone, forKey: "PHONENUMBER")
                        }
                        else{
                            prefs.setObject("null", forKey: "PHONENUMBER")
                        }
                        
                        if let email = jsonData[0].valueForKey("email") as? NSString{
                            prefs.setObject(email, forKey: "EMAIL")
                        }
                        else{
                            prefs.setObject("null", forKey: "EMAIL")
                        }
                        prefs.setObject(username, forKey: "USERNAME")
                        //prefs.setObject(password, forKey: "PASSWORD")
                        prefs.setInteger(1, forKey: "ISLOGGEDIN")
                        prefs.valueForKey("USERNAME") as! String

                        
                        for(var index = 1; index < jsonData.count; index++ ){
                            
                            let username1:NSString = jsonData[index].valueForKey("frienduser") as! NSString
                            let showname1:NSString = jsonData[index].valueForKey("friendname") as! NSString
                           // let title1:NSString = jsonData[index].valueForKey("friendname") as! NSString
                            if let status1 = jsonData[index].valueForKey("timestamp") as? NSString{
                                NSLog(status1 as String)
                                let dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                                var date = dateFormatter.dateFromString(status1 as String)
                                date = dateFormatter.dateFromString(status1 as String)
                                    prefs.setObject(date, forKey: username1 as String)
                            }else{
                                let dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                 dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                                let nilTimeStamp = "1970-01-01 01:01:01" as NSString
                                let nodate = dateFormatter.dateFromString(nilTimeStamp as String)
                                prefs.setObject(nodate, forKey: username1 as String)
                            }
                            let friend:Friend = Friend(username: username1 as String, showname: showname1 as String, timestamp: NSDate())
                            //self.delegate.addFriend(friend)
                        }
   
                        prefs.synchronize()
                        self.delegate.starting()
                        self.performSegueWithIdentifier("goto_mainactivity", sender: self)
                        
                    } else {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed!"
                        alertView.message = "Incorrect User Login Info OR you have not registered yet!"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
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
        
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
