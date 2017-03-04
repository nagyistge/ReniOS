//
//  PlacePickerViewController.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/29/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit
import GoogleMaps

class PlacePickerViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var placeCoordiantes: UILabel!
    @IBOutlet weak var placeDetails: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var attributionTextView: UITextView!
    var manager: OneShotLocationManager?
    var coords: String!
    
    var placePicker: GMSPlacePicker?
    var VIEWPORT_LATLNG: CLLocationCoordinate2D!
    let VIEWPORT_DELTA = 0.001
    var vc:newRsearched!

    override func viewDidLoad() {
        super.viewDidLoad()
           // Do any additional setup after loading the view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "newRsearched") as! newRsearched
        
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                print(location)
                let lat: Double = loc.coordinate.latitude
                let long: Double = loc.coordinate.longitude
                var coords: String = String(format:"%f", lat)+" : "+String(format:"%f", long)

                self.VIEWPORT_LATLNG = CLLocationCoordinate2DMake(lat, long)
                
            } else if let err = error {
                print(err.localizedDescription)
            }
            self.manager = nil
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func pickPlace(_ sender: UIButton) {
        let northEast = CLLocationCoordinate2DMake(VIEWPORT_LATLNG.latitude + VIEWPORT_DELTA, VIEWPORT_LATLNG.longitude + VIEWPORT_DELTA)
        let southWest = CLLocationCoordinate2DMake(VIEWPORT_LATLNG.latitude - VIEWPORT_DELTA, VIEWPORT_LATLNG.longitude - VIEWPORT_DELTA)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        
        
        placePicker?.pickPlace(callback: { (place: GMSPlace?,error: NSError?) -> Void in
            self.nameLabel.text = ""
            if error != nil {
                self.nameLabel.text = error?.localizedDescription
                return
            }
            
            if let place = place {
                self.nameLabel.text = place.name
                self.addressLabel.text = place.formattedAddress.components(separatedBy: ", ").joined(separator: "\n")
                self.placeDetails.text = place.types.description
                self.placeCoordiantes.text = "Latitude: Longitude = \n" + String(format:"%f",place.coordinate.latitude) + ": " + String(format:"%f", place.coordinate.longitude)
                self.coords = String(format:"%f",place.coordinate.latitude) + " : " + String(format:"%f", place.coordinate.longitude)

                
                
            } else {
                self.nameLabel.text = "No place selected"
                self.addressLabel.text = ""
                self.placeDetails.text = ""
                self.placeCoordiantes.text = ""

            }
        } as! GMSPlaceResultCallback)
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL,
        in characterRange: NSRange) -> Bool {
            // Make links clickable.
            return true
    }
    
    
    
    
    
    @IBAction func newNearbyRTapped(_ sender: UIButton) {
        self.vc.programVar = self.addressLabel.text
        self.vc.location = self.coords
        self.present(vc, animated: true, completion: nil)

        
    }
    
 
    @IBAction func onBackTapped(_ sender: UIButton) {
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
