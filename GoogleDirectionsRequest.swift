//
//  GoogleDirectionsRequest.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 9/1/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import Foundation
class GoogleDirectionsRequest {
    let place: Place
    
    init(place: Place) {
        self.place = place
    }
    
    func request(result: PlaceDetails -> ()) {
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/directions/json",
            params: [
                "orgin": startCoords,
                "&destination": endCoords
            ]
            ) { json in
                result(PlaceDetails(json: json as [String: AnyObject]))
        }
    }
}