//
//  autoCompleteR.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/27/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//


import UIKit


class autoCompleteR: UIViewController {
    
    var container:GooglePlacesAutocompleteContainer!
    var stringDetails:String!
    var vc: newRsearched!

    
    
    let gpaViewController = GooglePlacesAutocomplete(
        apiKey: "AIzaSyCC5rs4zMNmKNYOsEIuQ86kY6VBzTU1sZQ",
        placeType: .Address
    )
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewControllerWithIdentifier("newRsearched") as! newRsearched
       // gpaViewController.placeDelegate = self
       // presentViewController(gpaViewController, animated: true, completion: nil)
    }
    

    override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
        gpaViewController.placeDelegate = self
       presentViewController(gpaViewController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension autoCompleteR: GooglePlacesAutocompleteDelegate {
    
    func placeSelected(place: Place) {
        print(place.description)
        stringDetails = place.description


        self.dismissViewControllerAnimated(false, completion: nil)
        place.getDetails{ details in
            let lat = details.latitude
            let long = details.longitude
            let coords: String = String(format:"%f", lat)+" : "+String(format:"%f", long)
            self.vc.location = coords
            
            
        }
        vc.programVar = stringDetails

        self.presentViewController(vc, animated: true, completion: nil)

        
        
        
        
        place.getDetails { details in
            print(details)
        }
    }
    
    func placeViewClosed() {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("goto_mainactivity", sender: self)
    }
    

    
    
    
    
    
    
    
    
    
}