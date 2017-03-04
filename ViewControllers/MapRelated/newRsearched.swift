//
//  newR.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/26/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit
import CoreLocation

class newRsearched: UIViewController {
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDetails: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    var flag = -1
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var selectedDate: UILabel!
    var programVar : String!
    var location: String!
    
    @IBOutlet weak var selectedType: UILabel!
    @IBOutlet weak var workButton: UIButton!
    
    @IBOutlet weak var funButton: UIButton!
    @IBOutlet weak var eatButton: UIButton!
    @IBOutlet weak var placeDetails: UILabel!
    @IBOutlet weak var boredButton: UIButton!
    
    var manager: OneShotLocationManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workButton.addTarget(self, action: #selector(newRsearched.buttonClicked(_:)), for: .touchUpInside)
        eatButton.addTarget(self, action: #selector(newRsearched.buttonClicked(_:)), for: .touchUpInside)
        funButton.addTarget(self, action: #selector(newRsearched.buttonClicked(_:)), for: .touchUpInside)
        boredButton.addTarget(self, action: #selector(newRsearched.buttonClicked(_:)), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        placeDetails.text = programVar
        txtLocation.text = location
        
    }
    
    func buttonClicked( _ sender: UIButton!) {
        if sender === workButton {
            workButton.isHighlighted = true
            eatButton.isHighlighted = false
            funButton.isHighlighted = false
            boredButton.isHighlighted = false
            self.selectedType.text = "For Work!"
            flag = 2
            // do something
        } else if sender === eatButton {
            workButton.isHighlighted = false
            eatButton.isHighlighted = true
            funButton.isHighlighted = false
            boredButton.isHighlighted = false
            self.selectedType.text = "For Food!"
            flag = 0
            // do something
        } else if sender === funButton {
            workButton.isHighlighted = false
            eatButton.isHighlighted = false
            funButton.isHighlighted = true
            boredButton.isHighlighted = false
            self.selectedType.text = "For Fun!"
            flag = 1
            // do something
        }
        else if sender == boredButton{
            workButton.isHighlighted = false
            eatButton.isHighlighted = false
            funButton.isHighlighted = false
            boredButton.isHighlighted = true
            self.selectedType.text = "Im bored."
            flag = 3
        }
    }
    
    
    
    
    
    @IBAction func datePickerAction(_ sender: AnyObject) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let strDate = dateFormatter.string(from: datePicker.date)
        self.selectedDate.text = strDate
        
    }
    
    
    
    
    @IBAction func newRTapped(_ sender: UIButton) {
        let prefs:UserDefaults = UserDefaults.standard
        
        let username:String = prefs.value(forKey: "USERNAME") as! String
        let title:String = txtTitle.text!
        let detail:String = txtDetails.text!
        let location:String = txtLocation.text!
        let timefor = self.selectedDate.text!
        
        //let dateFormatter = NSDateFormatter()
       // dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        //dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
       // let timefor = dateFormatter.stringFromDate(datePicker.date)
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
            
            //NSLog("Response code: %ld", res?.statusCode);
            
            if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                
                NSLog("Response ==> %@", responseData);
                
                self.dismiss(animated: true, completion: nil)
               // self.performSegueWithIdentifier("goto_mainactivity", sender: self)
                                //self.dismissViewControllerAnimated(true, completion: nil)
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
        
        
        
        
        
        
       // self.performSegueWithIdentifier("goto_mainactivity", sender: self)
        //self.dismissViewControllerAnimated(true, completion: nil)
        //self.performSegueWithIdentifier("goto_mainactivity", sender: self)
        
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
