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

        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var flag:Int = -1
    
    var rangeflag:Int = 0
    
    var rendezes = [RendezStatus]()
    var statuses = [Status]()
    
    var query_rendezes = [Double : RendezStatus]()
    var q_indexes = [Double]()//damn dictionaries dont allow for indexing..
    var query_statuses = [Double : Status]()
    var q_s_indexes = [Double]()//damn dictionaries dont allow for indexing..
    
    var query_effit = [Double:AnyObject]()
    var q_effit = [Double]()
    var finalarr = [AnyObject]()
    var finalarrInd = [Int:Double]()//array for holding indexes as well as manhattan dist vals
    
    var finalInd = [Int]()
    
    let locationManager = CLLocationManager()
    var manager: OneShotLocationManager = OneShotLocationManager()
    var coords:String = "gwang"
    var x:String = "x"
    var y:String = "y"
    
    
        override func viewDidLoad() {
            super.viewDidLoad()
            self.tableVie.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

             locationManager.delegate = self
            
        }
        
        override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(true)

        }
        
        override func viewDidAppear(animated: Bool) {
            super.viewDidAppear(true)
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
                }
            }
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
            //return query_effit.count
            //return query_rendezes.count + query_statuses.count
            return finalarr.count
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableVie.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            if let rr = finalarr[finalInd[indexPath.row]] as? RendezStatus{
                let r = finalarr[finalInd[indexPath.row]] as! RendezStatus
                cell.textLabel?.text = r.title + " is " + String(finalarrInd[finalInd[indexPath.row]]!) + " m away!"
            }else{
                let r = finalarr[finalInd[indexPath.row]] as! Status
                 //cell.textLabel?.text = r!.title + " " + r!.username + " " + r!.timeset
                cell.textLabel?.text = r.title + " is " + String(finalarrInd[finalInd[indexPath.row]]!) + " m away!"
            }
            return cell
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        
        @IBAction func backTapped(sender: UIButton) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    
    func ManHanDist(x:String, y:String, xcoord:String, ycoord:String, flag:Int) -> Bool {
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
    
    func ManHanDistDouble(x:String, y:String, xcoord:String, ycoord:String, flag:Int) -> Double {
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
                let arr = ren.location.componentsSeparatedByString(" : ")
                let xcoord = arr[0]
                let ycoord = arr[1]
                if( ManHanDist( self.x,y: self.y, xcoord: xcoord,ycoord: ycoord,flag: self.rangeflag)){
                    let i = ManHanDistDouble( self.x,y: self.y, xcoord: xcoord,ycoord: ycoord,flag: flag)
                    query_rendezes[i] = ren
                     query_effit[i] = ren
                    
                    finalarrInd[finalarr.count] = i
                    finalarr.append(ren)
                    //q_indexes.append(i)
                }
            }
            query_rendezes.sort{
                return $0.0 < $1.0
            }
            for x in query_rendezes{
                q_indexes.append(x.0)
            }
            
            //statues manhattan calculations
            for stat in statuses{
                let arr = stat.location.componentsSeparatedByString(" : ")
                let xcoord = arr[0]
                let ycoord = arr[1]
                if( ManHanDist( self.x,y: self.y, xcoord: xcoord,ycoord: ycoord,flag: self.rangeflag)){
                    let i = ManHanDistDouble( self.x,y: self.y, xcoord: xcoord,ycoord: ycoord,flag: flag)
                    query_statuses[i] = stat
                    query_effit[i] = stat
                    
                    finalarrInd[finalarr.count] = i
                    finalarr.append(stat)
                    
                    //q_indexes.append(i)
                }
            }
            query_statuses.sort{
                return $0.0 < $1.0
            }
            for x in query_statuses{
                q_s_indexes.append(x.0)
            }
            
            
            query_effit.sort{
                return $0.0 < $1.0
            }
            for x in query_effit{
                q_effit.append(x.0)
            }
            
            finalarrInd.sort{
                return $0.1 < $1.1
            }
            
            for x in finalarrInd{
                 finalInd.append(x.0)
            }
            
           
            
            print("query_effit size " + String(query_effit.count))
             print("total q size " + String(query_statuses.count + query_rendezes.count ))
            print("total size " + String(statuses.count + rendezes.count ))
            print(self.coords)
            
        }
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

        

}