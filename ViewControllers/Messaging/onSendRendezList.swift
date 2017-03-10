//
//  onSendRendezList.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/14/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit

extension UIColor {
    class func randomColor() -> UIColor {
        
        let hue = CGFloat(arc4random() % 100) / 100
        let saturation = CGFloat(arc4random() % 100) / 100
        let brightness = CGFloat(arc4random() % 100) / 100
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

func generateRandomData() -> [[UIColor]] {
    let numberOfRows = 20
    let numberOfItemsPerRow = 15
    
    return (0..<numberOfRows).map { _ in
        return (0..<numberOfItemsPerRow).map { _ in UIColor.randomColor() }
    }
}

func jsonify(id: Int, username:String, title:String, detail:String, location:String, timefor:String, type:Int, response:Int) -> [String:Any]{
    var ret = [String:Any]()
    ret["id"] = id
    ret["friend"] = username
    ret["title"] = title
    ret["detail"] = detail
    ret["location"] = location
    ret["timefor"] = timefor
    ret["type"] = type
    ret["response"] = response
    
    return ret
    
}

class onSendRendezList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bBack: UIButton!

    var rendez = [Status]()
    var friends = [Friend]()
    var groups = [Groups]()
    var peeps = [AnyObject]()
    var added = [Bool]()
    var selectedRendez: Status!
    var username:String!

