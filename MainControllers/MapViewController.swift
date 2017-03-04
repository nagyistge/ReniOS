//
//  MapViewController.swift
//  Feed Me
//
//  Created by Ron Kliffer on 8/30/14.
//  Copyright (c) 2014 Ron Kliffer. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController,  CLLocationManagerDelegate, GMSMapViewDelegate
{
    @IBOutlet weak var rendezButton: UIButton!
    @IBOutlet weak var autocompleteR: UIButton!
    @IBOutlet weak var nearbyR: UIButton!
    var addressLabel: UILabel!
   // @IBOutlet weak var mapview: MKMapView!
    var mapView: GMSMapView!
    @IBOutlet weak var mapCenterPinImage: UIImageView!
    var pinImageVerticalConstraint: NSLayoutConstraint!
    var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]

     let locationManager = CLLocationManager()
    //var mapRadius: Double!
    var mapRadius: Double!
    let dataProvider = GoogleDataProvider()
    var nearbyPlaces: CLLocationCoordinate2D!
    let transitionOperator = TransitionOperator()
    let prefs:UserDefaults = UserDefaults.standard
    var username:String!// = prefs.valueForKey("USERNAME") as! String
    var mainMarker: GMSMarker!
    var toViewController:mapRendez!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    username = prefs.value(forKey: "USERNAME") as! String
    NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.refreshMap(_:)), name:NSNotification.Name(rawValue: "refresh"), object: nil)
    // Do any additional setup after loading the view, typically from a nib.
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    let camera = GMSCameraPosition.camera(withLatitude: -33.868,
        longitude:151.2086, zoom:6)
    mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height-85),     camera:camera)
    mapView.settings.scrollGestures = true
    mapView.settings.zoomGestures = true
    let region = mapView.projection.visibleRegion()
    let verticalDistance = GMSGeometryDistance(region.farLeft, region.nearLeft)
    let horizontalDistance = GMSGeometryDistance(region.farLeft, region.farRight)
    self.mapRadius = max(horizontalDistance, verticalDistance)*0.5
    
    mapView.delegate = self

    
    
    self.view = mapView
    mapCenterPinImage.center =  CGPoint(x: self.mapView.frame.size.width  / 2,
        y: (self.mapView.frame.size.height / 2)-30);
    self.view.addSubview(mapCenterPinImage)
    addressLabel.center =  CGPoint(x: (self.view.frame.size.width  / 2)+15,
        y: self.view.frame.size.height - 25);
    self.view.addSubview(addressLabel)
    autocompleteR.center =  CGPoint(x: 50,
        y: self.view.frame.size.height - 25);
    self.view.addSubview(autocompleteR)
    nearbyR.center =  CGPoint(x: self.view.frame.width-30,
        y: self.view.frame.size.height - 25);
    self.view.addSubview(nearbyR)
    rendezButton.center =  CGPoint(x: self.view.frame.width-30,
        y: 25);
    self.view.addSubview(rendezButton)

    

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "goto_autocompleteR"
        {
            //let destinationVC = segue.destinationViewController as? autoCompleteR
    }
  }
  

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 2
        if status == .authorizedWhenInUse {
            
            // 3
            locationManager.startUpdatingLocation()
            
            //4
            self.mapView.isMyLocationEnabled = true
            self.mapView.settings.myLocationButton = true
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(locations.first)
            print(location)
            print(location.coordinate.latitude)
            // 6
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 17, bearing: 0, viewingAngle: 0)
            
            // 7
            locationManager.stopUpdatingLocation()
        }
    
    }
    
    
    func refreshMap(_ notification: Notification){
        let chatstatus = notification.object as! RendezStatus
        print("parent method is called")
        print(notification)
        print(chatstatus.title)
        print(chatstatus.username)
        let coords = chatstatus.location.components(separatedBy: " : ")
        let x = (coords[0] as NSString).doubleValue
        let y = (coords[1] as NSString).doubleValue
        
        let position = CLLocationCoordinate2DMake(x, y)
        mainMarker = GMSMarker(position: position)
        mainMarker.title = chatstatus.title as String
        var snippet = "" as String
        if username == chatstatus.username{
            snippet += "Sent From You \r\n"
        }else{
            snippet += "From " + username + "\r\n"
        }
        snippet += chatstatus.details as String
        mainMarker.snippet = snippet
        mainMarker.map = mapView
        mainMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: x,longitude: y ))
        mapView.animate(toZoom: 17)
    }
    
    func mapView(_ mapView: GMSMapView!, idleAt position: GMSCameraPosition!) {
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(_ mapView: GMSMapView!, willMove gesture: Bool) {
        self.addressLabel.lock()
    }
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            self.addressLabel.unlock()
            if response != nil{
            if let address = response?.firstResult() {
                let lines = address.lines as! [String]
                self.addressLabel.text = lines.joined(separator: "\n")
                
                let labelHeight = self.addressLabel.intrinsicContentSize.height
                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.layoutIfNeeded()
                }) 
            }
            }
            else{
            }
    
        }
    }


    @IBAction func autocompleteTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goto_autocompleteR", sender: self)
        //let vc = autoCompleteR()
        //self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func nearbyTapped(_ sender: UIButton) {
        print(self.nearbyPlaces)

        //fetchNearbyPlaces(nearbyPlaces)
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        
        let prefs:UserDefaults = UserDefaults.standard
        let isLoggedIn:Int = prefs.integer(forKey: "ISLOGGEDIN") as Int
        if(isLoggedIn != 1){
            self.dismiss(animated: true, completion: nil)
        }
        
        //self.txtUsername.text = prefs.valueForKey("USERNAME") as? String
        
        
        let username:String = prefs.value(forKey: "USERNAME") as! String
        
        
        let post:NSString = "username=\(username)" as NSString
        
        NSLog("PostData: %@",post);
        
        let url:URL = URL(string: "http://www.jjkbashlord.com/fetchStatus.php")!
        
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
                
           //     var error: NSError?
                
                let jsonData:NSArray = (try! JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers )) as! NSArray
                
                
                for index in 0 ..< jsonData.count{
                    
               //     let username1:NSMutableString = jsonData[index].valueForKey("username") as! NSMutableString
                    if (jsonData[index] as AnyObject).value(forKey: "title") != nil{
                    let title1:NSString = (jsonData[index] as AnyObject).value(forKey: "title") as! NSString
                 //   let detail1:NSMutableString = jsonData[index].valueForKey("detail") as! NSMutableString
                    let location1:String = (jsonData[index] as AnyObject).value(forKey: "location") as! NSMutableString as String
                        let user:String = (jsonData[index] as AnyObject).value(forKey: "username") as! String
                        let detail:String = (jsonData[index] as AnyObject).value(forKey: "detail") as! String
                    
                    var splitcoords = location1.components(separatedBy: " : ")
                        if splitcoords.count > 1{
                    let lat = (splitcoords[0] as NSString).doubleValue
                    let long = (splitcoords[1] as NSString).doubleValue
                    
                    let position = CLLocationCoordinate2DMake(lat, long)
                    let marker = GMSMarker(position: position)
                    marker?.title = title1 as String
                    var snippet = "" as String
                    if user == username{
                        snippet += "Sent From You \r\n"
                    }else{
                        snippet += "From " + user + "\r\n"
                    }
                    snippet += detail
                    marker?.snippet = snippet
                    marker?.map = mapView
                    //marker.map = mapView
                        }
                    }
                }
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
    
    @IBAction func onRendezTapped(_ sender: UIButton) {
        //self.performSegueWithIdentifier("presentNav", sender: self)
        
        toViewController = self.storyboard?.instantiateViewController(withIdentifier: "mapRendez") as! mapRendez
        // toViewController = segue.destinationViewController as! chattingR

        self.modalPresentationStyle = UIModalPresentationStyle.custom
        toViewController.transitioningDelegate = self.transitionOperator
        
        self.present(toViewController, animated: true, completion: nil)
    }

    
}

