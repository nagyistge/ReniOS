//
//  editUserInfo.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/30/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit
import Foundation

class editUserInfo: UIViewController {

    
    var flag: Int!
    @IBOutlet weak var editInfoTitle: UILabel!
    @IBOutlet weak var editInfoDesc: UILabel!
    let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
    
    var php: String!
    
    
    @IBOutlet weak var editInfo: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if(flag == 0){
            editInfoTitle.text = "Edit Your Display Name!"
            editInfoDesc.text = "Type your new display name below and press SET!"
            php = "setShowname.php"
        }
        if(flag == 1){
            editInfoTitle.text = "Edit Your Email!"
            editInfoDesc.text = "Type your new Email below and press SET!"
            php = "setEmail.php"

            
        }
        if(flag == 2){

            editInfoTitle.text = "Edit Your Phonenumber!"
            editInfoDesc.text = "Type your new phonenumber below and press SET!"
            php = "setPhonenumber.php"

        
        }
        
        
    }
    
    
    
    @IBAction func onSetTapped(sender: UIButton) {
        var alert: Bool = false
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username:String = prefs.valueForKey("USERNAME") as! String
        let password:String = prefs.valueForKey("PASSWORD") as! String
        var param:String!
        if(editInfo.text!.isEmpty){
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Empty field!"
            alertView.message = "Please enter Display Name/ Email/ Phonenumber above!"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        
        }
        if(flag == 0){
            param = editInfo.text
            prefs.setObject(param, forKey: "SHOWNAME")
                                    prefs.synchronize()
        }
        if(flag == 1){
            if(isValidEmail(editInfo.text!)){
                param = editInfo.text
                 prefs.setObject(param, forKey: "EMAIL")
                                        prefs.synchronize()

                
            }
            else{
                alert = true
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Invalid Email!"
                alertView.message = "Please enter a valid email address!!"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
        if(flag == 2){
            if(isValidPhonenumber(editInfo.text!)){
                param = editInfo.text
                param = param.stringByReplacingOccurrencesOfString("\\D", withString: "", options: .RegularExpressionSearch,range: param.startIndex..<param.endIndex)
                 prefs.setObject(param, forKey: "PHONENUMBER")
                                        prefs.synchronize()
            }
            else{
                alert = true
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Invalid Phonenumber!"
                alertView.message = "Please enter a valid phonenumber!!!"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
        
        if(alert == false){
        
        
        
            let post:NSString = "username=\(username)&password=\(password)&param=\(param)"
        
            NSLog("PostData: %@",post);
        
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
        
        
            let res = response as! NSHTTPURLResponse!;
        
            NSLog("Response code: %ld", res.statusCode);
        
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                NSLog("Edit SUCCESS");
                
                
                self.dismissViewControllerAnimated(false, completion: nil)
            } else {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection Failed"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
        else{
        }

        
        
        
    }
    
    func isValidPhonenumber(value: String) -> Bool {
        
        let PHONE_REGEX = "^((\\+)|(00)|(\\*)|())[0-9]{3,14}((\\#)|())$"
        
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        
        let result =  phoneTest.evaluateWithObject(value)
        
        return result
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        
        print("validate emilId: \(testStr)")
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let result = emailTest.evaluateWithObject(testStr)
        
        return result
        
    }
    



}
