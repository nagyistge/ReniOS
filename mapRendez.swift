//
//  chattingR.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 9/2/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

class mapRendez: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource,CustomCellDelegate {
    //usernames

    var friendname: String!
    //display names
    var showuser: String!
    var showfriend: String!
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var friendLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtChatBox: UITextField!
    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let transitionOperator = TransitionOperator()
    
    @IBOutlet weak var customCell: UITableViewCell!
    
    
    var cellDescriptors: NSMutableArray = NSMutableArray()
    
    var visibleRowsPerSection = [[Int]]()
    
    
    var messagesArray = [ChatStatus]()
    
    var someInts = [Friend]()
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var username:String!// = prefs.valueForKey("USERNAME") as! String
    var someFriendInts = [RendezStatus]()

        
        // MARK: IBOutlet Properties
        
        @IBOutlet weak var tblExpandable: UITableView!
        
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        username = prefs.valueForKey("USERNAME") as! String
        //tableView
        
        //NSNOTIFICATION OBSERVER INITILIZER
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFriendNotif:", name: FriendActivityNotifKey, object: nil)
        if false{
            //init param for the initial list from msqli~~~~~~~~~~~~~~~~~~~~
            let username:String = prefs.valueForKey("USERNAME") as! String
            let post:NSString = "username=\(username)"
            NSLog("PostData: %@",post);
            //random shit needed for the http request
            let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/fetchRendezChatNotifChecker.php")!
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
                    let jsonData:NSArray = (try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers )) as! NSArray
                    for(var index = 0; index < jsonData.count; index++ ){
                        
                        
                        let username1:NSString = jsonData[index].valueForKey("username") as! NSString
                        let title1:NSString = jsonData[index].valueForKey("showname") as! NSString
                        var detail1:String = jsonData[index].valueForKey("timestamp") as! NSString as String
                        
                        if (detail1.characters.count < 18){
                            detail1 += ":00"
                        }
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date = dateFormatter.dateFromString(detail1 as String)
                        
                        print("Initial friendlist fetch for " + (username1 as String) + "\n")
                        print("showname: " + (title1 as String) + "\n")
                        print("date: " + (date?.description)! + "\n")
                        
                        
                        let status = Friend(username: username1 as String, showname: title1 as String, timestamp: date!)
                        someInts.append(status)
                    }
                    //self.delegate.loadFriends(someInts)
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
        }else{
            
        }
            // Do any additional setup after loading the view, typically from a nib.
        }
        
        
        override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
            self.someInts.removeAll()
            self.someInts.appendContentsOf(self.delegate.theNotifHelper.returnFriendNotif())
            print(someInts)
            //self.tableView.reloadData()
            configureTableView()
            
            loadCellDescriptors()
            print(cellDescriptors)
        }
        
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        // MARK: Custom Functions
        
        func configureTableView() {
            tblExpandable.delegate = self
            tblExpandable.dataSource = self
            tblExpandable.tableFooterView = UIView(frame: CGRectZero)
            
            tblExpandable.registerNib(UINib(nibName: "NormalCell", bundle: nil), forCellReuseIdentifier: "idCellNormal")
            tblExpandable.registerNib(UINib(nibName: "TextfieldCell", bundle: nil), forCellReuseIdentifier: "idCellTextfield")
            tblExpandable.registerNib(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "idCellDatePicker")
            tblExpandable.registerNib(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "idCellSwitch")
            tblExpandable.registerNib(UINib(nibName: "ValuePickerCell", bundle: nil), forCellReuseIdentifier: "idCellValuePicker")
            tblExpandable.registerNib(UINib(nibName: "SliderCell", bundle: nil), forCellReuseIdentifier: "idCellSlider")
        }
        
        
        func loadCellDescriptors() {


                let celler = NSMutableArray()
                for x in self.someInts{
                    if(!(delegate.isTheFriendInTheWoz(x.username))){
                        //not only does this store the chat in theWoz but also returns the rendezchatdictionary
                        let niceToMeetYou:rendezChatDictionary = delegate.makeFriendsWithWoz(username, friendname: x.username)
                        someFriendInts.appendContentsOf(niceToMeetYou.allDeesRendez)
                        print("they had to be introduced first but it is gucci meng now")
                        
                    }
                    else{ //the chat of that friend exists already, so lets just get it from theWozMap and make the lists
                        let statuslist = delegate.theWozMap[x.username]!
                        let rendez = statuslist.allDeesRendez
                        someFriendInts += rendez
                        NSLog("\n THE CHAT HAS RETRIEVED THE STATIC LIST FROM THE WOZ")
                    }
                    
                    let cell:NSMutableDictionary = ["isExpandable": true, "isExpanded": false, "isVisible": true, "value": "", "primaryTitle": "", "secondaryTitle": x.username, "cellIdentifier": "idCellNormal", "additionalRows": someFriendInts.count]
                    celler.addObject(cell)
                    
                    for y in someFriendInts{
                        if y.username == username{
                            let z = "From " + (y.username as String)
                        let fcell:NSMutableDictionary = ["isExpandable": false, "isExpanded": false, "isVisible": false, "value": "", "primaryTitle": y.title, "secondaryTitle": z, "cellIdentifier": "idCellNormal", "additionalRows": 0, "id": y.id]
                        celler.addObject(fcell)
                        }else{
                            let z = "To " + (y.username as String)
                            let fcell:NSMutableDictionary = ["isExpandable": false, "isExpanded": false, "isVisible": false, "value": "", "primaryTitle": y.title, "secondaryTitle": z, "cellIdentifier": "idCellNormal", "additionalRows": 0, "id": y.id]
                            celler.addObject(fcell)
                        }
                    }
                }
                cellDescriptors.addObject(celler)
            if(!someInts.isEmpty){
                getIndicesOfVisibleRows()
            }
                tblExpandable.reloadData()
            
        }
        
        
        func getIndicesOfVisibleRows() {
            visibleRowsPerSection.removeAll()
            
            //print(cellDescriptors)
            for currentSectionCells in cellDescriptors {
                var visibleRows = [Int]()
                for row in 0...((currentSectionCells as! [[String: AnyObject]]).count - 1) {
                    if let v = currentSectionCells[row]["isVisible"]as? Bool {
                        if v == true {
                            visibleRows.append(row)
                        }
                    }else{
                    }
                }
                visibleRowsPerSection.append(visibleRows)
            }
        }
        
        
        func getCellDescriptorForIndexPath(indexPath: NSIndexPath) -> [String: AnyObject] {
            let indexOfVisibleRow = visibleRowsPerSection[indexPath.section][indexPath.row]
            let cellDescriptor = cellDescriptors[indexPath.section][indexOfVisibleRow] as! [String: AnyObject]
            return cellDescriptor
        }
        
        
        // MARK: UITableView Delegate and Datasource Functions
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            if cellDescriptors.count != 0 {
                return cellDescriptors.count
            }
            else {
                return 0
            }
        }
        
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if(!visibleRowsPerSection.isEmpty){
                return visibleRowsPerSection[section].count
            }else{
                return 0
            }
    }
        
        
        func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            
            switch section {
            case 0:
                return "Friends"
                
            case 1:
                return "Groups"
                
            default:
                return "News Feed"
            }
        }
        
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath)
            let cell = tableView.dequeueReusableCellWithIdentifier(currentCellDescriptor["cellIdentifier"] as! String, forIndexPath: indexPath) as! CustomCell
            
            if currentCellDescriptor["cellIdentifier"] as! String == "idCellNormal" {
                if let primaryTitle = currentCellDescriptor["primaryTitle"] {
                    cell.textLabel?.text = primaryTitle as? String
                }
                
                if let secondaryTitle = currentCellDescriptor["secondaryTitle"] {
                    cell.detailTextLabel?.text = secondaryTitle as? String
                }
            }
            else if currentCellDescriptor["cellIdentifier"] as! String == "idCellTextfield" {
                cell.textField.placeholder = currentCellDescriptor["primaryTitle"] as? String
            }
            else if currentCellDescriptor["cellIdentifier"] as! String == "idCellSwitch" {
                cell.lblSwitchLabel.text = currentCellDescriptor["primaryTitle"] as? String
                
                let value = currentCellDescriptor["value"] as? String
                cell.swMaritalStatus.on = (value == "true") ? true : false
            }
            else if currentCellDescriptor["cellIdentifier"] as! String == "idCellValuePicker" {
                cell.textLabel?.text = currentCellDescriptor["primaryTitle"] as? String
            }
            else if currentCellDescriptor["cellIdentifier"] as! String == "idCellSlider" {
                let value = currentCellDescriptor["value"] as! String
                cell.slExperienceLevel.value = (value as NSString).floatValue
            }
            
            cell.delegate = self
            
            return cell
        }
        
        
        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath)
            
            switch currentCellDescriptor["cellIdentifier"] as! String {
            case "idCellNormal":
                return 60.0
                
            case "idCellDatePicker":
                return 270.0
                
            default:
                return 44.0
            }
        }
        
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let indexOfTappedRow = visibleRowsPerSection[indexPath.section][indexPath.row]
            
            if cellDescriptors[indexPath.section][indexOfTappedRow]["isExpandable"] as! Bool == false && cellDescriptors[indexPath.section][indexOfTappedRow]["primaryTitle"] as! String! != ""{
                //var returnRendezStatus:RendezStatus!
                for x in self.someFriendInts{
                    if x.id == cellDescriptors[indexPath.section][indexOfTappedRow]["id"] as! Int{
                         NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: x)
                    }
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            
            if cellDescriptors[indexPath.section][indexOfTappedRow]["isExpandable"] as! Bool == true {
                var shouldExpandAndShowSubRows = false
                if cellDescriptors[indexPath.section][indexOfTappedRow]["isExpanded"] as! Bool == false {
                    // In this case the cell should expand.
                    shouldExpandAndShowSubRows = true
                }
                print(indexPath.section)
                print(indexOfTappedRow)
                print(cellDescriptors[indexPath.section][indexOfTappedRow])
                cellDescriptors[indexPath.section][indexOfTappedRow]!.setValue(shouldExpandAndShowSubRows, forKeyPath: "isExpanded")//(shouldExpandAndShowSubRows, forKey: "isExpanded")
                print("if this doesnt print this is where it is fuckin up")
                for i in (indexOfTappedRow + 1)...(indexOfTappedRow + (cellDescriptors[indexPath.section][indexOfTappedRow]["additionalRows"] as! Int)) {
                    cellDescriptors[indexPath.section][i].setValue(shouldExpandAndShowSubRows, forKey: "isVisible")
                }
            }
            else {
                if cellDescriptors[indexPath.section][indexOfTappedRow]["cellIdentifier"] as! String == "idCellValuePicker" {
                    var indexOfParentCell: Int!
                    
                    for var i=indexOfTappedRow - 1; i>=0; --i {
                        if cellDescriptors[indexPath.section][i]["isExpandable"] as! Bool == true {
                            indexOfParentCell = i
                            break
                        }
                    }
                    
                    cellDescriptors[indexPath.section][indexOfParentCell].setValue((tblExpandable.cellForRowAtIndexPath(indexPath) as! CustomCell).textLabel?.text, forKey: "primaryTitle")
                    cellDescriptors[indexPath.section][indexOfParentCell].setValue(false, forKey: "isExpanded")
                    
                    for i in (indexOfParentCell + 1)...(indexOfParentCell + (cellDescriptors[indexPath.section][indexOfParentCell]["additionalRows"] as! Int)) {
                        cellDescriptors[indexPath.section][i].setValue(false, forKey: "isVisible")
                    }
                }
            }
            
            getIndicesOfVisibleRows()
            tblExpandable.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        
        // MARK: CustomCellDelegate Functions
        
        func dateWasSelected(selectedDateString: String) {
            let dateCellSection = 0
            let dateCellRow = 3
            
            cellDescriptors[dateCellSection][dateCellRow].setValue(selectedDateString, forKey: "primaryTitle")
            tblExpandable.reloadData()
        }
        
        
        func maritalStatusSwitchChangedState(isOn: Bool) {
            let maritalSwitchCellSection = 0
            let maritalSwitchCellRow = 6
            
            let valueToStore = (isOn) ? "true" : "false"
            let valueToDisplay = (isOn) ? "Married" : "Single"
            
            cellDescriptors[maritalSwitchCellSection][maritalSwitchCellRow].setValue(valueToStore, forKey: "value")
            cellDescriptors[maritalSwitchCellSection][maritalSwitchCellRow - 1].setValue(valueToDisplay, forKey: "primaryTitle")
            tblExpandable.reloadData()
        }
        
        
        func textfieldTextWasChanged(newText: String, parentCell: CustomCell) {
            let parentCellIndexPath = tblExpandable.indexPathForCell(parentCell)
            
            let currentFullname = cellDescriptors[0][0]["primaryTitle"] as! String
            let fullnameParts = currentFullname.componentsSeparatedByString(" ")
            
            var newFullname = ""
            
            if parentCellIndexPath?.row == 1 {
                if fullnameParts.count == 2 {
                    newFullname = "\(newText) \(fullnameParts[1])"
                }
                else {
                    newFullname = newText
                }
            }
            else {
                newFullname = "\(fullnameParts[0]) \(newText)"
            }
            
            cellDescriptors[0][0].setValue(newFullname, forKey: "primaryTitle")
            tblExpandable.reloadData()
        }
        
        
        func sliderDidChangeValue(newSliderValue: String) {
            cellDescriptors[2][0].setValue(newSliderValue, forKey: "primaryTitle")
            cellDescriptors[2][1].setValue(newSliderValue, forKey: "value")
            
            tblExpandable.reloadSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.None)
        }

    @IBAction func onBackPressed(sender: UIButton) {
         self.dismissViewControllerAnimated(true, completion: nil)
    }


}



    /*

var username: String!
var friendname: String!
//display names
var showuser: String!
var showfriend: String!

@IBOutlet weak var userLabel: UILabel!
@IBOutlet weak var friendLabel: UILabel!

@IBOutlet weak var tableView: UITableView!
@IBOutlet weak var txtChatBox: UITextField!

let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

let transitionOperator = TransitionOperator()

@IBOutlet weak var customCell: UITableViewCell!


var cellDescriptors: NSMutableArray!

var visibleRowsPerSection = [[Int]]()


var messagesArray = [ChatStatus]()

var someInts = [Friend]()
let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()


override func viewDidLoad()
{
super.viewDidLoad()
self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
//tableView

//NSNOTIFICATION OBSERVER INITILIZER
NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFriendNotif:", name: FriendActivityNotifKey, object: nil)
if self.delegate.yourFriends.count == 0{
//init param for the initial list from msqli~~~~~~~~~~~~~~~~~~~~
let username:String = prefs.valueForKey("USERNAME") as! String
let post:NSString = "username=\(username)"
NSLog("PostData: %@",post);
//random shit needed for the http request
let url:NSURL = NSURL(string: "http://www.jjkbashlord.com/fetchRendezChatNotifChecker.php")!
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
let jsonData:NSArray = (try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers )) as! NSArray
for(var index = 0; index < jsonData.count; index++ ){


let username1:NSString = jsonData[index].valueForKey("username") as! NSString
let title1:NSString = jsonData[index].valueForKey("showname") as! NSString
let detail1:NSString = jsonData[index].valueForKey("timestamp") as! NSString

let dateFormatter = NSDateFormatter()
dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
let date = dateFormatter.dateFromString(detail1 as String)

print("Initial friendlist fetch for " + (username1 as String) + "\n")
print("showname: " + (title1 as String) + "\n")
print("date: " + (date?.description)! + "\n")


let status = Friend(username: username1 as String, showname: title1 as String, timestamp: date!)
someInts.append(status)
}
self.delegate.loadFriends(someInts)
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
}else{
someInts = self.delegate.yourFriends
}
//done with the initial fetch~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
}

override func viewWillAppear(animated: Bool) {
super.viewWillAppear(animated)

configureTableView()

loadCellDescriptors()
}


override func didReceiveMemoryWarning() {
super.didReceiveMemoryWarning()
// Dispose of any resources that can be recreated.
}


// MARK: Custom Functions

func configureTableView() {
tableView.delegate = self
tableView.dataSource = self
tableView.tableFooterView = UIView(frame: CGRectZero)

tableView.registerNib(UINib(nibName: "NormalCell", bundle: nil), forCellReuseIdentifier: "idCellNormal")
tableView.registerNib(UINib(nibName: "TextfieldCell", bundle: nil), forCellReuseIdentifier: "idCellTextfield")
tableView.registerNib(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "idCellDatePicker")
tableView.registerNib(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "idCellSwitch")
tableView.registerNib(UINib(nibName: "ValuePickerCell", bundle: nil), forCellReuseIdentifier: "idCellValuePicker")
tableView.registerNib(UINib(nibName: "SliderCell", bundle: nil), forCellReuseIdentifier: "idCellSlider")
}


func loadCellDescriptors() {
if let path = NSBundle.mainBundle().pathForResource("CellDescriptor", ofType: "plist") {
cellDescriptors = NSMutableArray(contentsOfFile: path)
getIndicesOfVisibleRows()
tableView.reloadData()
}
}


func getIndicesOfVisibleRows() {
visibleRowsPerSection.removeAll()

for currentSectionCells in cellDescriptors {
var visibleRows = [Int]()

/*for row in 0...((currentSectionCells as! [[String: AnyObject]]).count - 1) {
if currentSectionCells[row]["isVisible"] as! Bool == true */
for var x = 0; x < (self.someInts.count); x++
{
visibleRows.append(x)
}



