//
//  GooglePlacesAutocomplete.swift
//  GooglePlacesAutocomplete
//
//  Created by Howard Wilson on 10/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import UIKit

public let ErrorDomain: String! = "GooglePlacesAutocompleteErrorDomain"

public struct LocationBias {
    public let latitude: Double
    public let longitude: Double
    public let radius: Int
    
    public init(latitude: Double = 0, longitude: Double = 0, radius: Int = 20000000) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    public var location: String {
        return "\(latitude),\(longitude)"
    }
}

public enum PlaceType: CustomStringConvertible {
    case All
    case Geocode
    case Address
    case Establishment
    case Regions
    case Cities
    
    public var description : String {
        switch self {
        case .All: return ""
        case .Geocode: return "geocode"
        case .Address: return "address"
        case .Establishment: return "establishment"
        case .Regions: return "(regions)"
        case .Cities: return "(cities)"
        }
    }
}

public class Place: NSObject {
    public let id: String
    public let desc: String
    public var apiKey: String?
    
    override public var description: String {
        get { return desc }
    }
    
    public init(id: String, description: String) {
        self.id = id
        self.desc = description
    }
    
    public convenience init(prediction: [String: AnyObject], apiKey: String?) {
        self.init(
            id: prediction["place_id"] as! String,
            description: prediction["description"] as! String
        )
        
        self.apiKey = apiKey
    }
    
    /**
     Call Google Place Details API to get detailed information for this place
     
     Requires that Place#apiKey be set
     
     - parameter result: Callback on successful completion with detailed place information
     */
    public func getDetails(result: @escaping (PlaceDetails) -> ()) {
        GooglePlaceDetailsRequest(place: self).request(result: result)
    }
}

public class PlaceDetails: CustomStringConvertible {
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let raw: [String: AnyObject]
    
    public init(json: [String: AnyObject]) {
        let result = json["result"] as! [String: AnyObject]
        let geometry = result["geometry"] as! [String: AnyObject]
        let location = geometry["location"] as! [String: AnyObject]
        
        self.name = result["name"] as! String
        self.latitude = location["lat"] as! Double
        self.longitude = location["lng"] as! Double
        self.raw = json
    }
    
    public var description: String {
        return "PlaceDetails: \(name) (\(latitude), \(longitude))"
    }
}

public protocol GooglePlacesAutocompleteDelegate {
    func placesFound(places: [Place])
    func placeSelected(place: Place)
    func placeViewClosed()
}

// MARK: - GooglePlacesAutocomplete
public class GooglePlacesAutocomplete: UINavigationController {
    public var gpaViewController: GooglePlacesAutocompleteContainer!
    public var closeButton: UIBarButtonItem!
    
    // Proxy access to container navigationItem
    public override var navigationItem: UINavigationItem {
        get { return gpaViewController.navigationItem }
    }
    
    public var placeDelegate: GooglePlacesAutocompleteDelegate? {
        get { return gpaViewController.delegate }
        set { gpaViewController.delegate = newValue }
    }
    
    public var locationBias: LocationBias? {
        get { return gpaViewController.locationBias }
        set { gpaViewController.locationBias = newValue }
    }
    
    public convenience init(apiKey: String, placeType: PlaceType = .All) {
        let gpaViewController = GooglePlacesAutocompleteContainer(
            apiKey: apiKey,
            placeType: placeType
        )
        
        self.init(rootViewController: gpaViewController)
        self.gpaViewController = gpaViewController
        
        closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(GooglePlacesAutocomplete.close))
        closeButton.style = UIBarButtonItemStyle.done
        
        gpaViewController.navigationItem.leftBarButtonItem = closeButton
        gpaViewController.navigationItem.title = "Enter Address"
    }
    
    func close() {
        placeDelegate?.placeViewClosed()
    }
    
    public func reset() {
        gpaViewController.searchBar.text = ""
        
        //gpaViewController.searchBar(searchBar: gpaViewController.searchBar, textDidChange: "")

    }
}

// MARK: - GooglePlacesAutocompleteContainer
public class GooglePlacesAutocompleteContainer: UIViewController {
    @IBOutlet public weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var delegate: GooglePlacesAutocompleteDelegate?
    var apiKey: String?
    var places = [Place]()
    var placeType: PlaceType = .All
    var locationBias: LocationBias?
    
    convenience init(apiKey: String, placeType: PlaceType = .All) {
        let bundle = Bundle(for: GooglePlacesAutocompleteContainer.self)
        
        self.init(nibName: "GooglePlacesAutocomplete", bundle: bundle)
        self.apiKey = apiKey
        self.placeType = placeType
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func viewWillLayoutSubviews() {
        topConstraint.constant = topLayoutGuide.length
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        print("GooglePlacesAutocompleteContainer::  viewDidLoad()")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func keyboardWasShown(_ notification: NSNotification) {
        if isViewLoaded && view.window != nil {
            let info: Dictionary = notification.userInfo!
            let keyboardSize: CGSize = ((info[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size)
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
            
            tableView.contentInset = contentInsets;
            tableView.scrollIndicatorInsets = contentInsets;
        }
    }
    
    func keyboardWillBeHidden(_ notification: NSNotification) {
        if isViewLoaded && view.window != nil {
            self.tableView.contentInset = UIEdgeInsets.zero
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
    }
}

// MARK: - GooglePlacesAutocompleteContainer (UITableViewDataSource / UITableViewDelegate)
extension GooglePlacesAutocompleteContainer: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        // Get the corresponding candy from our candies array
        let place = self.places[indexPath.row]
        
        // Configure the cell
        cell.textLabel!.text = place.description
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.placeSelected(place: self.places[indexPath.row])
    }
}

// MARK: - GooglePlacesAutocompleteContainer (UISearchBarDelegate)
extension GooglePlacesAutocompleteContainer: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            self.places = []
            tableView.isHidden = true
        } else {
            print("searchBar getPlaces() called")
            getPlaces(searchString: searchText)
        }
    }
    
