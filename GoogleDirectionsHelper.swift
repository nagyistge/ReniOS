//
//  GoogleDirectionsHelper.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 9/1/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import Foundation
class GoogleDirectionsHelper{
    /**
    Build a query string from a dictionary
    
    - parameter parameters: Dictionary of query string parameters
    - returns: The properly escaped query string
    */
    private class func query(parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sort(<) {
            let value: AnyObject! = parameters[key]
            components += [(escape(key), escape("\(value)"))]
        }
        
        return (components.map{"\($0)=\($1)"} as [String]).joinWithSeparator("&")
    }
    
    private class func escape(string: String) -> String {
        let legalURLCharactersToBeEscaped: CFStringRef = ":/?&=;+!@#$()',*"
        return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
    
    public class func doRequest(url: String, params: [String: String], success: NSDictionary -> ()) {
        let request = NSMutableURLRequest(
            URL: NSURL(string: "\(url)?\(query(params))")!
        )
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.handleResponse(data, response: response as? NSHTTPURLResponse, error: error, success: success)
        }
        
        task.resume()
    }
    
    private class func handleResponse(data: NSData!, response: NSHTTPURLResponse!, error: NSError!, success: NSDictionary -> ()) {
        if let error = error {
            print("GoogleDirections Error: \(error.localizedDescription)")
            return
        }
        
        if response == nil {
            print("GoogleDirections Error: No response from API")
            return
        }
        
        if response.statusCode != 200 {
            print("GoogleDirections Error: Invalid status code \(response.statusCode) from API")
            return
        }
        
        
        //let serializationError: NSError?
        let json:NSDictionary!
        do{
                json = try NSJSONSerialization.JSONObjectWithData(
                data,
                options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        
  
            
                if let status = json["status"] as? String {
                    if status != "OK" {
                        print("GoogleDirections API Error: \(status)")
                        return
                    }
            }
        
            // Perform table updates on UI thread
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
                success(json)
            })
        }catch let error as NSError {
            print("GooglePlaces Error: \(error.localizedDescription)")
            return
        }catch{
            print("SOMETHING ELSE HAPPENED, OKAY SWIFT 2.  SOME SORT OF ERROR")
        }
    }
}
