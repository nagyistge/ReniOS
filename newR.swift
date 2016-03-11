//
//  newR.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/26/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import GoogleMaps

class newR: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate
{


    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDetails: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    var manager: OneShotLocationManager = OneShotLocationManager()
    let locationManager = CLLocationManager()
    var flag = -1
    
    @IBOutlet weak var buttonLabel: UILabel!
    
    @IBOutlet weak var workButton: UIButton!
    @IBOutlet weak var boredButton: UIButton!
    @IBOutlet weak var eatButton: UIButton!
    @IBOutlet weak var partyButton: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        // Do any additional setup after loading the view.
        workButton.addTarget(self, action: "buttonClicked:", forControlEvents: .TouchUpInside)
        eatButton.addTarget(self, action: "buttonClicked:", forControlEvents: .TouchUpInside)
        partyButton.addTarget(self, action: "buttonClicked:", forControlEvents: .TouchUpInside)
        boredButton.addTarget(self, action: "buttonClicked:", forControlEvents: .TouchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        manager = OneShotLocationManager()
        manager.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                print(location)
                let lat: Double = loc.coordinate.latitude
                let long: Double = loc.coordinate.longitude
                let coords: String = String(format:"%f", lat)+" : "+String(format:"%f", long)
                self.txtLocation.text = coords
            } else if let err = error {
                print(err.localizedDescription)
            }
           // self.manager = nil
        }
    }
    
    func buttonClicked( sender: UIButton!) {
        if sender === workButton {
            workButton.highlighted = true
            eatButton.highlighted = false
            partyButton.highlighted = false
            boredButton.highlighted = false
            self.buttonLabel.text = "For Work!"
            flag = 2
            // do something
        } else if sender === eatButton {
            workButton.highlighted = false
            eatButton.highlighted = true
            partyButton.highlighted = false
            boredButton.highlighted = false
            self.buttonLabel.text = "For Food!"
            flag = 0
            // do something
        } else if sender === partyButton {
            workButton.highlighted = false
            eatButton.highlighted = false
            partyButton.highlighted = true
            boredButton.highlighted = false
            self.buttonLabel.text = "For Fun!"
            flag = 1
            // do something
        }
        else if sender == boredButton{
            workButton.highlighted = false
            eatButton.highlighted = false
            partyButton.highlighted = false
            boredButton.highlighted = true
            self.buttonLabel.text = "Im bored."
            flag = 3
        }
    }

    
    
    @IBAction func dateChanger(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        self.dateLabel.text = strDate
    }
    
    
    
    
    
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // 2
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(locations.first)
            print(location)
            print(location.coordinate.latitude)
            
            let lat: Double = location.coordinate.latitude
            let long: Double = location.coordinate.longitude
            let coords: String = String(format:"%f", lat)+" : "+String(format:"%f", long)
            self.txtLocation.text = coords

            locationManager.stopUpdatingLocation()
        }
        
    }
    
    
    

    @IBAction func newRTapped(sender: UIButton) {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()

        let username:String = prefs.valueForKey("USERNAME") as! String
        let title:String = txtTitle.text!
        let detail:String = txtDetails.text!
        let location:String = txtLocation.text!
                var timefor = self.dateLabel.text!
        
        if(flag == -1){
            print(flag)
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Pick a type!"
            alertView.message = "Are you working, eating, going out having a blast, or bored??"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        else if(title.isEmpty || detail.isEmpty){
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Fill it out!!"
            alertView.message = "Be as descriptive or non-descriptive as you'd like, but put something!"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        else{
        let post:NSString = "username=\(username)&title=\(title)&detail=\(detail)&location=\(location)&timefor=\(timefor)&type=\(flag)"
        NSLog("PostData: %@",post);
        
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/newStatus.php")!
        
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
                
                var error: NSError?
                
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