visibleRowsPerSection.append(visibleRows)
}
}


func getCellDescriptorForIndexPath(indexPath: NSIndexPath) -> [String: AnyObject] {
let indexOfVisibleRow = visibleRowsPerSection[indexPath.section][indexPath.row]
let cellDescriptor = cellDescriptors[indexPath.section][indexOfVisibleRow] as! [String: AnyObject]
return cellDescriptor
}


// MARK: UITableView Delegate and Datasource Functions

func numberOfSectionsInTableView(tableView: UITableView) -> Int {
if cellDescriptors != nil {
return cellDescriptors.count
}
else {
return 0
}
}


func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
return visibleRowsPerSection[section].count
}

func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
let currentCellDescriptor = self.someInts[indexPath.row]
let cell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier", forIndexPath: indexPath) as! CustomCell

/* if currentCellDescriptor["cellIdentifier"] as! String == "idCellNormal" {
if let primaryTitle = currentCellDescriptor["primaryTitle"] {*/
cell.textLabel?.text = self.someInts[indexPath.row].username as? String

/*
if let secondaryTitle = currentCellDescriptor["secondaryTitle"] {
cell.detailTextLabel?.text = secondaryTitle as? String
}
}
else if currentCellDescriptor["cellIdentifier"] as! String == "idCellTextfield" {
cell.textField.placeholder = currentCellDescriptor["primaryTitle"] as? String
}
else if currentCellDescriptor["cellIdentifier"] as! String == "idCellSwitch" {
cell.lblSwitchLabel.text = currentCellDescriptor["primaryTitle"] as? String

let value = currentCellDescriptor["value"] as? String
cell.swMaritalStatus.on = (value == "true") ? true : false
}
else if currentCellDescriptor["cellIdentifier"] as! String == "idCellValuePicker" {
cell.textLabel?.text = currentCellDescriptor["primaryTitle"] as? String
}
else if currentCellDescriptor["cellIdentifier"] as! String == "idCellSlider" {
let value = currentCellDescriptor["value"] as! String
cell.slExperienceLevel.value = (value as NSString).floatValue
}*/

