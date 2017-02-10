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
        let prefs:UserDefaults = UserDefaults.standard
        showname = prefs.string(forKey: "SHOWNAME")!
        email = prefs.string(forKey: "EMAIL")!
        phonenumber = prefs.string(forKey: "PHONENUMBER")!

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        }

    override func viewDidAppear(_ animated: Bool) {
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
        txtDisplayname.setTitle(showname, for: UIControlState())
        txtPhonenumber.setTitle(phonenumber, for: UIControlState())
        txtEmail.setTitle(email, for: UIControlState())
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
    @IBAction func onLogoutTapped(_ sender: UIButton) {
        let appDomain = Bundle.main.bundleIdentifier
        
        let prefs:UserDefaults = UserDefaults.standard
        let username = prefs.value(forKey: "USERNAME")
        let delegate = UIApplication.shared.delegate as! AppDelegate

        let friends = delegate.yourFriends
        var notifArr = [AnyObject]()
        
        for(i in 0 ..< friends.count){
           let time =  (prefs.value(forKey: friends[i].username)? as AnyObject).description!
            notifArr.append(["friend": friends[i].username, "time": time])
        
        }
        
        let finalNSArray:NSArray = notifArr as NSArray
        let finalarr:NSDictionary = ["json": finalNSArray, "username":username!]
        NSLog("PostData: %@",finalarr);
        let url:URL = URL(string: "http://www.jjkbashlord.com/onLogout.php")!
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
                NSLog("sent!!!!!!!")
                delegate.mSocket.disconnect(fast: true)
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
        
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
    
        self.performSegue(withIdentifier: "goto_login", sender: self)
        
    }
    
    
    @IBAction func onSetDisplaynameTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "editUser") as! editUserInfo

        vc.flag = 0
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func onSetEmailTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "editUser") as! editUserInfo
        vc.flag = 1
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func onSetPhonenumberTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "editUser") as! editUserInfo
        vc.flag = 2
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func onFriendSettingsTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "editFriendlist") as! editUserInfo
    }

    @IBAction func onBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    


}
