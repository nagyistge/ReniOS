//
//  showR.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/26/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit
import CoreLocation



class showRRendez: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate {
     var manager: OneShotLocationManager = OneShotLocationManager()
    let locationManager = CLLocationManager()
    @IBOutlet weak var deleteB: UIButton!
    var isStatusFromYou:Bool!
    @IBOutlet weak var responseName: UILabel!
    @IBOutlet weak var responsePicker: UIPickerView!
    var programVar : Status!
    var programVar1 : RendezStatus!

    @IBOutlet weak var friendResponses: UITableView!
    @IBOutlet weak var sendLocButton: UIButton!
    @IBOutlet weak var timeTxt: UILabel!
    @IBOutlet weak var typeImg: UIImageView!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtDetail: UILabel!
    @IBOutlet weak var txtLocation: UILabel!
    var vc: sendToFriends!
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var vm: showRMap!
    
    var username: String!
    var friendname: String!
    var showuser: String!
    var showfriend: String!
    var responses = ["Seen!", "Interested!", "Available"]
    var transitionOperator = TransitionOperator()
    @IBOutlet weak var visableIndicator: UISwitch!
    @IBOutlet weak var visabl: UILabel!
    var locationCoords:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.friendResponses.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
            txtTitle.text = self.programVar1.title as NSString as String
            txtDetail.text = self.programVar1.details as NSString as String
            txtLocation.text = self.programVar1.location as NSString as String
            if self.programVar1.type == 0{
                typeImg.image = UIImage(named: "eat")
            }
            if self.programVar1.type == 1{
                typeImg.image = UIImage(named: "party")
            }
            if self.programVar1.type == 2{
                typeImg.image = UIImage(named: "working")
            }
            if self.programVar1.type == 3{
                typeImg.image = UIImage(named: "idle")
            }
            self.timeTxt.text = " at " + self.programVar1.timefor
            
            if(self.isStatusFromYou == true){
                if(self.programVar1.response == 0){
                    self.responseName.text = self.programVar1.fromuser + " has recieved."
                }else if(self.programVar1.response == 1){
                    self.responseName.text = self.programVar1.fromuser + " is interested! "
                }else{
                    self.responseName.text = self.programVar1.fromuser + " is available!! "
                }
                
                //responsePicker.selectRow(self.programVar1.response, inComponent: 0, animated: true)
                responsePicker.delegate = nil
                if(friendResponses != nil){
                    friendResponses.removeFromSuperview()
                    responsePicker.removeFromSuperview()
                }
            }else{
                if(self.programVar1.response == 0){
                self.responseName.text = "You have "
                }else{
                    self.responseName.text = "You are "
                }
                responsePicker.selectRow(self.programVar1.response, inComponent: 0, animated: true)
                if(deleteB != nil){
                deleteB.removeFromSuperview()
                friendResponses.removeFromSuperview()
                }
        }
    }
    
    @IBAction func deleteR(sender: UIButton) {
        let post:NSString = "id=\(self.programVar1.id)&flag=\(0)"
        NSLog("PostData: %@",post);
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/updateRendez.php")!
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
            let res = response as! NSHTTPURLResponse
            NSLog("Response code: %ld", res.statusCode);
            if (res.statusCode >= 200 && res.statusCode < 300){
                let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                NSLog("Response ==> %@", responseData);
                self.dismissViewControllerAnimated(true, completion: nil)
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
    
    @IBAction func showOnMapTapped(sender: UIButton) {
        vm = self.storyboard?.instantiateViewControllerWithIdentifier("showRMap") as! showRMap
        let coords = txtLocation.text
        let title = txtTitle.text
        let detail = txtDetail.text
        vm.name = friendname
        vm.coords = coords
        vm.title1 = title
        vm.detail = detail
        vm.flag = 1
        
        self.presentViewController(vm, animated: true, completion: nil)
    }
    
    @IBAction func backTapped(sender: UIButton) {
        //if this value is 0, that means that need to check the response and if it is not the same as it was initially then got to update it
        if self.isStatusFromYou == false{
            if(self.programVar1.response != self.responsePicker.selectedRowInComponent(0)){
                updateStatus( self.programVar1.id, flag: 1, response: self.responsePicker.selectedRowInComponent(0))
                
                for(var i = 0; i < self.delegate.theWozMap[self.programVar1.fromuser]!.allDeesRendez.count; i++ ){
                    if((self.delegate.theWozMap[self.programVar1.fromuser]!.allDeesRendez[i] as RendezStatus) == self.programVar1 as RendezStatus){
                        self.delegate.newfeed[i].response = self.responsePicker.selectedRowInComponent(0)
                    }
                }
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView( tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.programVar == nil){
            return 0
        }else{
            return self.programVar.fromuser.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.friendResponses.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        var r = ""
        if programVar.fromuser[indexPath.row].response == 0{
            r = " has seen!"
        }else if programVar.fromuser[indexPath.row].response == 1{
            r = " is interested!"
        }else if programVar.fromuser[indexPath.row].response == 2{
            r = " is available!"
        }
        
        let resp:String = programVar.fromuser[indexPath.row].username + r
        cell.textLabel!.text = resp
        return cell
        
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.responses.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return self.responses[row]
    }

    func updateStatus(id:Int, flag:Int, response:Int) {

        let post:NSString = "id=\(id)&response=\(response)&flag=\(flag)"
        NSLog("PostData: %@",post);
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/updateRendez.php")!
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
            let res = response as! NSHTTPURLResponse
            NSLog("Response code: %ld", res.statusCode);
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                NSLog("Response ==> %@", responseData);
                self.dismissViewControllerAnimated(true, completion: nil)
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
