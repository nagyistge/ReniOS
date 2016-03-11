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
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var username:String!// = prefs.valueForKey("USERNAME") as! String
    var mainMarker: GMSMarker!
    var toViewController:mapRendez!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    username = prefs.valueForKey("USERNAME") as! String
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshMap:", name:"refresh", object: nil)
    // Do any additional setup after loading the view, typically from a nib.
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    let camera = GMSCameraPosition.cameraWithLatitude(-33.868,
        longitude:151.2086, zoom:6)
    mapView = GMSMapView.mapWithFrame(CGRectMake(0, 0, self.view.frame.width, self.view.frame.size.height-85),     camera:camera)
    mapView.settings.scrollGestures = true
    mapView.settings.zoomGestures = true
    let region = mapView.projection.visibleRegion()
    let verticalDistance = GMSGeometryDistance(region.farLeft, region.nearLeft)
    let horizontalDistance = GMSGeometryDistance(region.farLeft, region.farRight)
    self.mapRadius = max(horizontalDistance, verticalDistance)*0.5
    
    mapView.delegate = self

    
    
    self.view = mapView
    mapCenterPinImage.center =  CGPointMake(self.mapView.frame.size.width  / 2,
        (self.mapView.frame.size.height / 2)-30);
    self.view.addSubview(mapCenterPinImage)
    addressLabel.center =  CGPointMake((self.view.frame.size.width  / 2)+15,
        self.view.frame.size.height - 25);
    self.view.addSubview(addressLabel)
    autocompleteR.center =  CGPointMake(50,
        self.view.frame.size.height - 25);
    self.view.addSubview(autocompleteR)
    nearbyR.center =  CGPointMake(self.view.frame.width-30,
        self.view.frame.size.height - 25);
    self.view.addSubview(nearbyR)
    rendezButton.center =  CGPointMake(self.view.frame.width-30,
        25);
    self.view.addSubview(rendezButton)

    

  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "goto_autocompleteR"
        {
            //let destinationVC = segue.destinationViewController as? autoCompleteR
    }
  }
  

    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // 2
        if status == .AuthorizedWhenInUse {
            
            // 3
            locationManager.startUpdatingLocation()
            
            //4
            self.mapView.myLocationEnabled = true
            self.mapView.settings.myLocationButton = true
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
    
    
    func refreshMap(notification: NSNotification){
        let chatstatus = notification.object as! RendezStatus
        print("parent method is called")
        print(notification)
        print(chatstatus.title)
        print(chatstatus.username)
        let coords = chatstatus.location.componentsSeparatedByString(" : ")
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
        mainMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        mapView.animateToLocation(CLLocationCoordinate2D(latitude: x,longitude: y ))
        mapView.animateToZoom(17)
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        self.addressLabel.lock()
    }
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            self.addressLabel.unlock()
            if response != nil{
            if let address = response.firstResult() {
                let lines = address.lines as! [String]
                self.addressLabel.text = lines.joinWithSeparator("\n")
                
                let labelHeight = self.addressLabel.intrinsicContentSize().height
                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
                UIView.animateWithDuration(0.25) {
                    self.view.layoutIfNeeded()
                }
            }
            }
            else{
            }
    
        }
    }


    @IBAction func autocompleteTapped(sender: UIButton) {
        self.performSegueWithIdentifier("goto_autocompleteR", sender: self)
        //let vc = autoCompleteR()
        //self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func nearbyTapped(sender: UIButton) {
        print(self.nearbyPlaces)

        //fetchNearbyPlaces(nearbyPlaces)
    }

    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if(isLoggedIn != 1){
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        //self.txtUsername.text = prefs.valueForKey("USERNAME") as? String
        
        
        let username:String = prefs.valueForKey("USERNAME") as! String
        
        
        let post:NSString = "username=\(username)"
        
        NSLog("PostData: %@",post);
        
        let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/fetchStatus.php")!
        
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
                
           //     var error: NSError?
                
                let jsonData:NSArray = (try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers )) as! NSArray
                
                
                for(var index = 0; index < jsonData.count; index++ ){
                    
               //     let username1:NSMutableString = jsonData[index].valueForKey("username") as! NSMutableString
                    if jsonData[index].valueForKey("title") != nil{
                    let title1:NSString = jsonData[index].valueForKey("title") as! NSString
                 //   let detail1:NSMutableString = jsonData[index].valueForKey("detail") as! NSMutableString
                    let location1:String = jsonData[index].valueForKey("location") as! NSMutableString as String
                        let user:String = jsonData[index].valueForKey("username") as! String
                        let detail:String = jsonData[index].valueForKey("detail") as! String
                    
                    var splitcoords = location1.componentsSeparatedByString(" : ")
                        if splitcoords.count > 1{
                    let lat = (splitcoords[0] as NSString).doubleValue
                    let long = (splitcoords[1] as NSString).doubleValue
                    
                    let position = CLLocationCoordinate2DMake(lat, long)
                    let marker = GMSMarker(position: position)
                    marker.title = title1 as String
                    var snippet = "" as String
                    if user == username{
                        snippet += "Sent From You \r\n"
                    }else{
                        snippet += "From " + user + "\r\n"
                    }
                    snippet += detail
                    marker.snippet = snippet
                    marker.map = mapView
                        }
                    }
                }
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
    
    @IBAction func onRendezTapped(sender: UIButton) {
        //self.performSegueWithIdentifier("presentNav", sender: self)
        
        toViewController = self.storyboard?.instantiateViewControllerWithIdentifier("mapRendez") as! mapRendez
        // toViewController = segue.destinationViewController as! chattingR

        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        toViewController.transitioningDelegate = self.transitionOperator
        
        self.presentViewController(toViewController, animated: true, completion: nil)
    }

    
}

