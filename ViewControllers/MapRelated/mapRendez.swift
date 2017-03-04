//
//  chattingR.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 9/2/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

class mapRendez: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, CustomCellDelegate {
    //usernames

    var friendname: String!
    //display names
    var showuser: String!
    var showfriend: String!
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var friendLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtChatBox: UITextField!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    let transitionOperator = TransitionOperator()
    
    @IBOutlet weak var customCell: UITableViewCell!
    
    var cellDescriptors: NSMutableArray = NSMutableArray()
    
    var visibleRowsPerSection = [[Int]]()
    
    
    var messagesArray = [ChatStatus]()
    
    var someInts = [Friend]()
    let prefs:UserDefaults = UserDefaults.standard
    var username:String!// = prefs.valueForKey("USERNAME") as! String
    var someFriendInts = [RendezStatus]()
        @IBOutlet weak var tblExpandable: UITableView!
        
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        username = prefs.value(forKey: "USERNAME") as! String
        }
        
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.someInts.removeAll()
            self.someInts.append(contentsOf: self.delegate.theNotifHelper.returnFriendNotif())
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
            tblExpandable.tableFooterView = UIView(frame: CGRect.zero)
            
            tblExpandable.register(UINib(nibName: "NormalCell", bundle: nil), forCellReuseIdentifier: "idCellNormal")
            tblExpandable.register(UINib(nibName: "TextfieldCell", bundle: nil), forCellReuseIdentifier: "idCellTextfield")
            tblExpandable.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "idCellDatePicker")
            tblExpandable.register(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "idCellSwitch")
            tblExpandable.register(UINib(nibName: "ValuePickerCell", bundle: nil), forCellReuseIdentifier: "idCellValuePicker")
            tblExpandable.register(UINib(nibName: "SliderCell", bundle: nil), forCellReuseIdentifier: "idCellSlider")
        }
        
        
        func loadCellDescriptors() {
                let celler = NSMutableArray()
                for x in self.someInts{
                    if(!(delegate.isTheFriendInTheWoz(x.username))){
                        //not only does this store the chat in theWoz but also returns the rendezchatdictionary
                        let niceToMeetYou:rendezChatDictionary = delegate.makeFriendsWithWoz(username, friendname: x.username)
                        someFriendInts.append(contentsOf: niceToMeetYou.allDeesRendez)
                        print("they had to be introduced first but it is gucci meng now")
                        
                    }
                    else{ //the chat of that friend exists already, so lets just get it from theWozMap and make the lists
                        let statuslist = delegate.theWozMap[x.username]!
                        let rendez = statuslist?.allDeesRendez
                        someFriendInts += rendez!
                        NSLog("\n THE CHAT HAS RETRIEVED THE STATIC LIST FROM THE WOZ")
                    }
                    
                    let cell:NSMutableDictionary = ["isExpandable": true, "isExpanded": false, "isVisible": true, "value": "", "primaryTitle": "", "secondaryTitle": x.username, "cellIdentifier": "idCellNormal", "additionalRows": someFriendInts.count]
                    celler.add(cell)
                    
                    for y in someFriendInts{
                        if y.username == username{
                            let z = "From " + (y.username as String) + " at " + y.timeset
                        let fcell:NSMutableDictionary = ["isExpandable": false, "isExpanded": false, "isVisible": false, "value": "", "primaryTitle": y.title, "secondaryTitle": z, "cellIdentifier": "idCellNormal", "additionalRows": 0, "id": y.id]
                        celler.add(fcell)
                        }else{
                            let z = "To " + (y.username as String) + " at " + y.timeset
                            let fcell:NSMutableDictionary = ["isExpandable": false, "isExpanded": false, "isVisible": false, "value": "", "primaryTitle": y.title, "secondaryTitle": z, "cellIdentifier": "idCellNormal", "additionalRows": 0, "id": y.id]
                            celler.add(fcell)
                        }
                    }
                }
                cellDescriptors.add(celler)
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
                    if let v = ((currentSectionCells as! NSMutableArray)[row] as! [String:AnyObject])["isVisible"] as? Bool {
                        if v == true {
                            visibleRows.append(row)
                        }
                    }else{ /*  */}
                }
                visibleRowsPerSection.append(visibleRows)
            }
        }
        
        
        func getCellDescriptorForIndexPath(_ indexPath: IndexPath) -> [String: AnyObject] {
            let indexOfVisibleRow = visibleRowsPerSection[indexPath.section][indexPath.row]
            let cellDescriptor = (cellDescriptors[indexPath.section] as! NSMutableArray)[indexOfVisibleRow] as! [String: AnyObject]
            return cellDescriptor
        }
        
        
        // MARK: UITableView Delegate and Datasource Functions
        
        func numberOfSections(in tableView: UITableView) -> Int {
            if cellDescriptors.count != 0 {
                return cellDescriptors.count
            }
            else {
                return 0
            }
        }
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if(!visibleRowsPerSection.isEmpty){
                return visibleRowsPerSection[section].count
            }else{
                return 0
            }
    }
        
        
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            
            switch section {
            case 0:
                return "Friends"
                
            case 1:
                return "Groups"
                
            default:
                return "News Feed"
            }
        }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath)
            
            
            if currentCellDescriptor["cellIdentifier"] as! String == "idCellNormal" && currentCellDescriptor["isExpandable"] as! Bool == true {
                print("Expandable Cell")
                let cell = tableView.dequeueReusableCell(withIdentifier: currentCellDescriptor["cellIdentifier"] as! String, for: indexPath) as! CustomCell
                if let primaryTitle = currentCellDescriptor["primaryTitle"] {
                    //cell.textLabel?.text = primaryTitle as? String
                    cell.detailTextLabel?.text = primaryTitle as? String
                }
                
                if let secondaryTitle = currentCellDescriptor["secondaryTitle"] {
                    //cell.detailTextLabel?.text = secondaryTitle as? String
                    cell.textLabel?.text = secondaryTitle as? String
                }
                cell.delegate = self
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "rendezmapCell", for: indexPath) as! mapRendezCell
                if let primaryTitle = currentCellDescriptor["primaryTitle"] {
                    //cell.textLabel?.text = primaryTitle as? String
                    //cell.detailTextLabel?.text = primaryTitle as? String
                    cell.title.text = primaryTitle as? String
                }
                
                if let secondaryTitle = currentCellDescriptor["secondaryTitle"] {
                    //cell.detailTextLabel?.text = secondaryTitle as? String
                    //cell.textLabel?.text = secondaryTitle as? String
                    cell.time.text = secondaryTitle as? String
                }

                
                return cell
                
            }
        }
        
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let indexOfTappedRow = visibleRowsPerSection[indexPath.section][indexPath.row]
            print( String(indexOfTappedRow) + " indexoftapped " + String(indexPath.row) + " cell at" )
            //((cellDescriptors[indexPath.section] as! NSMutableArray)[indexOfTappedRow] as! [String : AnyObject])["isExpandable"] as! Bool == false
            let isExp = ((cellDescriptors[indexPath.section] as! NSMutableArray)[indexOfTappedRow] as! [String : AnyObject])["isExpandable"] as! Bool
            let isExpanded = ((cellDescriptors[indexPath.section] as! NSMutableArray)[indexOfTappedRow] as! [String : AnyObject])["isExpanded"] as! Bool
            let id = ((cellDescriptors[indexPath.section] as! NSMutableArray)[indexOfTappedRow] as! [String : AnyObject])["id"] as! Int
            let additionalRows = ((cellDescriptors[indexPath.section] as! NSMutableArray)[indexOfTappedRow] as! [String : AnyObject])["additionalRows"] as! Int
            let primaryTitle = ((cellDescriptors[indexPath.section] as! NSMutableArray)[indexOfTappedRow] as! [String : AnyObject])["primaryTitle"] as! String
            
            if isExp == false && primaryTitle != ""{
                print("Selecting a subcell in the expandable tableview.")
                //set the variables to the notification center to center onto
                //wherever the cell selected is on the map
                
                for x in self.someFriendInts{
                    if x.id == id{
                         NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: x)
                    }
                }
                self.dismiss(animated: true, completion: nil)
            }
            else if isExp == true {
                print("Selecting Expandable Parent Cell.")
                
                var shouldExpandAndShowSubRows = false
                if isExpanded == false {
                    // In this case the cell should expand.
                    shouldExpandAndShowSubRows = true
                }
                print(indexPath.section)
                print(indexOfTappedRow)
                //print(cellDescriptors[indexPath.section][indexOfTappedRow])
                ((cellDescriptors[indexPath.section] as! NSMutableArray)[indexOfTappedRow] as! NSDictionary).setValue(shouldExpandAndShowSubRows, forKeyPath: "isExpanded")//(shouldExpandAndShowSubRows, forKey: "isExpanded")

                for i in (indexOfTappedRow + 1)...(indexOfTappedRow + additionalRows) {
                    ((cellDescriptors[indexPath.section] as! NSMutableArray)[i] as! NSDictionary).setValue(shouldExpandAndShowSubRows, forKey: "isVisible")
                }
            }
            else {
                print("features in process")
                
            }
            
            getIndicesOfVisibleRows()
            tblExpandable.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.fade)
        }
        
        
        // MARK: CustomCellDelegate Functions

    
        func textfieldTextWasChanged(_ newText: String, parentCell: CustomCell) {
            let parentCellIndexPath = tblExpandable.indexPath(for: parentCell)
            
            let currentFullname = ((cellDescriptors[0] as! NSMutableArray)[0] as! [String:AnyObject])["primaryTitle"] as! String
            let fullnameParts = currentFullname.components(separatedBy: " ")
            
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
            
            ((cellDescriptors[0] as! NSMutableArray)[0] as! NSDictionary).setValue(newFullname, forKey: "primaryTitle")
            tblExpandable.reloadData()
        }
        
        
        func sliderDidChangeValue(_ newSliderValue: String) {
            ((cellDescriptors[2] as! NSMutableArray)[0] as! NSDictionary).setValue(newSliderValue, forKey: "primaryTitle")
            ((cellDescriptors[2] as! NSMutableArray)[1] as! NSDictionary).setValue(newSliderValue, forKey: "value")
            
            tblExpandable.reloadSections(IndexSet(integer: 2), with: UITableViewRowAnimation.none)
        }

    @IBAction func onBackPressed(_ sender: UIButton) {
         self.dismiss(animated: true, completion: nil)
    }

    
    

}