cell.delegate = self

return cell
}


func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath)

switch currentCellDescriptor["cellIdentifier"] as! String {
case "idCellNormal":
return 60.0

case "idCellDatePicker":
return 270.0

default:
return 44.0
}
}


func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
let indexOfTappedRow = visibleRowsPerSection[indexPath.section][indexPath.row]

if cellDescriptors[indexPath.section][indexOfTappedRow]["isExpandable"] as! Bool == true {
var shouldExpandAndShowSubRows = false
if cellDescriptors[indexPath.section][indexOfTappedRow]["isExpanded"] as! Bool == false {
// In this case the cell should expand.
shouldExpandAndShowSubRows = true
}

cellDescriptors[indexPath.section][indexOfTappedRow].setValue(shouldExpandAndShowSubRows, forKey: "isExpanded")

for i in (indexOfTappedRow + 1)...(indexOfTappedRow + (cellDescriptors[indexPath.section][indexOfTappedRow]["additionalRows"] as! Int)) {
cellDescriptors[indexPath.section][i].setValue(shouldExpandAndShowSubRows, forKey: "isVisible")
}
}
else {
if cellDescriptors[indexPath.section][indexOfTappedRow]["cellIdentifier"] as! String == "idCellValuePicker" {
var indexOfParentCell: Int!

for var i=indexOfTappedRow - 1; i>=0; --i {
if cellDescriptors[indexPath.section][i]["isExpandable"] as! Bool == true {
indexOfParentCell = i
break
}
}

cellDescriptors[indexPath.section][indexOfParentCell].setValue((tableView.cellForRowAtIndexPath(indexPath) as! CustomCell).textLabel?.text, forKey: "primaryTitle")
cellDescriptors[indexPath.section][indexOfParentCell].setValue(false, forKey: "isExpanded")

for i in (indexOfParentCell + 1)...(indexOfParentCell + (cellDescriptors[indexPath.section][indexOfParentCell]["additionalRows"] as! Int)) {
cellDescriptors[indexPath.section][i].setValue(false, forKey: "isVisible")
}
}
}

