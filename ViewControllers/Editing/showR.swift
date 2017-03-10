//
//  showR.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/26/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

protocol showRDelegate{
    func returnUpdate(_ status: Status)

}

class showR: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var isStatusFromYou:Bool!

    //pickerview spinner for seeing your response and being able to change it
    @IBOutlet weak var responsePicker: UIPickerView!
    //send button that should not show unless it is a status by you
    
    var programVar : Status!
    var programVar1 : RendezStatus!

    @IBOutlet weak var labelForResponseNames: UILabel!
    @IBOutlet weak var friendResponses: UITableView!
    //@IBOutlet weak var friendScroll: UIScrollView!
    @IBOutlet weak var timeTxt: UILabel!
    @IBOutlet weak var typeImg: UIImageView!
    
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtDetail: UILabel!
    @IBOutlet weak var txtLocation: UILabel!
    @IBOutlet weak var locL: UILabel!
    @IBOutlet weak var detailL: UILabel!
    @IBOutlet weak var titleL: UILabel!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bBack: UIButton!
    @IBOutlet weak var bDelete: UIButton!
    @IBOutlet weak var bMap: UIButton!
    var returnDelegate: showRDelegate!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var vm: showRMap!
    
    var username: String!
    var friendname: String!
    var showuser: String!
    var showfriend: String!
    var responses = ["Seen!", "Interested!", "Available"]

    var transitionOperator = TransitionOperator()

    @IBOutlet weak var visableIndicator: UISwitch!
    var switchBool:Bool!
    @IBOutlet weak var visabl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.friendResponses.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.backgroundColor = UIColor.rgb(240, green: 240, blue: 240)
        if topLabel.frame.origin.x < 0{
            setupViews()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //switchBool = self.programVar.visable
        
        if self.programVar != nil{
            txtTitle.text = self.programVar.title as NSString as String
            txtDetail.text = self.programVar.detail as NSString as String
            txtLocation.text = self.programVar.location as NSString as String
            if self.programVar.type == 0{
                typeImg.image = UIImage(named: "eat")
            }
            if self.programVar.type == 1{
                typeImg.image = UIImage(named: "party")
            }
            if self.programVar.type == 2{
                typeImg.image = UIImage(named: "working")
            }
            if self.programVar.type == 3{
                typeImg.image = UIImage(named: "idle")
            }
            if  self.programVar.timefor != "0000-00-00 00:00"{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                timeTxt.text = "Set for " + self.programVar.timefor
            }else{
                timeTxt.text = "No Starting Time Set!"
            }
            
            if self.isStatusFromYou == false{
                if(self.visableIndicator != nil){
                self.visabl.removeFromSuperview()
                self.visableIndicator.removeFromSuperview()
                self.friendResponses.removeFromSuperview()
                self.responsePicker.selectRow(self.programVar.response, inComponent: 0, animated: true)
                    self.labelForResponseNames.text = "You have "

                }
            }else{
                if(self.responsePicker != nil){
                    self.responsePicker.removeFromSuperview()
                    if self.programVar.visable == 1{
                        self.visableIndicator.setOn(true, animated: true)
                        self.visabl.text = "Visability: Public"
                    }else{
                        self.visableIndicator.setOn(false, animated: true)
                        self.visabl.text = "Visability: Private"
                    }
                }
            }
        }
        else{
            txtTitle.text = self.programVar1.title as NSString as String
            txtDetail.text = self.programVar1.details as NSString as String
            txtLocation.text = self.programVar1.location as NSString as String
        }
    }
    
    
    @IBAction func deleteR(_ sender: UIButton) {
        let prefs:UserDefaults = UserDefaults.standard
        
        let username:String = prefs.string(forKey: "USERNAME") as String!
        
        let title:String = txtTitle.text as String!
        let detail:String = txtDetail.text as String!
        let location: String = txtLocation.text as String!
        
        let post:NSString = "username=\(username)&title=\(title)&detail=\(detail)&location=\(location)" as NSString
        NSLog("PostData: %@",post);
        
        let url:URL = URL(string: "http://www.jjkbashlord.com/deleteStatus.php")!
        
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
                
                //var error: NSError?
                
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
        vm.coords = coords
        vm.title1 = title
        vm.detail = detail
        vm.flag = 1
        
        self.present(vm, animated: true, completion: nil)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        let prefs:UserDefaults = UserDefaults.standard
         let username:String = prefs.value(forKey: "USERNAME") as! String
        //if this value is 0, that means that need to check the response and if it is not the same as it was initially then got to update it
        if self.isStatusFromYou == false{
            if(self.programVar.response != self.responsePicker.selectedRow(inComponent: 0)){
                updateStatus( self.programVar.id, flag: 0, response: self.responsePicker.selectedRow(inComponent: 0))
                
                for i in 0..<self.delegate.newfeed.count{
                    if((self.delegate.newfeed[i] as Status) == self.programVar as Status){
                        self.delegate.newfeed[i].response = self.responsePicker.selectedRow(inComponent: 0)
                    }
                }
            }
        }else{
        //else need to check to see if you need to change if you updated the visability of the status
            print("back tapped for status that is yours")
            print(self.programVar.visable)
            print(visableIndicator.isOn)
            if( self.programVar.visable == 0 && visableIndicator.isOn){
                print("changing visable to true after toggle in showR")
                updateStatus( self.programVar.id, flag: 1, response: 1)
                
                  for i in 0..<self.delegate.theWozMap[username]!.allDeesStatus.count{
                    if((  self.delegate.theWozMap[username]!.allDeesStatus[i] as Status) == self.programVar as Status){
                           self.delegate.theWozMap[username]!.allDeesStatus[i].visable = 1
                        self.returnDelegate.returnUpdate(self.delegate.newfeed[i])
                    }
                }

            }else if( self.programVar.visable == 1 && !visableIndicator.isOn){
                updateStatus(self.programVar.id, flag: 1, response: 0)
                
                for i in 0..<self.delegate.theWozMap[username]!.allDeesStatus.count{
                    if((  self.delegate.theWozMap[username]!.allDeesStatus[i] as Status) == self.programVar as Status){
                        self.delegate.theWozMap[username]!.allDeesStatus[i].visable = 0
                        self.returnDelegate.returnUpdate(self.delegate.newfeed[i])
                    }
                }

            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        if (self.programVar == nil){
            return 0
        }else{
        return self.programVar.fromuser.count
        }}

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 3
        
 
        let prefs:UserDefaults = UserDefaults.standard
        //let username = prefs.valueForKey("USERNAME") as! String
        
            let cell:UITableViewCell = self.friendResponses.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        var r = ""
        if programVar.fromuser[indexPath.row].response == 0{
            r = " has seen!"
        }else if programVar.fromuser[indexPath.row].response == 1{
            r = " is interested!"
        }else if programVar.fromuser[indexPath.row].response == 2{
            r = " is available!"
        }
        
        let resp:String = programVar.fromuser[indexPath.row].username + r
            cell.textLabel!.text = resp
            return cell
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.responses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.responses[row]
    }
    
    func updateStatus(_ id:Int, flag:Int, response:Int) {
        let prefs:UserDefaults = UserDefaults.standard
        
        let username:String = prefs.string(forKey: "USERNAME") as String!
        
       // let title:String = txtTitle.text as String!
        //let detail:String = txtDetail.text as String!
       // let location: String = txtLocation.text as String!
        
        let post:NSString = "id=\(id)&username=\(username)&response=\(response)&flag=\(flag)" as NSString
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
                
                //var error: NSError?
                
                self.dismiss(animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Sign in Failed!", message: "Connection Failed", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title:  "OK", style: .default) { action in
                    // perhaps use action.title here
                })
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Sign in Failed!", message: "Connection Failed", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title:  "OK", style: .default) { action in
                // perhaps use action.title here
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func onVisChange(_ sender: UISwitch) {
        if visableIndicator.isOn{
            visabl.text = "Visability: Public"
        }else{
            visabl.text = "Visability: Private"
        }
    }
    

    func setupViews(){
        view.addConstraintsWithFormat("V:|-20-[v0(40)]", views: topLabel)
        view.addConstraintsWithFormat("H:|[v0]|", views: topLabel)
        view.addConstraintsWithFormat("H:|[v0(60)]", views: bBack)
        view.addConstraintsWithFormat("V:|-20-[v0]", views: bBack)
        //currently after status bar and top label ending at 60px height
        
        view.addConstraintsWithFormat("V:|-65-[v0(25)]-5-[v1(30)]-5-[v2(25)]-5-[v3(60)]-5-[v4(25)]-5-[v5(30)]-20-[v6(60)]-30-[v7]-15-[v8]", views: titleL, txtTitle, detailL, txtDetail, locL, txtLocation, typeImg, visabl, friendResponses)
        view.addConstraintsWithFormat("V:[v0(60)]-16-|", views: bMap)
        view.addConstraintsWithFormat("V:[v0(60)]-16-|", views: bDelete)
        
        view.addConstraint(NSLayoutConstraint(item: timeTxt, attribute: .top, relatedBy: .equal, toItem: typeImg, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: visableIndicator, attribute: .top, relatedBy: .equal, toItem: visabl, attribute: .top, multiplier: 1, constant: 0))

        
        view.addConstraintsWithFormat("H:|-16-[v0]", views: titleL)
        view.addConstraintsWithFormat("H:|-16-[v0]", views: detailL)
        view.addConstraintsWithFormat("H:|-16-[v0]", views: locL)
        view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: txtTitle)
        view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: txtDetail)
        view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: txtLocation)
        view.addConstraintsWithFormat("H:|-26-[v0(60)]", views: typeImg)
        view.addConstraintsWithFormat("H:|-16-[v0]", views: visabl)
        view.addConstraintsWithFormat("H:|-16-[v0(130)]", views: bMap)
        view.addConstraintsWithFormat("H:[v0(130)]-16-|", views: bDelete)

    }

}
