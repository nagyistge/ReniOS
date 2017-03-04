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
    
    let delegate = UIApplication.shared.delegate as! AppDelegate

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signinTapped(_ sender: UIButton) {
        //Authentication 
        let username:NSString = txtUsername.text! as NSString
        let password:NSString = txtPassword.text! as NSString
        
        if ( username.isEqual(to: "") || password.isEqual(to: "") ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign in Failed!"
            alertView.message = "Please enter Username and Password"
            alertView.delegate = self
            alertView.addButton(withTitle: "OK")
            alertView.show()
        } else {
            
            let post:NSString = "username=\(username)&password=\(password)" as NSString
            
            NSLog("PostData: %@",post);
            
            let url:URL = URL(string: "http://www.jjkbashlord.com/FetchUserData.php")!
            
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
                    
                  //  var error: NSError?
                    
                    let jsonData:NSArray = (try! JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers )) as! NSArray

                    let prefs:UserDefaults = UserDefaults.standard
                    let success:NSString = (jsonData[0] as AnyObject).value(forKey: "username") as! NSString

                    NSLog("Success: %ld", success);
                    
                    if(success == username)
                    {
                        NSLog("Login SUCCESS");
                        
                        if let showname = (jsonData[0] as AnyObject).value(forKey: "showname") as? NSString{
                            prefs.set(showname, forKey: "SHOWNAME")
                        }
                        else{
                            prefs.set("null", forKey: "SHOWNAME")
                        }
                        
                        if let phone = (jsonData[0] as AnyObject).value(forKey: "phonenumber") as? NSString{
                            prefs.set(phone, forKey: "PHONENUMBER")
                        }
                        else{
                            prefs.set("null", forKey: "PHONENUMBER")
                        }
                        
                        if let email = (jsonData[0] as AnyObject).value(forKey: "email") as? NSString{
                            prefs.set(email, forKey: "EMAIL")
                        }
                        else{
                            prefs.set("null", forKey: "EMAIL")
                        }
                        prefs.set(username, forKey: "USERNAME")
                        //prefs.setObject(password, forKey: "PASSWORD")
                        prefs.set(1, forKey: "ISLOGGEDIN")
                        prefs.value(forKey: "USERNAME") as! String

                        
                        for index in 1..<jsonData.count{
                            
                            let username1:NSString = (jsonData[index] as AnyObject).value(forKey: "frienduser") as! NSString
                            let showname1:NSString = (jsonData[index] as AnyObject).value(forKey: "friendname") as! NSString
                           // let title1:NSString = jsonData[index].valueForKey("friendname") as! NSString
                            if let status1 = (jsonData[index] as AnyObject).value(forKey: "timestamp") as? NSString{
                                NSLog(status1 as String)
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                                var date = dateFormatter.date(from: status1 as String)
                                date = dateFormatter.date(from: status1 as String)
                                    prefs.set(date, forKey: username1 as String)
                            }else{
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                 dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                                let nilTimeStamp = "1970-01-01 01:01:01" as NSString
                                let nodate = dateFormatter.date(from: nilTimeStamp as String)
                                prefs.set(nodate, forKey: username1 as String)
                            }
                            let friend:Friend = Friend(username: username1 as String, showname: showname1 as String, timestamp: Date())
                            //self.delegate.addFriend(friend)
                        }
   
                        prefs.synchronize()
                        self.delegate.starting()
                        self.performSegue(withIdentifier: "goto_mainactivity", sender: self)
                        
                    } else {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed!"
                        alertView.message = "Incorrect User Login Info OR you have not registered yet!"
                        alertView.delegate = self
                        alertView.addButton(withTitle: "OK")
                        alertView.show()
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
