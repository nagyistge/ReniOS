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

    @IBOutlet weak var bBack: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bCreate: UIButton!

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
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        // Do any additional setup after loading the view.
        workButton.addTarget(self, action: #selector(newR.buttonClicked(_:)), for: .touchUpInside)
        eatButton.addTarget(self, action: #selector(newR.buttonClicked(_:)), for: .touchUpInside)
        partyButton.addTarget(self, action: #selector(newR.buttonClicked(_:)), for: .touchUpInside)
        boredButton.addTarget(self, action: #selector(newR.buttonClicked(_:)), for: .touchUpInside)
        topLabel.frame = CGRect(x: 0, y: 20, width: width, height: 45)
        txtTitle.frame = CGRect(origin: CGPoint(x: 20, y: 100 ), size: CGSize(width: width-40, height: txtTitle.frame.size.height ))
        txtDetails.frame = CGRect(origin: CGPoint(x: 20, y: 150 ), size: CGSize(width: width-40, height: txtTitle.frame.size.height ))
        txtLocation.frame = CGRect(origin: CGPoint(x: 20, y: 200 ), size: CGSize(width: width-40, height: txtTitle.frame.size.height ))
        
        buttonLabel.frame = CGRect(x: ((width/2)-(buttonLabel.frame.size.width/2)), y: txtLocation.frame.origin.y+50, width: buttonLabel.frame.size.width, height: buttonLabel.frame.size.height)
        workButton.frame = CGRect(x: (width/2)-(80), y: buttonLabel.frame.origin.y + 20.0, width: 75, height: 75)
        eatButton.frame = CGRect(x: workButton.frame.origin.x, y: workButton.frame.origin.y + 80, width: 75, height: 75)
        partyButton.frame = CGRect(x: (width/2)+5, y: workButton.frame.origin.y, width: 75, height: 75)
        boredButton.frame = CGRect(x: (width/2)+5, y: eatButton.frame.origin.y, width: 75, height: 75)
        
        dateLabel.frame = CGRect(x: (width/2)-(dateLabel.frame.size.width/2), y: boredButton.frame.origin.y+boredButton.frame.size.height+5, width: dateLabel.frame.size.width, height: dateLabel.frame.size.height)
        datePicker.frame = CGRect(x: 0, y: dateLabel.frame.origin.y+50, width: width, height: datePicker.frame.size.height+20 )
        
        bCreate.layer.cornerRadius = 10
        bCreate.frame = CGRect(x: (width-300)/2, y: height-95, width: 300, height: 60)
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
            print(location)
            print(location.coordinate.latitude)
            
            let lat: Double = location.coordinate.latitude
            let long: Double = location.coordinate.longitude
            let coords: String = String(format:"%f", lat)+" : "+String(format:"%f", long)
            self.txtLocation.text = coords

            locationManager.stopUpdatingLocation()
        }
    }
    
    
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
            let alert = UIAlertController(title: "Pick a type!", message: "Are you working, eating, going out, or bored?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title:  "OK", style: .default) { action in
                // perhaps use action.title here
            })
            self.present(alert, animated: true, completion: nil)
        }
        else if(title.isEmpty || detail.isEmpty){
            
            let alert = UIAlertController(title: "Fill it out!", message: "Be as detailed as possible!", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title:  "OK", style: .default) { action in
                // perhaps use action.title here
            })
            self.present(alert, animated: true, completion: nil)
        
        }else{
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
            
                if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300){
                    let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                    NSLog("Response ==> %@", responseData);
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Sign in Failed!", message: "Connection Failed", preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title:  "OK", style: .default) { action in
                            // perhaps use action.title here
                    })
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Sign in Failed!", message: "Connection Failed", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title:  "OK", style: .default) { action in
                        // perhaps use action.title here
                })
                
                if let error = reponseError {
                    alert.message = (error.localizedDescription)
                }
                self.present(alert, animated: true, completion: nil)
            
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
