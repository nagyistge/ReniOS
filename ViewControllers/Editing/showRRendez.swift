//
//  showR.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/26/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit
import CoreLocation



class showRRendez: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate {
     var manager: OneShotLocationManager = OneShotLocationManager()
    let locationManager = CLLocationManager()
    @IBOutlet weak var deleteB: UIButton!
    var isStatusFromYou:Bool!
    @IBOutlet weak var responseName: UILabel!
    @IBOutlet weak var responsePicker: UIPickerView!
    var programVar : Status!
    var programVar1 : RendezStatus!

    @IBOutlet weak var friendResponses: UITableView!
    var friendRespArray:[GResps]! = Array<GResps>()
    
    @IBOutlet weak var sendLocButton: UIButton!
    @IBOutlet weak var timeTxt: UILabel!
    @IBOutlet weak var typeImg: UIImageView!
    
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtDetail: UILabel!
    @IBOutlet weak var txtLocation: UILabel!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var locL: UILabel!
    @IBOutlet weak var detailL: UILabel!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bBack: UIButton!
    @IBOutlet weak var bMap: UIButton!
    @IBOutlet weak var bLoc: UIButton!
    @IBOutlet weak var bDelete: UIButton!
    
    var vc: sendToFriends!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var vm: showRMap!
    
    var username: String!
    var friendname: String!
    var showuser: String!
    var showfriend: String!
    var responses = ["Seen!", "Interested!", "Available"]
    var transitionOperator = TransitionOperator()
    var locationCoords:String!
     var flag:Int = -1//IF THIS IS -1 IT IS NORMAL, ELSE IT IS A GROUPCHAT
    
    var id:Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.rgb(240, green: 240, blue: 240)
        self.friendResponses.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
        if topLabel.frame.origin.x < 0{
            setupViews()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
            txtTitle.text = self.programVar1.title as NSString as String
            txtDetail.text = self.programVar1.details as NSString as String
            txtLocation.text = self.programVar1.location as NSString as String
            if self.programVar1.type == 0{
                typeImg.image = UIImage(named: "eat")
            }
            if self.programVar1.type == 1{
                typeImg.image = UIImage(named: "party")
            }
            if self.programVar1.type == 2{
                typeImg.image = UIImage(named: "working")
            }
            if self.programVar1.type == 3{
                typeImg.image = UIImage(named: "idle")
            }
            self.timeTxt.text = " at " + self.programVar1.timefor
            
            if(self.isStatusFromYou == true){
                if(self.programVar1.response == 0){
                    self.responseName.text = self.programVar1.fromuser + " has recieved."
                }else if(self.programVar1.response == 1){
                    self.responseName.text = self.programVar1.fromuser + " is interested! "
                }else{
                    self.responseName.text = self.programVar1.fromuser + " is available!! "
                }
                
                //responsePicker.selectRow(self.programVar1.response, inComponent: 0, animated: true)
                responsePicker.delegate = nil
                if(friendResponses != nil){
                    //friendResponses.removeFromSuperview()
                    print("responsePicker removed from superview")
                    responsePicker.removeFromSuperview()
                }
            }else{
                if(self.programVar1.response == 0){
                self.responseName.text = "You have "
                }else{
                    self.responseName.text = "You are "
                }
                responsePicker.selectRow(self.programVar1.response, inComponent: 0, animated: true)
                if(deleteB != nil){
                deleteB.removeFromSuperview()
                //friendResponses.removeFromSuperview()
                }
        }
        let delegate1 = UIApplication.shared.delegate as! AppDelegate
        print("id: " + String(id))
        if delegate1.groupResponses[id] != nil{
            print("succ")
            friendRespArray.append(contentsOf: delegate1.groupResponses[id]!)
            print(friendRespArray.count)
        }else{
            print("fuafomkclqm")
            //friendRespArray = Array<GResps>()
        }
        friendResponses.reloadData()
        
    }
    
    @IBAction func deleteR(_ sender: UIButton) {
        let post:NSString = "id=\(self.programVar1.id)&flag=\(0)" as NSString
        NSLog("PostData: %@",post);
        let url:URL = URL(string: "http://www.jjkbashlord.com/updateRendez.php")!
        let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
        let postLength:NSString = String( postData.count ) as NSString
        let request:NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var reponseError: NSError?
        var response: URLResponse?
        var urlData: Data?
        do {
            urlData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning:&response)
        } catch let error as NSError {
            reponseError = error
            urlData = nil
        }
        
        if ( urlData != nil ) {
            let res = response as! HTTPURLResponse
            NSLog("Response code: %ld", res.statusCode);
            if (res.statusCode >= 200 && res.statusCode < 300){
                let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                NSLog("Response ==> %@", responseData);
                self.dismiss(animated: true, completion: nil)
            } else {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection Failed"
                alertView.delegate = self
                alertView.addButton(withTitle: "OK")
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
            alertView.addButton(withTitle: "OK")
            alertView.show()
        }
    }
    
