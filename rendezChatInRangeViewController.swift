//
//  rendezChatInRangeViewController.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 7/27/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit

class rendezChatInRangeViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
        //usernames
        var username: String!
        var friendname: String!
        //display names
        var showuser: String!
        var showfriend: String!
        
        @IBOutlet weak var userLabel: UILabel!
        @IBOutlet weak var friendLabel: UILabel!
        @IBOutlet weak var tableVie: UITableView!
        @IBOutlet weak var txtChatBox: UITextField!
        let transitionOperator = TransitionOperator()
    
        //need a custom cell that can hold... lets say 3 values ranging 
    //from 0-2 indicating distance/range for when to notify
        @IBOutlet weak var customCell: UITableViewCell!

        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var flag:Int = -1
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
    }
        
        override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(true)

        }
        
        override func viewDidAppear(animated: Bool) {
            super.viewDidAppear(true)
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
          
        }
        
        //NSNotificationStuff---NSNotificationStuff---
        //-ON RECIEVE
        //should be called by the app delegate when it gets new emit by the NSNotificationCenter
        internal func updateChattingNotif(notification:NSNotification){
            print("is the update in rendezChat even called??")
            //get the friend param and set it
        }
    
        //--TABLE STUFF ------TABLE STUFF ------TABLE STUFF ------TABLE STUFF ------TABLE STUFF ------
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableVie.dequeueReusableCellWithIdentifier("customCell", forIndexPath: indexPath)
            
            return cell
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        
        @IBAction func backTapped(sender: UIButton) {
            dismissViewControllerAnimated(true, completion: nil)
        }
        

}