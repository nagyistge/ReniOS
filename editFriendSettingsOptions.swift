//
//  editFriendSettingsOptions.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/30/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit
import AddressBook
import Foundation

class editFriendSettingsOptions: UIViewController {
        var vc: showFriendlistTypes!
    
    
    //var contactsImporter: ContactsImporter!
    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    var contacts: Array<Contact>!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showContacts(contacts: Array<Contact>) {
        let alertView = UIAlertView(title: "Success!", message: "\(contacts.count) contacts imported successfully", delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }

    @IBAction func onSyncTapped(sender: UIButton) {
        //let contactsImporter = ContactsImporter()
                print("DO I NEED CONTACTS IMPORTER?")
        ContactsImporter.importContacts(showContacts)
                print("MIDDE USERNAME IS SET")
        contacts = ContactsImporter.copyContacts()

        print(contacts.count)
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username:String = prefs.valueForKey("USERNAME") as! String

        var arr = [AnyObject]()
        
        //let dic = ["2": "B", "1": "A", "3": "C"]
       // arr.append(dic)
    
        print("BEFORE USERNAME IS SET, BEFORE FOR LOOP")
        let first = ["name": username]
        arr.append(first)
        for contact in contacts{
            let name: NSString = contact.firstName + " " + contact.lastName
            
            if(contact.phonenumber.count != 0){
            let param:NSString = contact.phonenumber[0].stringByReplacingOccurrencesOfString("\\D", withString: "", options: .RegularExpressionSearch,range: contact.phonenumber[0].startIndex..<contact.phonenumber[0].endIndex)
            
            
            
            let paramint:NSInteger = param.integerValue
            var emailparam:NSString!
                    print("BEFORE EMAIL COUNT")
            if(contact.email.count == 0){
                emailparam = "No Email"
            }
            else{
            emailparam = contact.email[0]
            }
            print("JSON SHIT")
                let jsonObject = ["name": name, "phonenumber": paramint, "email": emailparam]
                arr.append(jsonObject)
            }else
            {
                let paramint = "0"
                let emailparam = "screw emails"
            
            let jsonObject = ["name": name, "phonenumber": paramint, "email": emailparam]
            arr.append(jsonObject)
            }
        }
        let fuckingNSArray:NSArray = arr
        let fuckingfinal:NSDictionary = ["json": fuckingNSArray]
        
        print(fuckingNSArray[0].valueForKey("name"))
        NSLog("PostData: %@",fuckingfinal);
        
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/fetchFriendsSwift.php")!

        var theFuckingPostData:NSData = NSKeyedArchiver.archivedDataWithRootObject(fuckingNSArray)
        let da:NSData = try! NSJSONSerialization.dataWithJSONObject(fuckingfinal, options: [])
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
    
    
    @IBAction func onFriendlistTapped(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = self.storyboard?.instantiateViewControllerWithIdentifier("friendlistType") as! showFriendlistTypes
        vc.flag = 0
        self.presentViewController(vc, animated: true, completion: nil)
        
        
    }

    
    @IBAction func onAddFriendsTapped(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = self.storyboard?.instantiateViewControllerWithIdentifier("friendlistType") as! showFriendlistTypes
        vc.flag = 1
        self.presentViewController(vc, animated: true, completion: nil)
        
        
    }
    
    @IBAction func onFriendsAddedYouTapped(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = self.storyboard?.instantiateViewControllerWithIdentifier("friendlistType") as! showFriendlistTypes
        vc.flag = 2
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    
    @IBAction func onInviteFriendsTapped(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = self.storyboard?.instantiateViewControllerWithIdentifier("friendlistType") as! showFriendlistTypes
        vc.flag = 3
        self.presentViewController(vc, animated: true, completion: nil)
        
    }

    
    
    @IBAction func onBackTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
