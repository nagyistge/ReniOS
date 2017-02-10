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
        
        // Do any additional setup after loading the view.
        workButton.addTarget(self, action: #selector(newR.buttonClicked(_:)), for: .touchUpInside)
        eatButton.addTarget(self, action: #selector(newR.buttonClicked(_:)), for: .touchUpInside)
        partyButton.addTarget(self, action: #selector(newR.buttonClicked(_:)), for: .touchUpInside)
        boredButton.addTarget(self, action: #selector(newR.buttonClicked(_:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestWhenInUseAuthorization()
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
    
    func buttonClicked( _ sender: UIButton!) {
        if sender === workButton {
            workButton.isHighlighted = true
            eatButton.isHighlighted = false
            partyButton.isHighlighted = false
            boredButton.isHighlighted = false
            self.buttonLabel.text = "For Work!"
            flag = 2
            // do something
        } else if sender === eatButton {
            workButton.isHighlighted = false
            eatButton.isHighlighted = true
            partyButton.isHighlighted = false
            boredButton.isHighlighted = false
            self.buttonLabel.text = "For Food!"
            flag = 0
            // do something
        } else if sender === partyButton {
            workButton.isHighlighted = false
            eatButton.isHighlighted = false
            partyButton.isHighlighted = true
            boredButton.isHighlighted = false
            self.buttonLabel.text = "For Fun!"
            flag = 1
            // do something
        }
        else if sender == boredButton{
            workButton.isHighlighted = false
            eatButton.isHighlighted = false
            partyButton.isHighlighted = false
            boredButton.isHighlighted = true
            self.buttonLabel.text = "Im bored."
            flag = 3
        }
    }

    
    
    @IBAction func dateChanger(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let strDate = dateFormatter.string(from: datePicker.date)
        self.dateLabel.text = strDate
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 2
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
    
    
    

    @IBAction func newRTapped(_ sender: UIButton) {
        let prefs:UserDefaults = UserDefaults.standard

        let username:String = prefs.value(forKey: "USERNAME") as! String
        let title:String = txtTitle.text!
        let detail:String = txtDetails.text!
        let location:String = txtLocation.text!
                let timefor = self.dateLabel.text!
        
        if(flag == -1){
            print(flag)
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Pick a type!"
            alertView.message = "Are you working, eating, going out having a blast, or bored??"
            alertView.delegate = self
            alertView.addButton(withTitle: "OK")
            alertView.show()
        }
        else if(title.isEmpty || detail.isEmpty){
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Fill it out!!"
            alertView.message = "Be as descriptive or non-descriptive as you'd like, but put something!"
            alertView.delegate = self
            alertView.addButton(withTitle: "OK")
            alertView.show()
        }
        else{
        let post:NSString = "username=\(username)&title=\(title)&detail=\(detail)&location=\(location)&timefor=\(timefor)&type=\(flag)" as NSString
        NSLog("PostData: %@",post);
        
        let url:URL = URL(string: "http://www.jjkbashlord.com/newStatus.php")!
        
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
            
            NSLog("Response code: %ld", res?.statusCode);
            
            if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                
                NSLog("Response ==> %@", responseData);
                
             //   var error: NSError?
                
                self.dismiss(animated: true, completion: nil)
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
        self.dismiss(animated: true, completion: nil)
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
