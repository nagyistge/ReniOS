//
//  SettingsMenu.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/24/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

class SettingsMenu: UIViewController {

    
    //var user:User!
    
   // @IBOutlet weak var txtDisplayname: UITextField!
    //@IBOutlet weak var txtPhonenumber: UITextField!
    //@IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtDisplayname: UIButton!
    @IBOutlet weak var txtPhonenumber: UIButton!
    @IBOutlet weak var txtEmail: UIButton!
        var vc: editUserInfo!
    
    
    var showname: String!
    var email:String!
    var phonenumber: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        showname = prefs.stringForKey("SHOWNAME")!
        email = prefs.stringForKey("EMAIL")!
        phonenumber = prefs.stringForKey("PHONENUMBER")!

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if(showname == "null"){
            showname = "Choose a display name!"
        }
        if(phonenumber == "null"){
            phonenumber = "Set your phonenumber!"
        }
        if(email == "null"){
            email = "Set your email!"
        }
        txtDisplayname.setTitle(showname, forState: .Normal)
        txtPhonenumber.setTitle(phonenumber, forState: .Normal)
        txtEmail.setTitle(email, forState: .Normal)
        print(showname + "  "  + phonenumber + "  " + email )
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onLogoutTapped(sender: UIButton) {
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username = prefs.valueForKey("USERNAME")
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

        let friends = delegate.yourFriends
        var notifArr = [AnyObject]()
        
        for(var i = 0; i < friends.count; i++){
           let time =  prefs.valueForKey(friends[i].username)?.description!
            notifArr.append(["friend": friends[i].username, "time": time])
        
        }
        
        let finalNSArray:NSArray = notifArr
        let finalarr:NSDictionary = ["json": finalNSArray, "username":username!]
        NSLog("PostData: %@",finalarr);
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/onLogout.php")!
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
                NSLog("sent!!!!!!!")
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
        
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
    
        self.performSegueWithIdentifier("goto_login", sender: self)
        
    }
    
    
    @IBAction func onSetDisplaynameTapped(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewControllerWithIdentifier("editUser") as! editUserInfo

        vc.flag = 0
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func onSetEmailTapped(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewControllerWithIdentifier("editUser") as! editUserInfo
        vc.flag = 1
        self.presentViewController(vc, animated: true, completion: nil)
    }

    @IBAction func onSetPhonenumberTapped(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewControllerWithIdentifier("editUser") as! editUserInfo
        vc.flag = 2
        self.presentViewController(vc, animated: true, completion: nil)
    }

    @IBAction func onFriendSettingsTapped(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewControllerWithIdentifier("editFriendlist") as! editUserInfo
    }

    @IBAction func onBackTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    


}