    @IBAction func showOnMapTapped(_ sender: UIButton) {
        vm = self.storyboard?.instantiateViewController(withIdentifier: "showRMap") as! showRMap
        let coords = txtLocation.text
        let title = txtTitle.text
        let detail = txtDetail.text
        vm.name = friendname
        vm.coords = coords
        vm.title1 = title
        vm.detail = detail
        vm.flag = 1
        vm.gflag = flag
        self.present(vm, animated: true, completion: nil)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        //if this value is 0, that means that need to check the response and if it is not the same as it was initially then got to update it
        if self.isStatusFromYou == false{
            if(self.programVar1.response != self.responsePicker.selectedRow(inComponent: 0)){
                updateStatus( self.programVar1.id, flag: 2, response: self.responsePicker.selectedRow(inComponent: 0))
                
                for i in 0..<self.delegate.theWozMap[self.programVar1.fromuser]!.allDeesRendez.count{
                    if((self.delegate.theWozMap[self.programVar1.fromuser]!.allDeesRendez[i] as RendezStatus) == self.programVar1 as RendezStatus){
                        self.delegate.theWozMap[self.programVar1.fromuser]!.allDeesRendez[i].response = self.responsePicker.selectedRow(inComponent: 0)
                    }
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            return self.friendRespArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.friendResponses.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        var r = ""
        if friendRespArray[indexPath.row].resp == 0{
            r = " has seen!"
        }else if friendRespArray[indexPath.row].resp == 1{
            r = " is interested!"
        }else if friendRespArray[indexPath.row].resp == 2{
            r = " is available!"
        }
        
        let resp:String = friendRespArray[indexPath.row].name + r
        cell.textLabel!.text = resp
        return cell
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.responses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return self.responses[row]
    }

    func updateStatus(_ id:Int, flag:Int, response:Int) {
        let prefs:UserDefaults = UserDefaults.standard
        let username:String = prefs.string(forKey: "USERNAME") as String!
        //check the flag here, if it is -1 we are in a 1 to 1 rendez, else
        //we need to set some sort of indicator to update a response
        //to the correct rendezresponse that related to the groupchat....
        
        let post:NSString = "id=\(id)&response=\(response)&flag=\(flag)&username=\(username)" as NSString
        NSLog("PostData: %@",post);
        let url:URL = URL(string: "http://www.jjkbashlord.com/updateStatusResponse.php")!
        let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
        let postLength:NSString = String( postData.count ) as NSString
        let request:NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        var reponseError: NSError?
        var response: URLResponse?
        var urlData: Data?
        do {
            urlData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning:&response)
        } catch let error as NSError {
            reponseError = error
            urlData = nil
        }
        if ( urlData != nil ) {
            let res = response as! HTTPURLResponse
            NSLog("Response code: %ld", res.statusCode);
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                NSLog("Response ==> %@", responseData);
                self.dismiss(animated: true, completion: nil)
            } else {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection Failed"
                alertView.delegate = self
                alertView.addButton(withTitle: "OK")
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
            alertView.addButton(withTitle: "OK")
            alertView.show()
        }
    }
    
    func setupViews(){
        view.addConstraintsWithFormat("V:|-20-[v0(40)]", views: topLabel)
        view.addConstraintsWithFormat("H:|[v0]|", views: topLabel)
        view.addConstraintsWithFormat("H:|[v0(60)]", views: bBack)
        view.addConstraintsWithFormat("V:|-20-[v0]", views: bBack)
        //currently after status bar and top label ending at 60px height
        
        view.addConstraintsWithFormat("V:|-65-[v0(25)]-5-[v1(30)]-5-[v2(25)]-5-[v3(80)]-5-[v4(25)]-5-[v5(30)]-20-[v6(60)]-30-[v7(40)]-15-[v8]-80-|", views: titleL, txtTitle, detailL, txtDetail, locL, txtLocation, typeImg, responseName, friendResponses)
        view.addConstraintsWithFormat("V:[v0(60)]-16-|", views: bMap)
        view.addConstraintsWithFormat("V:[v0(60)]-16-|", views: bDelete)
        view.addConstraintsWithFormat("V:[v0(60)]-16-|", views: bLoc)
        
        view.addConstraintsWithFormat("H:|-16-[v0]", views: titleL)
        view.addConstraintsWithFormat("H:|-16-[v0]", views: detailL)
        view.addConstraintsWithFormat("H:|-16-[v0]", views: locL)
        view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: txtTitle)
        view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: txtDetail)
        view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: txtLocation)
        view.addConstraintsWithFormat("H:|-26-[v0(60)]", views: typeImg)
        view.addConstraintsWithFormat("H:|-16-[v0]", views: responseName)
        timeTxt.translatesAutoresizingMaskIntoConstraints = false
        responsePicker.translatesAutoresizingMaskIntoConstraints = false
        let bWidth = (UIScreen.main.bounds.size.width-112)/3
        view.addConstraintsWithFormat("H:|-16-[v0(\(bWidth))]-40-[v1(\(bWidth))]-40-[v2(\(bWidth))]-16-|", views: bMap, bDelete, bLoc)
        
        view.addConstraint(NSLayoutConstraint(item: timeTxt, attribute: .left, relatedBy: .equal, toItem: typeImg, attribute: .right, multiplier: 1, constant: 8))
        view.addConstraint(NSLayoutConstraint(item: responsePicker, attribute: .left, relatedBy: .equal, toItem:responseName, attribute: .right, multiplier: 1, constant: 8))
        
        view.addConstraint(NSLayoutConstraint(item: timeTxt, attribute: .top, relatedBy: .equal, toItem: typeImg, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: responsePicker , attribute: .centerY, relatedBy: .equal, toItem: responseName, attribute: .top, multiplier: 1, constant: 0))
        
        print("responsePicker frame ", responsePicker.frame)
        
        
        //view.addConstraintsWithFormat("H:[v0(130)]-16-|", views: bDelete)
        
    }
}
