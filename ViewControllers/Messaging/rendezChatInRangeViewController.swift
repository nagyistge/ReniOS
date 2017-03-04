//
//  rendezChatInRangeViewController.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 7/27/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit
import Foundation
class rendezChatInRangeViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
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

    @IBOutlet weak var inRangesTitle: UILabel!
    
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        var flag:Int = -1
    
    var rangeflag:Int = 0
    
    var rendezes = [RendezStatus]()
    var statuses = [Status]()
    
    var finalarr = [AnyObject]()
    var finalarrInd = [Int:Double]()//array for holding indexes as well as manhattan dist vals
    var finalInd = [Int]()//extracted indexes from finalarrInd by taking the keys in the array
    
    let locationManager = CLLocationManager()
    var manager: OneShotLocationManager = OneShotLocationManager()
    var coords:String = "gwang"
    var x:String = "x"
    var y:String = "y"
    
    
        override func viewDidLoad() {
            super.viewDidLoad()
            self.tableVie.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

             locationManager.delegate = self
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)

        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(true)
            let delegate = UIApplication.shared.delegate as! AppDelegate
          locationManager.requestWhenInUseAuthorization()
            manager = OneShotLocationManager()
            manager.fetchWithCompletion {location, error in
                // fetch location or an error
                if let loc = location {
                    print(location)
                    let lat: Double = loc.coordinate.latitude
                    let long: Double = loc.coordinate.longitude
                    self.coords = String(format:"%f", lat)+" : "+String(format:"%f", long)
                    self.x = String(format:"%f", lat)
                    self.y = String(format:"%f", long)
                    self.queryRanges()
                    self.tableVie.reloadData()
                } else if let err = error {
                    print(err.localizedDescription)
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Connection Error!"
                    alertView.message = "Location could not be found!"
                    alertView.delegate = self
                    alertView.addButton(withTitle: "OK")
                    alertView.show()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        

    
        //--TABLE STUFF ------TABLE STUFF ------TABLE STUFF ------TABLE STUFF ------TABLE STUFF ------
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            //return query_effit.count
            //return query_rendezes.count + query_statuses.count
            return finalarr.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            //finalInd[indexPath.row] is basically an array of indexes of Rendezes and Statuses
            // and their manhattan distanes.
            //finalarr holds the rendezes/statuses and finalarrInd holds the manhattan distances as
            //seen below
            
            let cell = tableVie.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            if let rr = finalarr[finalInd[indexPath.row]] as? RendezStatus{
                //use the indexPath.row to ge the ith shortest distance RendezStatus
                let r = finalarr[finalInd[indexPath.row]] as! RendezStatus
                //
                cell.textLabel?.text = r.title + " is " + String( Int(finalarrInd[finalInd[indexPath.row]]!)) + " m away!"
            }else{
                let r = finalarr[finalInd[indexPath.row]] as! Status
                 //cell.textLabel?.text = r!.title + " " + r!.username + " " + r!.timeset
                cell.textLabel?.text = r.title + " is " + String( Int(finalarrInd[finalInd[indexPath.row]]!)) + " m away!"
            }
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        if let rr = finalarr[finalInd[indexPath.row]] as? RendezStatus{
            //use the indexPath.row to get the ith shortest distance RendezStatus
            let r = finalarr[finalInd[indexPath.row]] as! RendezStatus
            print("title:" + r.title )
            fireOffRange(r.id, flag: self.rangeflag)
        }else{
            let r = finalarr[finalInd[indexPath.row]] as! Status
            print("title:" +  r.title)
            fireOffRange(r.id, flag: self.rangeflag)
        }
       
    
    }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        
        @IBAction func backTapped(_ sender: UIButton) {
            self.dismiss(animated: true, completion: nil)
        }
    
    func ManHanDist(_ x:String, y:String, xcoord:String, ycoord:String, flag:Int) -> Bool {
        let xx = Double(x)
        let yy = Double(y)
        
        let xxcoord = Double(xcoord)
        let yycoord = Double(ycoord)
        
        //flag here will determine the query distance?
        //0 = 0.01
        //1 = 0.001
        if(flag == 0){
            return 0.01 <= (abs(xx!-xxcoord!) + abs(yy!-yycoord!))
        }else{
            return 0.001 <= (abs(xx!-xxcoord!) + abs(yy!-yycoord!))
        }
    }
    
    func ManHanDistDouble(_ x:String, y:String, xcoord:String, ycoord:String, flag:Int) -> Double {
        let xx = Double(x)
        let yy = Double(y)
        
        let xxcoord = Double(xcoord)
        let yycoord = Double(ycoord)
        
        //flag here will determine the query distance?
        //0 = 0.01
        //1 = 0.001
        if(flag == 0){
            return (abs(xx!-xxcoord!) + abs(yy!-yycoord!))
        }else{
            return (abs(xx!-xxcoord!) + abs(yy!-yycoord!))
        }
        
        
        //return (abs(from.x - to.x) + abs(from.y - to.y));
    }
    
    // 1.0 = 111km
    // 0.1 = 11.1 km
    // 0.01 = 1.1km
    // 0.001 = 110 m
    // 0.0001 = 11 m
    //probably will be workin in between like 1.1 km and 110 m, so difference of 0.01 and 0.001
    func queryRanges(){
        
        if(self.coords != "gwang"){
            for ren in rendezes{
                let arr = ren.location.components(separatedBy: " : ")
                let xcoord = arr[0]
                let ycoord = arr[1]
                if( ManHanDist( self.x,y: self.y, xcoord: xcoord,ycoord: ycoord,flag: self.rangeflag)){
                    let i = ManHanDistDouble( self.x,y: self.y, xcoord: xcoord,ycoord: ycoord,flag: flag)
                    //calculate its distance and set the current arraysize as the count with the
                    //distance as the value, allowing the index at which it was appended to be saved
                    finalarrInd[finalarr.count] = i
                    finalarr.append(ren)

                }
            }
            
            //statues manhattan calculations
            for stat in statuses{
                let arr = stat.location.components(separatedBy: " : ")
                let xcoord = arr[0]
                let ycoord = arr[1]
                if( ManHanDist( self.x,y: self.y, xcoord: xcoord,ycoord: ycoord,flag: self.rangeflag)){
                    let i = ManHanDistDouble( self.x,y: self.y, xcoord: xcoord,ycoord: ycoord,flag: flag)
                    //calculate its distance and set the current arraysize as the count with the
                    //distance as the value, allowing the index at which it was appended to be saved
                    finalarrInd[finalarr.count] = i
                    finalarr.append(stat)

                }
            }
            
            //sort according to the manhattan distances
            finalarrInd.sorted{
                return $0.1 < $1.1
            }
            
            //add all the indexes in their newly sorted order according to their distances
            for x in finalarrInd{
                 finalInd.append(x.0)
            }

            //then refresh the tables
        }
    
    
    
    }
    
    @IBAction func onRangeOption(_ sender: UIButton) {
        var settingflag = -1
        var msg = "What is the distances you would like to see Rendezes?"
        if(rangeflag == 0){
            msg += " \nCurrent range is 100 meters!"
        }else{
            msg += " \nCurrent range is 2 miles!"
        }
        let alert = UIAlertController(title: "Select a range below!", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "100 meters", style: UIAlertActionStyle.default, handler: { action in
            if( self.rangeflag != 0 ){
                self.rangeflag = 0
                self.queryRanges()
                self.tableVie.reloadData()

            }
            
        }))
        alert.addAction(UIAlertAction(title: "2 miles", style: UIAlertActionStyle.default, handler: { action in
            if( self.rangeflag != 1 ){
                self.rangeflag = 1
                self.queryRanges()
                self.tableVie.reloadData()

            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    /*
    The units digit (one decimal degree) gives a position up to 111 kilometers (60 nautical miles, about 69 miles). It can tell us roughly what large state or country we are in.
    
    The first decimal place is worth up to 11.1 km: it can distinguish the position of one large city from a neighboring large city.
    
    The second decimal place is worth up to 1.1 km: it can separate one village from the next.
    
    The third decimal place is worth up to 110 m: it can identify a large agricultural field or institutional campus.
    
    The fourth decimal place is worth up to 11 m: it can identify a parcel of land. It is comparable to the typical accuracy of an uncorrected GPS unit with no interference.
    
    The fifth decimal place is worth up to 1.1 m: it distinguish trees from each other. Accuracy to this level with commercial GPS units can only be achieved with differential correction.
    
    The sixth decimal place is worth up to 0.11 m: you can use this for laying out structures in detail, for designing landscapes, building roads. It should be more than good enough for tracking movements of glaciers and rivers. This can be achieved by taking painstaking measures with GPS, such as differentially corrected GPS.
    
    */

    func fireOffRange(_ id:Int, flag:Int){
        let prefs:UserDefaults = UserDefaults.standard
        
        let username:String = prefs.value(forKey: "USERNAME") as! String
        let post:NSString = "id=\(id)&username=\(username)&flag=\(flag)" as NSString
        NSLog("PostData: %@",post);
        //random shit needed for the http request
        let url:URL = URL(string: "http://www.jjkbashlord.com/onInRangeUpdate.php")!
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
                //WE ARE IN THE PROMISED LAND
                print("shboozy")
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sent!"
                alertView.message = "Now they know you were nearby!  Creep."
                alertView.delegate = self
                alertView.addButton(withTitle: "OK")
                alertView.show()
                
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

}
