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
        placeType: .address
    )
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "newRsearched") as! newRsearched
       // gpaViewController.placeDelegate = self
       // presentViewController(gpaViewController, animated: true, completion: nil)
    }
    

    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        gpaViewController.placeDelegate = self
       present(gpaViewController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension autoCompleteR: GooglePlacesAutocompleteDelegate {
    
    func placeSelected(_ place: Place) {
        print(place.description)
        stringDetails = place.description


        self.dismiss(animated: false, completion: nil)
        place.getDetails{ details in
            let lat = details.latitude
            let long = details.longitude
            let coords: String = String(format:"%f", lat)+" : "+String(format:"%f", long)
            self.vc.location = coords
            
            
        }
        vc.programVar = stringDetails

        self.present(vc, animated: true, completion: nil)

        
        
        
        
        place.getDetails { details in
            print(details)
        }
    }
    
    func placeViewClosed() {
        self.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "goto_mainactivity", sender: self)
    }
    

    
    
    
    
    
    
    
    
    
}
