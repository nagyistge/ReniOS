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
    fileprivate class func query(_ parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sorted(by: <) {
            let value: AnyObject! = parameters[key]
            components += [(escape(key), escape("\(value)"))]
        }
        
        return (components.map{"\($0)=\($1)"} as [String]).joined(separator: "&")
    }
    
    fileprivate class func escape(_ string: String) -> String {
        let legalURLCharactersToBeEscaped: CFString = ":/?&=;+!@#$()',*" as CFString
        return CFURLCreateStringByAddingPercentEscapes(nil, string as CFString!, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
    
    open class func doRequest(_ url: String, params: [String: String], success: @escaping (NSDictionary) -> ()) {
        let request = NSMutableURLRequest(
            url: URL(string: "\(url)?\(query(params as [String : AnyObject]))")!
        )
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            self.handleResponse(data, response: response as? , error: error, success: success)
        }) 
        
        task.resume()
    }
    
    fileprivate class func handleResponse(_ data: Data!, response: HTTPURLResponse!, error: NSError!, success: @escaping (NSDictionary) -> ()) {
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
                json = try JSONSerialization.jsonObject(
                with: data,
                options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        
  
            
                if let status = json["status"] as? String {
                    if status != "OK" {
                        print("GoogleDirections API Error: \(status)")
                        return
                    }
            }
        
            // Perform table updates on UI thread
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
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
