//
//  showRMap.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 9/1/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit
import GoogleMaps


class showRMap: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate,UITableViewDelegate, UITableViewDataSource {
    var someInts = [FromLocation]()

    
    @IBOutlet weak var tableView: UITableView!
    var name:String!
    var coords: String!
    var coordss: [String]!
    var title1: String!
    var detail: String!
    var mapView: GMSMapView!
    
    var flag:Int = -1;
    
    let locationManager = CLLocationManager()
    var destinationLat: String!
    var destinationLong: String!

    
        var manager: OneShotLocationManager?

    @IBOutlet weak var directions: UIButton!
    
    
    @IBOutlet weak var backButton: UIButton!
    
    var gflag:Int!//GROUP FLAG
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if(flag == -1){
            //  because of my terrible foresight on this matter as well
            //  as totally forgetting to patch this up, have the flag to see which
            //  sort of showRMap im doing (the ones with friends and whatnot, or
            //  the one where one just wants to see the location of a particular
            //  status rendez)
            print(name)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        var c:[FromLocation] = [FromLocation()]
        
        if(gflag != -1){
            
            let group = delegate.getGroup(name)
            
            self.someInts.removeAll()
            self.someInts.append(contentsOf: c)
            for mem in group.members{
                self.someInts.insert((FromLocation(username: mem.username, id: mem.username, location: mem.location, time: Date())), at: 0)
            }
            //self.someInts.insert((FromLocation(username: title1, id: title1, location: coords, time: NSDate())), atIndex: 0)
            self.tableView.reloadData()
            
            if(self.someInts.count == 0 || self.someInts[0].location.isEmpty){
                 let alert = UIAlertController(title: "You were not sent a location!", message: "Your friend has never sent you a location.  Loser.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Admit Defeat.", style: UIAlertActionStyle.cancel, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
                //self.dismissViewControllerAnimated(true, completion: nil)
            }else{
            print(self.someInts[0].location)
            var coordsArray = self.someInts[0].location.components(separatedBy: " : ")
            let lat = (coordsArray[0] as NSString).doubleValue
            let long = (coordsArray[1] as NSString).doubleValue
            
            let camera = GMSCameraPosition.camera(withLatitude: lat,
                longitude: long, zoom: 14)
            mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            mapView.isMyLocationEnabled = true
            self.view = mapView
            mapView.delegate = self
            self.view.addSubview(directions)
            self.view.addSubview(backButton)
            self.view.addSubview(tableView)
            
            if let mylocation = mapView.myLocation{
                NSLog("User's location: %@", mylocation)
            } else {
                NSLog("User's location is unknown")
            }
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(lat , long)
            marker.title = title
            marker.snippet = detail
            marker.map = mapView
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
            
            for i in 0..<c.count{
                let marker = GMSMarker()
                var coor = c[i].location
                if(coor != "gwang"){
                    var coordsArray = coor.components(separatedBy: " : ")
                    print("coor ->>>>> " + coor)
                    let lat = (coordsArray[0] as NSString).doubleValue
                    let long = (coordsArray[1] as NSString).doubleValue
                    marker.position = CLLocationCoordinate2DMake(lat , long)
                    marker.title = c[i].username
                    marker.snippet = "at " + dateFormatter.string(from: c[i].time as Date)
                    marker.map = mapView
                }
                }
            }
        }
        else{
            if let a = delegate.yourLocs[name]{
                c = delegate.yourLocs[name]!
            }
        
            self.someInts.removeAll()
            self.someInts.append(contentsOf: c)
            self.someInts.insert((FromLocation(username: title1, id: title1, location: coords, time: Date()))
, at: 0)
            self.tableView.reloadData()
            var coordsArray = coords.components(separatedBy: " : ")
            let lat = (coordsArray[0] as NSString).doubleValue
            let long = (coordsArray[1] as NSString).doubleValue
        
            let camera = GMSCameraPosition.camera(withLatitude: lat,
            longitude: long, zoom: 14)
            mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            mapView.isMyLocationEnabled = true
            self.view = mapView
            mapView.delegate = self
            self.view.addSubview(directions)
            self.view.addSubview(backButton)
            self.view.addSubview(tableView)
        
            if let mylocation = mapView.myLocation{
                NSLog("User's location: %@", mylocation)
            } else {
                NSLog("User's location is unknown")
            }
        
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(lat , long)
            marker.title = title
            marker.snippet = detail
            marker.map = mapView
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        
            for i in 0..<c.count{
                let marker = GMSMarker()
                var coor = c[i].location
                if(coor != "gwang"){
                    var coordsArray = coor.components(separatedBy: " : ")
                    print("coor ->>>>> " + coor)
                    let lat = (coordsArray[0] as NSString).doubleValue
                    let long = (coordsArray[1] as NSString).doubleValue
                    marker.position = CLLocationCoordinate2DMake(lat , long)
                    marker.title = c[i].username
                    marker.snippet = "at " + dateFormatter.string(from: c[i].time as Date)
                    marker.map = mapView
                }
            }
            }
        }else{
            var coordsArray = coords.components(separatedBy: " : ")
            let lat = (coordsArray[0] as NSString).doubleValue
            let long = (coordsArray[1] as NSString).doubleValue
            
            let camera = GMSCameraPosition.camera(withLatitude: lat,
                longitude: long, zoom: 14)
            mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            mapView.isMyLocationEnabled = true
            self.view = mapView
            
            mapView.delegate = self
            self.view.addSubview(directions)
            self.view.addSubview(backButton)
            self.view.addSubview(tableView)
            
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(lat , long)
            marker.title = title
            marker.snippet = detail
            marker.map = mapView
        
        }
    }
    
    @IBAction func getDirections(_ sender: UIButton) {
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                print(location)
                let lat: Double = loc.coordinate.latitude
                let long: Double = loc.coordinate.longitude
                let coords1 = (NSString(format:"%f", lat) as String) + "," + (NSString(format:"%f", long) as String)

                var coordsArray = self.coords.components(separatedBy: " : ")
                let latt = coordsArray[0] as NSString
                let longg = coordsArray[1] as NSString
                let daddr = (latt as String) + "," + (longg as String)
                
                if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                    UIApplication.shared.openURL(URL(string:
                        "comgooglemaps://?saddr=\(coords1)&daddr=\(daddr)&center=37.422185,-122.083898&zoom=5")!)
                    print("Somehigwvwvwr")
                } else {
                    NSLog("Can't use comgooglemaps://");
                }

            } else if let err = error {
                print(err.localizedDescription)
            }
            self.manager = nil
        }
    }

    @IBAction func onBackTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    

    func numberOfSections(in tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return self.someInts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let name:String = self.someInts[indexPath.row].username
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        cell.textLabel!.text = name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)
        var coordsArray = self.someInts[indexPath.row].location.components(separatedBy: " : ")
        if(coordsArray.count < 2){
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Location has not been pinged!"
            alertView.message = self.someInts[indexPath.row].username + " has not pinged their location!"
            alertView.delegate = self
            alertView.addButton(withTitle: "OK")
            alertView.show()
        }else{
            let lat = (coordsArray[0] as NSString).doubleValue
            let long = (coordsArray[1] as NSString).doubleValue
            mapView.animate(toLocation: CLLocationCoordinate2D(latitude: lat,longitude: long))
        }
    }
    
    
    
}




