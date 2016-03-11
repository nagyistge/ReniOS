//
//  showRMap.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 9/1/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit
import GoogleMaps


class showRMap: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    var coords: String!
    var title1: String!
    var detail: String!
    var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    var destinationLat: String!
    var destinationLong: String!
    //let googleDirectionsHelper: GoogleDirectionsHelper!
        var manager: OneShotLocationManager?

    @IBOutlet weak var directions: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        




        var coordsArray = coords.componentsSeparatedByString(" : ")
        let lat = (coordsArray[0] as NSString).doubleValue
        let long = (coordsArray[1] as NSString).doubleValue
        
        
        let camera = GMSCameraPosition.cameraWithLatitude(lat,
            longitude: long, zoom: 14)
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        self.view = mapView
        
        mapView.delegate = self
        self.view.addSubview(directions)
        
        
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
    }
    



    
    @IBAction func getDirections(sender: UIButton) {
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                print(location)
                let lat: Double = loc.coordinate.latitude
                let long: Double = loc.coordinate.longitude
                let coords1: NSString = (NSString(format:"%f", lat) as String) + "," + (NSString(format:"%f", long) as String)

 
                var coordsArray = self.coords.componentsSeparatedByString(" : ")
                let latt = coordsArray[0] as NSString
                let longg = coordsArray[1] as NSString
                
                
                let daddr: NSString = (latt as String) + "," + (longg as String)

                
                
                if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
                    UIApplication.sharedApplication().openURL(NSURL(string:
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
    


    
    
    
    
    
    
    
    }




