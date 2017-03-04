//
//  onCreateGroupVC.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 3/10/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit

class onCreateGroupVC:  UIViewController,UITableViewDelegate, UITableViewDataSource {

    var username:String!
    var showname:String!
    @IBOutlet weak var friendListView: UITableView!
    @IBOutlet weak var groupName: UITextField!
    
    @IBOutlet weak var groupDescription: UITextField!
    var someInts = [Friend]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.friendListView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        someInts += delegate.yourFriends
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return self.someInts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 3
        let cell:UITableViewCell = self.friendListView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = self.someInts[indexPath.row].friendname
        let select = self.someInts[indexPath.row].selected
        if(select == false){
            //self.someInts[indexPath.row].selected = true
           // cell.setSelected(false, animated: true)
            cell.accessoryType = UITableViewCellAccessoryType.none;
        }
        else{
            //self.someInts[indexPath.row].selected = false
            //cell.setSelected(false, animated: true)
             cell.accessoryType = UITableViewCellAccessoryType.checkmark;
        }
        print("TableView: " + self.someInts[indexPath.row].friendname)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let select = self.someInts[indexPath.row].selected
        
        if(select == false){
            self.someInts[indexPath.row].selected = true
            //tableView.cellForRowAtIndexPath(indexPath)?.setSelected(true, animated: true)
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark;
        }
        else{
            self.someInts[indexPath.row].selected = false
            //tableView.cellForRowAtIndexPath(indexPath)?.setSelected(false, animated: true)
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none;
        }
    }
    

    @IBAction func onBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onGroupCreateClicked(_ sender: UIButton) {
        let prefs:UserDefaults = UserDefaults.standard
        let username:String = prefs.value(forKey: "USERNAME") as! String
        let showname:String = prefs.value(forKey: "SHOWNAME") as! String
        var arr = [NSDictionary]()
        var friendar = [Friend]()
        var memberArray = [AnyObject]()
        //add the list of selected peoples
        let friendObj = ["username": username, "showname": showname]
        memberArray.append(friendObj as AnyObject)
        for friend in self.someInts{
            if(friend.selected == true){
                let friendObj = ["username": friend.username, "showname": friend.friendname]
                memberArray.append(friendObj as AnyObject)
                friendar.append(friend)
            }
        }
        
        arr.append(["groupname": self.groupName.text!, "groupdetail": self.groupDescription.text!, "members": memberArray])
        
        let finalarr:NSDictionary = ["json": arr]
        NSLog("PostData: %@",finalarr);
        let url:URL = URL(string: "http://www.jjkbashlord.com/onGroupCreation.php")!
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
                NSLog("sent!!!!!!!")
                let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                NSLog("Response ==> %@", responseData);
                //let jsonData:Int = (try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers )) as! Int
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.yourGroups.append(Groups(id: responseData.integerValue, groupname: self.groupName.text!, groupdetail: self.groupDescription.text!, members: friendar))
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
    
    
    
    
    }