    lazy var friendView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(230, green: 230, blue: 230)
        //view.backgroundColor = UIColor.red
        return view
    }()
    lazy var friendTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom )
        button.backgroundColor = UIColor.red
        //button.imageView?.image = UIImage(named: "cancel")
        button.setBackgroundImage(UIImage(named: "cancel")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        button.tintColor = UIColor.rgb(91, green: 14, blue: 13)
        button.layer.cornerRadius = 10
        return button
    }()
    lazy var checkButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom )
        button.backgroundColor = UIColor.green
        //button.imageView?.image = UIImage(imageLiteralResourceName: "check")
        button.setBackgroundImage(UIImage(named: "check")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        button.tintColor = UIColor.rgb(14, green: 91, blue: 13)
        button.layer.cornerRadius = 10
        return button
    }()
    @IBOutlet weak var rendezTableView: UITableView!
    @IBOutlet weak var pickLabel: UILabel!
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    lazy var locLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    lazy var titleL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blue
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "Title"
        return label
    }()
    lazy var detailL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blue
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "Detail"
        return label
    }()
    lazy var locL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blue
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "Location"
        return label
    }()
    
     var path: IndexPath!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rendezTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //self.friendTableView.dataSource = self
        //self.friendTableView.delegate = self
        self.friendTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell1")
        let prefs:UserDefaults = UserDefaults.standard
        username = prefs.value(forKey: "USERNAME") as! String
        self.view.backgroundColor = UIColor.rgb(240, green: 240, blue: 240)
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        if topLabel.frame.origin.x != 0{
            topLabel.frame = CGRect(x: 0, y: 20, width: width, height: 40)
            bBack.frame = CGRect(x: 0, y: 20, width: bBack.frame.size.width, height: 40)
            //current height at 60px
            
            pickLabel.frame = CGRect(x: 0, y: 65, width: width, height: 30)
            // current height 60px+5px+30px = 95px, start table at 100px
            
            rendezTableView.frame = CGRect(x: 10, y: 100, width: width-20, height: height-110)
            
            view.addSubview(friendView)
            friendView.frame = CGRect(x: width, y: 65, width: width-20, height: height-80)
            setupView()
            cancelButton.addTarget(self, action: #selector(onCancelPressed), for: .touchDown)
            checkButton.addTarget(self, action: #selector(onSendPressed), for: .touchDown)
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if self.peeps.count > 0{
            self.peeps.removeAll()
            self.added.removeAll()
        }
        
        for x in self.friends{
            self.peeps.append(x)
            self.added.append(false)
        }
        for x in self.groups{
            self.peeps.append(x)
            self.added.append(false)
        }
        self.rendezTableView.reloadData()
        //self.friendTableView.reloadData()
        print("onSendRendezList counts peeps/rendez ", self.peeps.count, self.rendez.count)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView(){

        friendView.addSubview(titleL)
        friendView.addSubview(detailL)
        friendView.addSubview(locL)
        friendView.addSubview(titleLabel)
        friendView.addSubview(detailLabel)
        friendView.addSubview(locLabel)
        friendView.addSubview(self.friendTableView)
        friendView.addSubview(cancelButton)
        friendView.addSubview(checkButton)
       
        friendView.addConstraintsWithFormat("V:|-5-[v0]-3-[v1]-10-[v2]-3-[v3]-10-[v4]-3-[v5]-15-[v6]-60-|", views: titleL, titleLabel, detailL, detailLabel, locL, locLabel, self.friendTableView)
        friendView.addConstraintsWithFormat("V:[v0(50)]-5-|", views: cancelButton )
        friendView.addConstraintsWithFormat("V:[v0(50)]-5-|", views: checkButton )
        friendView.addConstraintsWithFormat("H:|-16-[v0]-16-|", views: titleL)
        friendView.addConstraintsWithFormat("H:|-16-[v0]-16-|", views: titleLabel)
        friendView.addConstraintsWithFormat("H:|-16-[v0]-16-|", views: detailL)
        friendView.addConstraintsWithFormat("H:|-16-[v0]-16-|", views: detailLabel)
        friendView.addConstraintsWithFormat("H:|-16-[v0]-16-|", views: locLabel)
        friendView.addConstraintsWithFormat("H:|-16-[v0]-16-|", views: locL)
        friendView.addConstraintsWithFormat("H:|-16-[v0]-16-|", views: self.friendTableView)
        friendView.addConstraintsWithFormat("H:|-16-[v0(60)]", views: cancelButton)
        friendView.addConstraintsWithFormat("H:[v0(60)]-16-|", views: checkButton)
        cancelButton.imageView?.image = UIImage(imageLiteralResourceName: "cancel")
        checkButton.imageView?.image = UIImage(imageLiteralResourceName: "check")
    }
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onCancelPressed(){
        selectedRendez = nil
        // red x shown after a rendez is picked from the first tableview
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            self.friendView.frame.origin.x = UIScreen.main.bounds.width
        }) { (completed: Bool) in }
    }

    func onSendPressed(){
        // green check mark
        sendTapped()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("")
        if tableView == rendezTableView{
            titleLabel.text = self.rendez[indexPath.row].title
            detailLabel.text = self.rendez[indexPath.row].detail
            locLabel.text = self.rendez[indexPath.row].location
            selectedRendez = self.rendez[indexPath.row]
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
                self.friendView.frame.origin.x = 5
            }) { (completed: Bool) in
                self.friendTableView.delegate = self
                self.friendTableView.dataSource = self
                self.friendTableView.reloadData()
            }
        }else{
            //print(tableView.cellForRow(at: indexPath)?.isHighlighted.description, tableView.cellForRow(at: indexPath)?.isSelected.description, tableView.cellForRow(at: indexPath)?.isFocused.description )
            tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
            if added[indexPath.item] == true{
                tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.white
                added[indexPath.item] = false
            }else{
                tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.rgb(155, green: 239, blue: 169)
                added[indexPath.item] = true
            }
        }
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == rendezTableView{
            print("returning rendez count ", self.rendez.count)
            return self.rendez.count
        }else{
            print("returning peeps count ", self.peeps.count)
            return self.peeps.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == rendezTableView{
            let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 17)
            cell.textLabel!.text = self.rendez[indexPath.row].title
            let status = self.rendez[indexPath.row]
            var v = ""
            if(self.rendez[indexPath.row].visable == 0){
                v += "private"
            }else{
                v += "public"
            }
            v += "\n" + status.timefor
            cell.detailTextLabel!.text = v
            
            if(status.type == 0){
                cell.imageView?.image = UIImage(named: "eat")
            }else if(status.type == 1){
                cell.imageView?.image = UIImage(named: "party")
            }else if(status.type == 2){
                cell.imageView?.image = UIImage(named: "working")
            }else if(status.type == 3){
                cell.imageView?.image = UIImage(named: "idle")
            }
            //cell.backgroundColor = UIColor.rgb(235, green: 235, blue: 235)
            return cell
        }else{
            let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
            cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 17)
            
            print("cellForRowAt called ")
            if let a = self.peeps[indexPath.row] as? Groups{
                print(a.groupname)
                cell.textLabel!.text = a.groupname
            }else if let a = self.peeps[indexPath.row] as? Friend{
                print(a.friendname)
                cell.textLabel!.text = a.friendname
            }
            return cell
        }
    }
    
    func sendTapped() {
        var arr = [AnyObject]()
        var friendarr = [AnyObject]()
        var delegate = UIApplication.shared.delegate as! AppDelegate
        let prefs:UserDefaults = UserDefaults.standard
        let showname:String = prefs.value(forKey: "SHOWNAME") as! String
        let userObject = ["username": self.username, "showname": showname]
        arr.append(userObject as AnyObject)
        let statusObject = ["title": titleLabel.text ?? "", "detail": detailLabel.text ?? "", "location": locLabel.text ?? "", "type": selectedRendez.type, "timefor": selectedRendez.timefor, "response": 0] as [String : Any]
        arr.append(statusObject as AnyObject)
 
        for i in 0..<self.peeps.count{
            if added[i] == true{
                if let entity = self.peeps[i] as? Groups{
                    let groupObj = ["username": entity.groupname, "showname": entity.groupdetail]
                    friendarr.append(groupObj as AnyObject)
                    //let emitobj = ["id": selectedRendez.id as AnyObject, "friend": entity.groupname as AnyObject, "title": titleLabel ?? "", "detail": detailLabel.text ?? "", "location": locLabel ?? "", "timefor": selectedRendez.timefor, "type": selectedRendez.type, "response": 0] as [String : Any]
                    let emitobj = jsonify(id: selectedRendez.id, username: entity.groupname, title: titleLabel.text!, detail: detailLabel.text!, location: locLabel.text!, timefor: selectedRendez.timefor, type: selectedRendez.type, response: 0)
                    delegate.grouparr.append(emitobj as AnyObject)
                }else if let entity = self.peeps[i] as? Friend{
                    let friendObj = ["username": entity.username, "showname": entity.friendname]
                    friendarr.append(friendObj as AnyObject)
                    //let emitobj = ["id": selectedRendez.id as AnyObject, "friend": entity.username as AnyObject, "title": titleLabel.text ?? "", "detail": detailLabel ?? "", "location": locLabel.text ?? "", "timefor": selectedRendez.timefor, "type": selectedRendez.type, "response": 0] as [String : Any]
                    let emitobj = jsonify(id: selectedRendez.id, username: entity.username, title: titleLabel.text!, detail: detailLabel.text!, location: locLabel.text!, timefor: selectedRendez.timefor, type: selectedRendez.type, response: 0)
                    delegate.friendarr.append(emitobj as AnyObject)
                }
            }
        }
        
        if(friendarr.count == 0){
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "You have not chosen any friends!!"
            alertView.message = "Choose a friend loser"
            alertView.delegate = self
            alertView.addButton(withTitle: "OK")
            alertView.show()
        }
        else{
            delegate.events.trigger(eventName: "emitRendez")
            let friendarray = ["array": friendarr]
            arr.append(friendarray as AnyObject)
            let finalNSArray:NSArray = arr as NSArray
            let finalarr:NSDictionary = ["json": finalNSArray]
            NSLog("PostData: %@",finalarr);
            let url:URL = URL(string: "http://www.jjkbashlord.com/sentRSwift.php")!
            let da:Data = try! JSONSerialization.data(withJSONObject: finalarr, options: [])
            print(da)
            let postLength:NSString = String( da.count ) as NSString
            let request:NSMutableURLRequest = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = da
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
                let res = response as! HTTPURLResponse!;
                //NSLog("Response code: %ld", res?.statusCode);
                if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
                {
                    let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                    NSLog("Response ==> %@", responseData);
                    let jsonData:NSObject = (try! JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers )) as! NSObject
                    NSLog("sent!!!!!!!")
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    let date = dateFormatter.string(from: Date())
                    
                    for i in 0..<self.peeps.count{
                        if added[i] == true{
                            if let friend = peeps[i] as? Friend{
                                if(!(delegate.isTheFriendInTheWoz(friend.username))){
                                    delegate.theWozMap[friend.username] = rendezChatDictionary()
                                }
                                let rendezStatus:RendezStatus = RendezStatus(id: jsonData.value(forKey: friend.username) as! Int, username: self.username, title: selectedRendez.title, details: selectedRendez.detail, location: selectedRendez.location, timeset: date, timefor: selectedRendez.timefor, type: selectedRendez.type, response: selectedRendez.response, fromuser: friend.username)
                                delegate.theWozMap[friend.username]!.allDeesRendez.append(rendezStatus)
                                friend.selected = false

                            }else if let group = peeps[i] as? Groups{
                                if(!(delegate.isTheFriendInTheWoz(group.groupname))){
                                    delegate.theWozMap[group.groupname] = rendezChatDictionary()
                                }
                            
                                let rendezStatus:RendezStatus = RendezStatus(id: jsonData.value(forKey: group.groupname) as! Int, username: self.username, title: selectedRendez.title, details: selectedRendez.detail, location: selectedRendez.location, timeset: date, timefor: selectedRendez.timefor, type: selectedRendez.type, response: selectedRendez.response, fromuser: group.groupname)
                                delegate.theWozMap[group.groupname]!.allDeesRendez.append(rendezStatus)
                                group.selected = false
                            }
                        }
                    }
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
        onCancelPressed()
    }
    
}

