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
    override func viewDidAppear(_ animated: Bool) {
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
    
    
    
    @IBAction func onSetTapped(_ sender: UIButton) {
        var alert: Bool = false
        let prefs:UserDefaults = UserDefaults.standard
        let username:String = prefs.value(forKey: "USERNAME") as! String
        let password:String = prefs.value(forKey: "PASSWORD") as! String
        var param:String!
        if(editInfo.text!.isEmpty){
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Empty field!"
            alertView.message = "Please enter Display Name/ Email/ Phonenumber above!"
            alertView.delegate = self
            alertView.addButton(withTitle: "OK")
            alertView.show()
        
        }
        if(flag == 0){
            param = editInfo.text
            prefs.set(param, forKey: "SHOWNAME")
                                    prefs.synchronize()
        }
        if(flag == 1){
            if(isValidEmail(editInfo.text!)){
                param = editInfo.text
                 prefs.set(param, forKey: "EMAIL")
                                        prefs.synchronize()

                
            }
            else{
                alert = true
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Invalid Email!"
                alertView.message = "Please enter a valid email address!!"
                alertView.delegate = self
                alertView.addButton(withTitle: "OK")
                alertView.show()
            }
        }
        if(flag == 2){
            if(isValidPhonenumber(editInfo.text!)){
                param = editInfo.text
                param = param.replacingOccurrences(of: "\\D", with: "", options: .regularExpression,range: param.range(of: param) )
                prefs.set(param, forKey: "PHONENUMBER")
                prefs.synchronize()
            }
            else{
                alert = true
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Invalid Phonenumber!"
                alertView.message = "Please enter a valid phonenumber!!!"
                alertView.delegate = self
                alertView.addButton(withTitle: "OK")
                alertView.show()
            }
        }
        
        if(alert == false){
            let post:NSString = "username=\(username)&password=\(password)&param=\(param)" as NSString
        
            NSLog("PostData: %@",post);
        
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
        
        
            let res = response as! HTTPURLResponse!;
        
            //NSLog("Response code: %ld", res?.statusCode);
        
            if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
            {
                NSLog("Edit SUCCESS");
                
                
                self.dismiss(animated: false, completion: nil)
            } else {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection Failed"
                alertView.delegate = self
                alertView.addButton(withTitle: "OK")
                alertView.show()
            }
        }
        else{
        }

        
        
        
    }
    
    func isValidPhonenumber(_ value: String) -> Bool {
        
        let PHONE_REGEX = "^((\\+)|(00)|(\\*)|())[0-9]{3,14}((\\#)|())$"
        
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        
        let result =  phoneTest.evaluate(with: value)
        
        return result
        
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        
        print("validate emilId: \(testStr)")
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let result = emailTest.evaluate(with: testStr)
        
        return result
        
    }
    



}