getIndicesOfVisibleRows()
tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
}


// MARK: CustomCellDelegate Functions

func dateWasSelected(selectedDateString: String) {
let dateCellSection = 0
let dateCellRow = 3

cellDescriptors[dateCellSection][dateCellRow].setValue(selectedDateString, forKey: "primaryTitle")
tableView.reloadData()
}


func maritalStatusSwitchChangedState(isOn: Bool) {
let maritalSwitchCellSection = 0
let maritalSwitchCellRow = 6

let valueToStore = (isOn) ? "true" : "false"
let valueToDisplay = (isOn) ? "Married" : "Single"

cellDescriptors[maritalSwitchCellSection][maritalSwitchCellRow].setValue(valueToStore, forKey: "value")
cellDescriptors[maritalSwitchCellSection][maritalSwitchCellRow - 1].setValue(valueToDisplay, forKey: "primaryTitle")
tableView.reloadData()
}


func textfieldTextWasChanged(newText: String, parentCell: CustomCell) {
let parentCellIndexPath = tableView.indexPathForCell(parentCell)

let currentFullname = cellDescriptors[0][0]["primaryTitle"] as! String
let fullnameParts = currentFullname.componentsSeparatedByString(" ")

var newFullname = ""

if parentCellIndexPath?.row == 1 {
if fullnameParts.count == 2 {
newFullname = "\(newText) \(fullnameParts[1])"
}
else {
newFullname = newText
}
}
else {
newFullname = "\(fullnameParts[0]) \(newText)"
}

cellDescriptors[0][0].setValue(newFullname, forKey: "primaryTitle")
tableView.reloadData()
}


func sliderDidChangeValue(newSliderValue: String) {
cellDescriptors[2][0].setValue(newSliderValue, forKey: "primaryTitle")
cellDescriptors[2][1].setValue(newSliderValue, forKey: "value")

tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.None)
}

}
*/