//
//  ContentViewController.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/25/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, showRDelegate{

    @IBOutlet weak var friendTableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var items: [String] = ["We", "Heart", "Swift"]
    var someInts = [Status]()
    var someFriendInts = [Status]()
    var statusToPass: Status!
    var newCar: String = ""
    var vc: showR!
    var username:String!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtUsername: UILabel!
    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.friendTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell1")
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if(isLoggedIn != 1){
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.txtUsername.text = prefs.valueForKey("USERNAME") as? String
        username = prefs.valueForKey("USERNAME") as! String
        if (self.delegate.theWozMap[username] == nil){
            self.delegate.starting()
            
        }
         //let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.someInts.appendContentsOf( self.delegate.theWozMap[username]!.allDeesStatus )
        self.someFriendInts.appendContentsOf(self.delegate.newfeed)

        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username:String = prefs.valueForKey("USERNAME") as! String
        
        let delegate1 = UIApplication.sharedApplication().delegate as! AppDelegate
        print("IS THIS BEING CALLED???")
        self.someInts.removeAll()
        self.someFriendInts.removeAll()
        self.someInts.appendContentsOf( delegate1.theWozMap[username]!.allDeesStatus )
        self.someFriendInts.appendContentsOf(delegate1.newfeed)
        self.tableView.reloadData()
        self.friendTableView.reloadData()

    }
    
func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
func tableView( tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
    if tableView == self.tableView{
        return self.someInts.count
    }
    else{
    return self.someFriendInts.count
    }
    }
    func friendTableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return self.someFriendInts.count
    }
    
 func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 3

        //NSLog("WHEN DOES THE TABLE REFRESH?  WHERE DO I NEED TO SET SOMEINTS")
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    let username = prefs.valueForKey("USERNAME") as! String
    if tableView == self.tableView{
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
         cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel!.text = self.someInts[indexPath.row].title
        var v = ""
        if(self.someInts[indexPath.row].visable == 0){
            v += "private"
        }else{
            v += "public"
        }
         cell.detailTextLabel!.text = v
        return cell
    }
    else{
       // var friendcell:UITableViewCell = self.friendTableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath)
        //if friendcell != nil{
        //  friendcell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        let friendcell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell1")
         friendcell.selectionStyle = UITableViewCellSelectionStyle.None
        
        friendcell.textLabel!.text = self.someFriendInts[indexPath.row].title
        print( self.someFriendInts[indexPath.row].username)
        
        
        friendcell.detailTextLabel!.text = "from " + self.someFriendInts[indexPath.row].username
        return friendcell
    }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        if tableView == self.tableView{
        let currentCell = self.someInts[indexPath.row] as Status
        statusToPass = currentCell
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = self.storyboard?.instantiateViewControllerWithIdentifier("showR") as! showR
        vc.programVar = statusToPass
        vc.isStatusFromYou = true
            vc.returnDelegate = self
        
            
       
        self.presentViewController(vc, animated: true, completion: nil)
        }
        else{
            let currentCell = self.someFriendInts[indexPath.row] as Status
            statusToPass = currentCell
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            vc = self.storyboard?.instantiateViewControllerWithIdentifier("showR") as! showR
            vc.programVar = statusToPass
            vc.isStatusFromYou = false
            vc.returnDelegate = self
            
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    


    @IBAction func newR(sender: AnyObject) {
    
    
    }


    func returnUpdate(status:Status){
        
        for(var i = 0; i < self.delegate.newfeed.count; i++ ){
            if((  self.delegate.newfeed[i] as Status) == status){
                
                self.delegate.newfeed[i].visable = 0
                //self.returnDelegate.returnUpdate(self.delegate.newfeed[i])
            }
        }
        
    
    }


}