    /**
     Call the Google Places API and update the view with results.
     - parameter searchString: The search query
     */
    
    private func getPlaces(searchString: String) {
        var params = [
            "key": apiKey ?? "",
            "input": searchString,
            "types": placeType.description
        ]
        print("GooglePlacesAutoComplete:: getPlaces(): params ", params)
        
        if let bias = locationBias {
            params["location"] = bias.location
            params["radius"] = bias.radius.description
        }
        
        if (searchString == ""){
            return
        }
        
        GooglePlacesRequestHelpers.doRequest(
            //https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Vict&types=geocode&language=fr&key=YOUR_API_KEY
            //https://maps.googleapis.com/maps/api/place/textsearch/output?parameters
            //"https://maps.googleapis.com/maps/api/place/autocomplete/json
            url: "https://maps.googleapis.com/maps/api/place/autocomplete/json",
            params: params
        ) { json, error in
            if let json = json{
                if let predictions = json["predictions"] as? Array<[String: AnyObject]> {
                    self.places = predictions.map { (prediction: [String: AnyObject]) -> Place in
                        return Place(prediction: prediction, apiKey: self.apiKey)
                    }
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                    self.delegate?.placesFound(places: self.places)
                }
            }else{
                print("line 289: json error")
            }
        }
    }
}

// MARK: - GooglePlaceDetailsRequest
class GooglePlaceDetailsRequest {
    let place: Place
    
    init(place: Place) {
        self.place = place
    }
    
    func request(result: @escaping (PlaceDetails) -> ()) {
        GooglePlacesRequestHelpers.doRequest(
            url: "https://maps.googleapis.com/maps/api/place/details/json",
            params: [
                "placeid": place.id,
                "key": place.apiKey ?? ""
            ]
        ) { json, error in
            if let json = json as? [String: AnyObject] {
                result(PlaceDetails(json: json))
            }
            if let error = error {
                // TODO: We should probably pass back details of the error
                print("Error fetching google place details: \(error)")
            }
        }
    }
}

// MARK: - GooglePlacesRequestHelpers
class GooglePlacesRequestHelpers {
    /**
     Build a query string from a dictionary
     - parameter parameters: Dictionary of query string parameters
     - returns: The properly escaped query string
     */
    private class func query(parameters: [String: String]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys) {
            let value: String = parameters[key]!
            components += [(escape(string: key), escape(string: "\(value)"))]
        }
        
        let q = (components.map{"\($0)=\($1)"} as [String]).joined(separator: "&")
        print("GooglePlacesRequestHelpers ",q)
        return q
    }
    
    private class func escape(string: String) -> String {
        let legalURLCharactersToBeEscaped: CFString = ":/?&=;+!@#$()',*" as CFString
        return CFURLCreateStringByAddingPercentEscapes(nil, string as CFString!, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
    
    class func doRequest(url: String, params: [String: String], completion: @escaping (NSDictionary?,NSError?) -> ()) {
        let request = NSMutableURLRequest(
            url: NSURL(string: "\(url)?\(query(parameters: params as [String : String]))")! as URL
        )
        print("doRequest URL ", request)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            self.handleResponse(data: data as NSData!, response: response as? HTTPURLResponse, error: error as NSError!, completion: completion)
        }
        
        task.resume()
    }
    
    private class func handleResponse(data: NSData!, response: HTTPURLResponse!, error: NSError!, completion: @escaping (NSDictionary?, NSError?) -> ()) {
        
        // Always return on the main thread...
        let done: ((NSDictionary?, NSError?) -> Void) = {(json, error) in
            DispatchQueue.main.async(execute:
                {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(json,error)
            })
        }
        
        if let error = error {
            print("GooglePlaces Error: \(error.localizedDescription)")
            done(nil,error)
            return
        }
        
        if response == nil {
            print("GooglePlaces Error: No response from API")
            let error = NSError(domain: ErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey:"No response from API"])
            done(nil,error)
            return
        }
        
        if response.statusCode != 200 {
            print("GooglePlaces Error: Invalid status code \(response.statusCode) from API")
            let error = NSError(domain: ErrorDomain, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:"Invalid status code"])
            done(nil,error)
            return
        }
        
        let json: NSDictionary?
        do {
            json = try JSONSerialization.jsonObject(
                with: data as Data,
                options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
        } catch {
            print("Serialisation error")
            let serialisationError = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:"Serialization error"])
            done(nil,serialisationError)
            return
        }
        
        if let status = json?["status"] as? String {
            if status != "OK" {
                print("GooglePlaces API Error: \(status)")
                let error = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:status])
                done(nil,error)
                return
            }
        }
        
        done(json,nil)
        
    }
}
