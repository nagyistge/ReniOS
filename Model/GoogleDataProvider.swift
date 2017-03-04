//
//  GoogleDataProvider.swift
//  Feed Me
//
//  Created by Ron Kliffer on 8/30/14.
//  Copyright (c) 2014 Ron Kliffer. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class GoogleDataProvider {
  
  let apiKey = "AIzaSyCtZkaftILPjennmNLcm5iiIFatU3Lgglg"
  var photoCache = [String:UIImage]()
  var placesTask = URLSessionDataTask()
  var session: URLSession {
    return URLSession.shared
  }
  
  func fetchPlacesNearCoordinate(_ coordinate: CLLocationCoordinate2D, radius: Double, types:[String], completion: @escaping (([GooglePlace]) -> Void)) -> ()
  {
    var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true&key = \(apiKey)"
    let typesString = types.count > 0 ? types.joined(separator: "|") : "food"
    //urlString += "&types=\(typesString)"
    urlString = urlString.addingPercentEscapes(using: String.Encoding.utf8)!
    
    if placesTask.taskIdentifier > 0 && placesTask.state == .running {
      placesTask.cancel()
    }
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    placesTask = session.dataTask(with: URL(string: urlString)!, completionHandler: {data, response, error in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      var placesArray = [GooglePlace]()
        let err: AutoreleasingUnsafeMutablePointer<NSError?>? = nil
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options:[]) as? NSDictionary

            print(coordinate.latitude)
            print(coordinate.longitude)
            if let results:NSArray = json?.value(forKey: "results") as? NSArray {
                for rawPlace in results {
                    let place = GooglePlace(dictionary: (rawPlace as! NSDictionary) as! [String : AnyObject], acceptedTypes: types)
                    placesArray.append(place)
                    print(place.name)
                    if let reference = place.photoReference {
                        self.fetchPhotoFromReference(reference) { image in
                            place.photo = image
              }
            }
          }
        }
      }
        catch{
            print(err)
        }
      DispatchQueue.main.async {
        completion(placesArray)
      }
    }) 
    placesTask.resume()
  }
  
  
  func fetchDirectionsFrom(_ from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: @escaping ((String?) -> Void)) -> ()
  {
    let urlString = "https://maps.googleapis.com/maps/api/directions/json?key=\(apiKey)&origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&mode=walking"
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    session.dataTask(with: URL(string: urlString)!, completionHandler: {data, response, error in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      var encodedRoute: String?
      if let json = (try? JSONSerialization.jsonObject(with: data!, options:[])) as? [String:AnyObject] {
        print(json["error_message"]!)
        if let routes = json["routes"] as AnyObject? as? [AnyObject] {
          if let route = routes.first as? [String : AnyObject] {
            if let polyline = route["overview_polyline"] as AnyObject? as? [String : String] {
              if let points = polyline["points"] as AnyObject? as? String {
                encodedRoute = points
              }
            }
          }
        }
      }
      DispatchQueue.main.async {
        completion(encodedRoute)
      }
    }) .resume()
  }
  
  
  func fetchPhotoFromReference(_ reference: String, completion: @escaping ((UIImage?) -> Void)) -> ()
  {
    if let photo = photoCache[reference] as UIImage! {
      completion(photo)
    } else {
      let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photoreference=\(reference)&key=\(apiKey)"
      
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      session.downloadTask(with: URL(string: urlString)!, completionHandler: {url, response, error in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let downloadedPhoto = UIImage(data: try! Data(contentsOf: url!))
        self.photoCache[reference] = downloadedPhoto
        DispatchQueue.main.async {
          completion(downloadedPhoto)
        }
      }) .resume()
    }
  }
}
